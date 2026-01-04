export KUBECONFIG=/data/.cache/kb.yaml
kubectl get pods -A -o wide | grep -E "192.168.0.102|192.168.0.60|192.168.0.234|192.168.0.184|NAMESPACE"

