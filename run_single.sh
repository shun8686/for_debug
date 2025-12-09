# ===========modify start====================
sglang_source_path="/data/d00662834/1206/sglang"
test_case="test/srt/ascend_k8s/test_ascend_qwen3_8b_in1000_out300_bs8.py"
npu_num=4
image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:main-cann8.3.rc1-a3"
# ===========modify end======================

export KUBECONFIG=/data/.cache/kb.yaml
export NAMESPACE=sglang-single-debug
export KUBE_JOB_NAME=sglang-single-$(uuidgen)
export KUBE_JOB_TYPE=single
echo "KUBE_JOB_NAME: $KUBE_JOB_NAME"
SCRIPT_PATH=$(dirname $(readlink -f $0))

pip3 install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple jinja2-cli

echo "{ \"image\": $image,\
	\"name_space\": \"$NAMESPACE\",\
	\"kube_job_name\": \"$KUBE_JOB_NAME\",\
	\"kube_config\": \"$KUBECONFIG\",\
	\"sglang_source_path\": \"$sglang_source_path\",\
	\"test_case\": \"$test_case\",\
	\"npu_num\": $npu_num }"|\
    jinja2 ${SCRIPT_PATH}/k8s_single.yaml.jinja2 -o ${SCRIPT_PATH}/k8s_single.yaml

cd ${SCRIPT_PATH}
python3 -u run_ascend_ci.py
