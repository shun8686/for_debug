#!/bin/bash

sglang_source_path=$1
test_case=$2
npu_num=$3
image=$4
debug=$5

SCRIPT_PATH=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
echo "Run path: ${SCRIPT_PATH}"
cd ${sglang_source_path}
git pull
cd ${SCRIPT_PATH}

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

pip3 install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple kubernetes
pip3 install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple jinja2-cli
whereis jinja2
echo $PATH

current_date=$(date +%Y%m%d)
tc_name=${test_case##*/}
tc_name=${tc_name%.*}
test_data_output_path=/data/d00662834/metrics/${current_date}
mkdir -p ${test_data_output_path}
metrics_data_file=${test_data_output_path}/${tc_name}.txt

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

if [ -f ${metrics_data_file} ];then
  sed -i "1i\Image: ${image}" ${metrics_data_file}
fi

if [ -z "${debug}" ];then
  sleep 10
  kubectl delete -f ${SCRIPT_PATH}/${KUBE_YAML_FILE}
  if [ -n "$(echo "${KUBE_YAML_FILE}" | grep -v '/')" ];then
    cd ${SCRIPT_PATH}
    rm -rf ${KUBE_YAML_FILE}
  fi
  sleep 10
fi
