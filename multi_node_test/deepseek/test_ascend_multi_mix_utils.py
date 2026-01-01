import os
import subprocess
import time
import requests
import threading
import psutil
import socket

from kubernetes import client, config
from kubernetes.client.rest import ApiException
from sglang.test.test_utils import ( # type: ignore
    popen_launch_server,
)


KUBE_CONFIG = os.environ.get('KUBECONFIG')
NAMESPACE = os.environ.get('NAMESPACE')
CONFIGMAP_NAME = os.environ.get('KUBE_CONFIG_MAP')

if not NAMESPACE:
    raise EnvironmentError("NAMESPACE environment variable not set")

if not CONFIGMAP_NAME:
    raise EnvironmentError("KUBE_CONFIG_MAP environment variable not set")

LOCAL_TIMEOUT = 3600
SERVICE_PORT = "6677"

def get_nic_name():
    for nic, addrs in psutil.net_if_addrs().items():
        for addr in addrs:
            if addr.family == socket.AF_INET and (addr.address.startswith("172.") or addr.address.startswith("192.")):
                print(f"The nic name matched is {nic}")
                return nic
    return None

nic_name_result = get_nic_name()
NIC_NAME = "lo" if nic_name_result is None else nic_name_result

config.load_kube_config(KUBE_CONFIG)
v1 = client.CoreV1Api()

# query configmap
def query_configmap(name: str, namespace: str) -> client.V1ConfigMap:
    try:
        configmap = v1.read_namespaced_config_map(name, namespace)
        print(f"query_configmap {name} in {namespace} successfully!")
        return configmap
    except ApiException as e:
        print(f"query_configmap {name} in {namespace} error {e=}")
        return None
    except Exception as e:
        print(f"Unexpected error in query_configmap: {e}")        
        return None   

def run_command(cmd, shell=True):
    try:
        result = subprocess.run(
            cmd, shell=shell, capture_output=True, text=True, check=False
        )
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Command error: {e}")
        return None
    
def run_bench_serving(
    host: str,
    port: str,
    model_path: str = None,
    dataset_name: str = None,
    request_rate: int = None,
    max_concurrency: int = None,
    num_prompts: int = None,
    input_len: int = None,
    output_len: int = None,
    random_range_ratio: float = 1.0,
    dataset_path: str = None,
    result_file: str = None
) -> dict:

    cmd_args = [
        "python3",
        "-m", "sglang.bench_serving",
        "--backend", "sglang",
        "--model", model_path,
        "--host", host,
        "--port", port,
    ]

    if dataset_name:
        cmd_args.extend(["--dataset-name", str(dataset_name)])
    if dataset_path:
        cmd_args.extend(["--dataset-path", str(dataset_path)])
    if request_rate:
        cmd_args.extend(["--request-rate", str(request_rate)])
    if max_concurrency:
        cmd_args.extend(["--max-concurrency", str(max_concurrency)])
    if num_prompts:
        cmd_args.extend(["--num-prompts", str(num_prompts)])
    if input_len:
        cmd_args.extend(["--random-input-len", str(input_len)])
    if output_len:
        cmd_args.extend(["--random-output-len", str(output_len)])
    if random_range_ratio:
        cmd_args.extend(["--random-range-ratio", str(random_range_ratio)])

    result_file = "./bench_log.txt" if not result_file else result_file
    print(f"The metrics result file: {result_file}")

    command = " ".join(cmd_args)
    print(f"command:{command}")
    metrics = run_command(f"{command} | tee {result_file}")
    print(f"metrics is {metrics}")

    result = {}
    for metric_name, grep_pattern, awk_index in [
        ('mean_ttft', 'Mean TTFT', 4),
        ('mean_tpot', 'Mean TPOT', 4),
        ('total_tps', 'Output token throughput', 5)
    ]:
        output = run_command(f"grep '{grep_pattern}' {result_file} | awk '{{print ${awk_index}}}'")
        result[metric_name] = output.strip() if output else None
    return result

def query_master_node_ip() -> str:
    master_node_ip = None
    configmap = query_configmap(CONFIGMAP_NAME, NAMESPACE)
    if configmap and configmap.data:
        for pod_name, ip in configmap.data.items():
            if pod_name.endswith("sglang-node-0"):
                master_node_ip = ip
                break
    if master_node_ip is None:
        print(f"Can not find master node in configmap: {configmap.data if configmap else 'None'}")

    return master_node_ip

def check_configmap_ready():
    while True:
        configmap = query_configmap(CONFIGMAP_NAME, NAMESPACE)
        if not (configmap and configmap.data and query_master_node_ip()):
            print(f"configmap is not ready, wait for 15s ......")
            time.sleep(15)
        else:
            print(f"monitor configmap.data: {configmap.data}")
            break

# launch node
def launch_node(config):
    print(f"launch_node start ......")
    node_ip = os.getenv("POD_IP")
    hostname = os.getenv("HOSTNAME")
    if not node_ip:
        raise ValueError("POD_IP environment variable not set")
    if not hostname:
        raise ValueError("HOSTNAME environment variable not set")
    
    try:
        pod_index = int(hostname.rsplit("-", 1)[-1])
    except (ValueError, IndexError) as e:
        raise ValueError(f"Invalid hostname format: {hostname}") from e

    # monitor configmap to generate dist-init-addr and node-rank
    check_configmap_ready()
    dist_init_addr = None
    master_node_ip = query_master_node_ip()
    if not master_node_ip:
        raise RuntimeError("Failed to get master node IP")
    dist_init_addr = f"{master_node_ip}:5000"
    print(f"launch_node dist_init_addr: {dist_init_addr}")

    special_args = [
        "--dist-init-addr", dist_init_addr,
        "--node-rank", str(pod_index),
    ]
    other_args = config["other_args"]
    other_args.extend(special_args)

    for key, value in config["node_envs"].items():
        print(f"ENV_VAR {key}: {value}")
        os.environ[key] = value
    
    print(f"Starting node, {node_ip=} {other_args=}")
    return popen_launch_server(
        config["model_path"],
        f"http://{node_ip}:{SERVICE_PORT}",
        timeout=LOCAL_TIMEOUT,
        other_args=other_args,
    )

def start_server(model_config: dict) -> threading.Thread:
    sglang_thread = threading.Thread(
        target=launch_node, 
        args=(model_config,),
        daemon=True,
    )
    sglang_thread.start()
    return sglang_thread

def wait_server_ready(url: str, timeout: int = LOCAL_TIMEOUT) -> None:
    print(f"Waiting for the server to start... url={url}")
    start_time = time.perf_counter()
    while True:
        try:
            response = requests.get(url, timeout=5)
            if response.status_code == 200:
                print(f"Server {url} is ready!")
                return
        except requests.RequestException as e:
            print(f"Server not ready yet: {e}. Retrying...")
        except Exception as e:
            print(f"Unexpected error: {e}. Retrying...")

        if time.perf_counter() - start_time > timeout:
            raise RuntimeError(f"Server {url} failed to start in {timeout}s")
        time.sleep(10)
