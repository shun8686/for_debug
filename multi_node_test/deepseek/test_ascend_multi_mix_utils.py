import os
import subprocess
import time
import requests
import threading
import psutil
import socket

from kubernetes import client, config
from kubernetes.client.rest import ApiException
from sglang.test.test_utils import (
    CustomTestCase,
    popen_launch_server,
)


KUBE_CONFIG = os.environ.get('KUBECONFIG')
NAMESPACE = os.environ.get('NAMESPACE')
CONFIGMAP_NAME = os.environ.get('KUBE_CONFIG_MAP')
LOCAL_TIMEOUT = 3600
SERVICE_PORT = "6677"

def get_nic_name():
    for nic, addrs in psutil.net_if_addrs().items():
        for addr in addrs:
            if addr.family == socket.AF_INET and (addr.address.startswith("172.") or addr.address.startswith("192.")):
                print("The nic name matched is {}".format(nic))
                return nic
    return None

NIC_NAME = "lo" if get_nic_name() == None else get_nic_name()

config.load_kube_config(KUBE_CONFIG)
v1 = client.CoreV1Api()

# query configmap
def query_configmap(name, namespace):
    try:
        configmap = v1.read_namespaced_config_map(name, namespace)
        print(f"query_configmap successfully!")
        return configmap
    except ApiException as e:
        print(f"query_configmap error {e=}")
        return None

def run_command(cmd, shell=True):
    try:
        result = subprocess.run(
            cmd, shell=shell, capture_output=True, text=True, check=False
        )
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"command error: {e}")
        return None
    
def run_bench_serving(host, port, model_path=None, dataset_name=None, request_rate=None, max_concurrency=None, num_prompts=None, input_len=None, output_len=None,
                      random_range_ratio=1, dataset_path=None, result_file=None):
    dataset_configs = (f"--dataset-name {dataset_name}")
    request_configs = "" if request_rate==None else (f"--request-rate {request_rate}")
    random_configs = (f"--random-input-len {input_len} --random-output-len {output_len} --random-range-ratio {random_range_ratio}")
    if dataset_name == "gsm8k":
        dataset_configs = (f"{dataset_configs} --dataset-path {dataset_path}")
        random_configs = (f"--random-input-len {input_len} --random-output-len {output_len}")

    command = (f"python3 -m sglang.bench_serving --backend sglang --model {model_path} --host {host} --port {port} {dataset_configs} {request_configs} "
               f"--max-concurrency {max_concurrency} --num-prompts {num_prompts} {random_configs}")

    result_file = "./bench_log.txt" if not result_file else result_file
    print(f"The metrics result file: {result_file}")

    print(f"command:{command}")
    metrics = run_command(f"{command} | tee {result_file}")
    print("metrics is " + str(metrics))
    mean_ttft = run_command(
        "grep 'Mean TTFT' " + result_file + " | awk '{print $4}'"
    )
    mean_tpot = run_command(
        "grep 'Mean TPOT' " + result_file + " | awk '{print $4}'"
    )
    total_tps = run_command(
        "grep 'Output token throughput' " + result_file + " | awk '{print $5}'"
    )
    result = {
        'mean_ttft': mean_ttft,
        'mean_tpot': mean_tpot,
        'total_tps': total_tps
    }
    return result

# launch node
def launch_node(config):
    print(f"launch_node start ......")
    node_ip = os.getenv("POD_IP")
    hostname = os.getenv("HOSTNAME")
    pod_index = int(hostname.rsplit("-", 1)[-1])

    # monitor configmap to generate dist-init-addr and node-rank
    isReady = False
    dist_init_addr = None
    while not isReady:
        configmap = query_configmap(CONFIGMAP_NAME, NAMESPACE)
        if configmap.data == None:
            print(f"configmap is None, wait for 15s ......")
            time.sleep(15)
            continue
        print(f"monitor {configmap.data=}")

        master_node_ip = None
        for pod_name in configmap.data:
            if pod_name.endswith("sglang-node-0"):
                master_node_ip = configmap.data[pod_name]
                break
        if master_node_ip == None:
            print(f"Can not find master node in configmap: {configmap.data=}")
            continue

        dist_init_addr = f"{master_node_ip}:5000"
        print(f"launch_node {dist_init_addr=}")
        isReady = True

    special_args = [
        "--dist-init-addr",
        dist_init_addr,
        "--node-rank",
        pod_index,
    ]
    other_args = config["other_args"]
    for sa in special_args:
            other_args.append(sa)

    for key, value in config["node_envs"].items():
        print(f"ENV_VAR {key}:{value}")
        os.environ[key] = value
    
    print(f"Starting node, {node_ip=} {other_args=}")
    return popen_launch_server(
        config["model_path"],
        f"http://{node_ip}:{SERVICE_PORT}",
        timeout=LOCAL_TIMEOUT,
        other_args=[
            *other_args,
        ],
    )

def wait_server_ready(url, timeout=LOCAL_TIMEOUT):
    print(f"Waiting for the server to start...")
    start_time = time.perf_counter()
    while True:
        try:
            response = requests.get(url)
            if response.status_code == 200:
                print(f"Server {url} is ready!")
                return
        except Exception:
            pass

        if time.perf_counter() - start_time > timeout:
            raise RuntimeError(f"Server {url} failed to start in {timeout}s")
        time.sleep(10)

class TestMultiMixUtils(CustomTestCase):

    @classmethod
    def setUpClass(cls):
        cls.local_ip = os.getenv("POD_IP")
        hostname = os.getenv("HOSTNAME")
        cls.role = "master" if hostname.endswith("sglang-node-0") else "worker"
        print(f"Init {cls.local_ip} {cls.role=}!")

    def start_server(self):
        sglang_thread = threading.Thread(
            target=launch_node, args=(self.model_config,)
        )
        sglang_thread.start()

