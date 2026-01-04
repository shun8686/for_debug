export KUBECONFIG=/data/.cache/kb.yaml

namespace="sglang-single-debug"
pod=$1

kubectl exec -it -n ${namespace} ${pod} -- df -h /dev/shm 
