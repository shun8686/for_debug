export KUBECONFIG=/data/.cache/kb.yaml

namespace=$1
pod_name=$2

kubectl logs -f -n ${namespace} ${pod_name}


