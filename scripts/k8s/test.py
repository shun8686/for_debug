import os
from kubernetes import client, config

def get_pods_info(namespace, search_string):
	config.load_kube_config(os.environ.get('KUBECONFIG'))
	v1 = client.CoreV1Api()
	pods = v1.list_namespaced_pod(namespace=namespace)
	matching_pods = []

	for pod in pods.items:
		if search_string in pod.metadata.name:
			ip = pod.status.pod_ip
			matching_pods.append((pod.metadata.name, ip))
	return matching_pods

namespace = 'kube-system'
search_string = 'mindx'
pods_info = get_pods_info(namespace, search_string)
for name, ip in pods_info:
	print(f"Pod Name: {name}, IP: {ip}")

