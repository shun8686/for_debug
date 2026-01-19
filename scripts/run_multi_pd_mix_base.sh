#!/bin/bash

date
export PATH=/usr/local/bin:$PATH

sglang_source_path=$1
test_case=$2
node_size=$3
image=$4
debug=$5

perf_test_path=${sglang_source_path}/test/registered/ascend/performance

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
export NAMESPACE=sglang-multi-debug
export KUBE_JOB_NAME=sglang-multi-debug
export KUBE_JOB_TYPE=multi
export KUBE_CONFIG_MAP=sglang-info
export KUBE_YAML_FILE=k8s_multi.yaml
echo "KUBE_JOB_NAME: $KUBE_JOB_NAME"

pip3 install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple kubernetes
pip3 install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple jinja2-cli

# Clear resources
kubectl delete -f ${SCRIPT_PATH}/${KUBE_YAML_FILE} --ignore-not-found=true || true

pod_name_prefix="${KUBE_JOB_NAME}-sglang"
echo "kube name space: $NAMESPACE, pod name prefix: ${pod_name_prefix}"
while true; do
  if kubectl get po -A -n $NAMESPACE | grep -q "${pod_name_prefix}"; then
    echo "Found exist sglang job, sleeping for 30 seconds..."
    sleep 30
    kubectl get pods | grep "${pod_name_prefix}" | awk '{print $1}' | xargs kubectl delete pod -n $NAMESPACE || true
  else
    echo "No sglang job exist, start test case..."
    break
  fi
done

current_date=$(date +%Y%m%d)
tc_name=${test_case##*/}
tc_name=${tc_name%.*}
tag_info=$(echo "$image" | cut -d: -f2)
test_data_output_path=/data/d00662834/metrics/${tag_info}/${current_date}
mkdir -p ${test_data_output_path}
metrics_data_file=${test_data_output_path}/${tc_name}.txt

echo "{ \"image\": $image,\
	\"name_space\": \"$NAMESPACE\",\
	\"kube_job_name\": \"$KUBE_JOB_NAME\",\
	\"kube_config\": \"$KUBECONFIG\",\
	\"kube_config_map\": \"$KUBE_CONFIG_MAP\",\
	\"node_size\": $node_size,\
	\"sglang_source_path\": \"$sglang_source_path\",\
        \"metrics_data_file\": \"$metrics_data_file\",\
	\"test_case\": \"$test_case\" }"|\
    jinja2 ${SCRIPT_PATH}/k8s_multi.yaml.jinja2 -o ${SCRIPT_PATH}/${KUBE_YAML_FILE}

cd ${SCRIPT_PATH}
python3 -u ${perf_test_path}/run_ascend_ci.py

if [ -f ${metrics_data_file} ];then
  sed -i "1i\Image: ${image}" ${metrics_data_file}
fi

# check result and export logs
result=$(cat ${metrics_data_file} | grep "Serving Benchmark Result" | wc -l)
if [ ${result} -lt 1 ];then
    echo "FAILED: ${tc_name}, exporting logs..."
    for((i=0;i<${node_size};i++))
    do
	pod_name=${pod_name_prefix}-node-${i}
        log_file=log/${tc_name}_node-${i}.log
        kubectl logs -n ${NAMESPACE} ${pod_name} > ${log_file}
    done
fi

if [ -z "${debug}" ];then
  kubectl delete -f ${SCRIPT_PATH}/${KUBE_YAML_FILE}

  while true; do
    if kubectl get po -A -n $NAMESPACE | grep -q "${pod_name_prefix}"; then
      echo "Found exist sglang job, sleeping for 30 seconds..."
      sleep 30
      kubectl get pods | grep "${pod_name_prefix}" | awk '{print $1}' | xargs kubectl delete pod -n $NAMESPACE || true
    else
      echo "No sglang job exist."
      break
    fi
  done

  if [ -n "$(echo "${KUBE_YAML_FILE}" | grep -v '/')" ];then
    cd ${SCRIPT_PATH}
    rm -rf ${KUBE_YAML_FILE}
  fi
fi



