export KUBECONFIG=/data/.cache/kb.yaml

namespace=sglang-multi-debug
pod_name_prefix=sglang-multi-debug-sglang

pod_name=$1

case "$pod_name" in
    p|p0)
       kubectl logs -f -n ${namespace} ${pod_name_prefix}-prefill-0
    ;;
    p1)
       kubectl logs -f -n ${namespace} ${pod_name_prefix}-prefill-1
    ;;
    d|d0)
       kubectl logs -f -n ${namespace} ${pod_name_prefix}-decode-0
    ;;
    d1)
       kubectl logs -f -n ${namespace} ${pod_name_prefix}-decode-1
    ;;
    r|r0)
       kubectl logs -f -n ${namespace} ${pod_name_prefix}-router-0
    ;;
    n|n0)
       kubectl logs -f -n ${namespace} ${pod_name_prefix}-node-0
    ;;
    n1)
       kubectl logs -f -n ${namespace} ${pod_name_prefix}-node-1
    ;;
    *)
       kubectl logs -f -n sglang-single-debug ${pod_name}
    ;;
esac

