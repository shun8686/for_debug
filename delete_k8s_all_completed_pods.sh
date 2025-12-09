export KUBECONFIG=/data/.cache/kb.yaml
export NAMESPACE=sglang-single-debug

kubectl get pods -n ${NAMESPACE} | grep "Completed"

kubectl get pods -n ${NAMESPACE} | grep "Completed" | awk '{print $1}' | xargs kubectl delete pod -n ${NAMESPACE}

kubectl get pods -n ${NAMESPACE} | grep "Completed"
