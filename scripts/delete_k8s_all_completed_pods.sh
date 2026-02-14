export KUBECONFIG=/data/.cache/kb.yaml

#NAMESPACE=sglang-single-debug
NAMESPACE=sglang-multi-debug

kubectl get pods -n ${NAMESPACE} | grep "Completed"

kubectl get pods -n ${NAMESPACE} | grep "Completed" | awk '{print $1}' | xargs kubectl delete pod -n ${NAMESPACE}

kubectl get pods -n ${NAMESPACE} | grep "Completed"
