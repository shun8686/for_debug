# ===========modify start====================
sglang_source_path="/data/l30079981/pr/sglang"
test_case="test/srt/ascend_k8s/test_ascend_Qwen3_235B_w8a8_2p2d_in3500_out1500.py"
prefill_size=2
decode_size=2
router_size=1
image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:main-cann8.3.rc1-a3"
# ===========modify end======================

export KUBECONFIG=/data/.cache/kb.yaml
export NAMESPACE=sglang-multi-debug
export KUBE_JOB_NAME=sglang-multi-debug
export KUBE_JOB_TYPE=multi
export KUBE_CONFIG_MAP=sglang-info
echo "KUBE_JOB_NAME: $KUBE_JOB_NAME"
SCRIPT_PATH=$(dirname $(readlink -f $0))

pip3 install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple jinja2-cli

echo "{ \"image\": $image,\
	\"name_space\": \"$NAMESPACE\",\
	\"kube_job_name\": \"$KUBE_JOB_NAME\",\
	\"kube_config\": \"$KUBECONFIG\",\
	\"kube_config_map\": \"$KUBE_CONFIG_MAP\",\
	\"prefill_size\": $prefill_size,\
	\"decode_size\": $decode_size,\
	\"router_size\": $router_size,\
	\"sglang_source_path\": \"$sglang_source_path\",\
	\"test_case\": \"$test_case\" }"|\
    jinja2 ${SCRIPT_PATH}/deepep.yaml.jinja2 -o ${SCRIPT_PATH}/deepep.yaml

cd ${SCRIPT_PATH}
python3 -u run_ascend_ci.py


