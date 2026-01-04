export KUBECONFIG=/data/.cache/kb.yaml

yaml=$1
kubectl delete -f ${yaml}

