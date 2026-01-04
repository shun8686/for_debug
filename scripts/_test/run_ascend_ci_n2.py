import yaml
import re
import signal
import subprocess
import sys
import time
import os

from kubernetes import client, config
from kubernetes.client.rest import ApiException

config.load_kube_config(os.environ.get('KUBECONFIG'))
v1 = client.CoreV1Api()

LOCAL_TIMEOUT = 10800
KUBE_NAME_SPACE = os.environ.get('NAMESPACE')
KUBE_CONFIG_MAP = os.environ.get('KUBE_CONFIG_MAP')
KUBE_JOB_TYPE = os.environ.get('KUBE_JOB_TYPE')
MONITOR_POD_NAME = "{}-sglang-router-0".format(os.environ.get('KUBE_JOB_NAME')) if KUBE_JOB_TYPE != "single" else \
    "{}-pod-0".format(os.environ.get('KUBE_JOB_NAME'))
SINGLE_NODE_YAML = "test.yaml"
MULTI_NODE_YAML = "deepep.yaml"

def run_command(cmd, shell=True):
    try:
        result = subprocess.run(
            cmd, shell=shell, capture_output=True, text=True, check=True
        )
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"execute command error: {e}")
        return None

def create_pod(yaml_file_path, namespace):
    with open(yaml_file_path, "r", encoding="utf-8") as f:
        pod_yaml = yaml.safe_load(f)
    
    print(f"Begin to create pod. Namespace:{namespace}, yaml: {yaml_file_path}")
    try:
        response = v1.create_namespaced_pod(
            namespace=namespace,
            body=pod_yaml
        )
        print(f"Pod create successfully! Pod name: {response.metadata.name}")
        print(f"Pod Status: {response.status.phase}")
        return response
    
    except ApiException as e:
        print(f"Pod create failed! Error info: {e.reason}")
        print(f"Error details: {e.body}")
        raise

if __name__ == "__main__":    
    print("apply k8s yaml... KUBE_NAME_SPACE:{}, KUBE_CONFIG_MAP:{}, KUBE_JOB_TYPE:{}"
          .format(KUBE_NAME_SPACE, KUBE_CONFIG_MAP, KUBE_JOB_TYPE))
    
    k8s_yaml = SINGLE_NODE_YAML if KUBE_JOB_TYPE == "single" else MULTI_NODE_YAML
    result = run_command("kubectl apply -f {}".format(k8s_yaml))
    if result:
        print(result)
#    responese = create_pod(k8s_yaml, KUBE_NAME_SPACE)

#    if responese:
#        print(responese)


