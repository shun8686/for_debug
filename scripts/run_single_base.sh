sglang_source_path=$1
test_case=$2
npu_num=$3
image=$4
debug=$5

if [ "$#" -lt 3 ];then
  echo "Param num is less than 3. Exit."
  exit 1
fi

if [ ! -f ${sglang_source_path}/${test_case} ]; then
  echo "Testcase file is not exist: ${sglang_source_path}/${test_case}"
  exit 1
fi

if [ -z "${image}" ];then
  image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:main-cann8.3.rc1-a3"
fi
echo "image: ${image}"

export KUBECONFIG=/data/.cache/kb.yaml
export NAMESPACE=sglang-single-debug
export KUBE_JOB_NAME=sglang-single-$(uuidgen)
export KUBE_JOB_TYPE=single
export KUBE_YAML_FILE=yaml_${KUBE_JOB_NAME}.yaml

echo "KUBE_JOB_NAME: $KUBE_JOB_NAME"
SCRIPT_PATH=$(dirname $(readlink -f $0))

current_date=$(date +%Y%m%d)
tc_name=${test_case##*/}
tc_name=${tc_name%.*}
test_data_output_path=/data/d00662834/metrics/${current_date}
mkdir -p ${test_data_output_path}
metrics_data_file=/data/d00662834/metrics/${current_date}/${tc_name}.txt

echo "{ \"image\": $image,\
\"name_space\": \"$NAMESPACE\",\
\"kube_job_name\": \"$KUBE_JOB_NAME\",\
\"kube_config\": \"$KUBECONFIG\",\
\"sglang_source_path\": \"$sglang_source_path\",\
\"metrics_data_file\": \"$metrics_data_file\",\
\"test_case\": \"$test_case\",\
\"npu_num\": $npu_num }"|\
    jinja2 ${SCRIPT_PATH}/k8s_single.yaml.jinja2 -o ${SCRIPT_PATH}/${KUBE_YAML_FILE}

cd ${SCRIPT_PATH}
python3 -u run_ascend_ci.py

if [ -z "${debug}" ];then
  kubectl delete -f ${SCRIPT_PATH}/${KUBE_YAML_FILE}
  rm -rf ${SCRIPT_PATH}/${KUBE_YAML_FILE}
  sleep 60
fi
