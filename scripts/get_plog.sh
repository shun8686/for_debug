export KUBECONFIG=/data/.cache/kb.yaml

namespace=sglang-multi-debug
pod_name_prefix=sglang-multi-debug-sglang

plog_path=/data/d00662834/debug/plog

pod_name=$1
pod=${pod_name}

case "$pod_name" in
    p|p0)
	pod=${pod_name_prefix}-prefill-0
    ;;
    p1)
	pod=${pod_name_prefix}-prefill-1
    ;;
    d|d0)
        pod=${pod_name_prefix}-decode-0
    ;;
    d1)
	pod=${pod_name_prefix}-decode-1
    ;;
    n|n0)
        pod=${pod_name_prefix}-node-0
    n1)
	pod=${pod_name_prefix}-node-1
    ;;
    *)
	namespace=sglang-single-debug
	pod=${pod_name}
    ;;
esac

target_path=${plog_path}/${pod}
mkdir -p ${target_path}
rm -rf ${target_path}/*.log
kubectl cp ${namespace}/${pod}:/root/ascend/log/debug/plog ${target_path}
