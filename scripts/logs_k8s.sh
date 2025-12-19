export KUBECONFIG=/data/.cache/kb.yaml

namespace=sglang-multi-debug
pod_name=sglang-multi-debug-sglang-prefill-0

kubectl logs -f -n sglang-multi-debug ${pod_name}
