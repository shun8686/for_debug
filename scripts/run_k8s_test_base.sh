#!/bin/bash

sglang_source_path=$1
test_case=$2
image=$3
install_sglang_from_source=$4
kube_job_type=$5

date
share_disk_root_path=/data/ascend-ci-share-pkking-sglang
perf_test_path=${sglang_source_path}/python/sglang/test/ascend/e2e

export PATH=/usr/local/bin:$PATH
export KUBECONFIG=${share_disk_root_path}/.cache/kb.yaml

NAMESPACE=sgl-project
KUBE_JOB_NAME_MULTI=sglang-multi-debug
KUBE_JOB_NAME_SINGLE=sglang-single-debug

prefill_size=0
decode_size=0
router_size=0
node_size=0
npu_size=0

if [ -z "$kube_job_type" ];then
  echo "Param kube_job_type is needed!"
  exit 1
fi
if [ "$kube_job_type" = "multi-pd-separation" ];then
  prefill_size=$6
  decode_size=$7
  router_size=1
  if [ "$#" -lt 7 ];then
    echo "Param num is less than 7. Exit."
    exit 1
  fi
fi
if [ "$kube_job_type" = "multi-pd-mix" ];then
  node_size=$6
  if [ "$#" -lt 6 ];then
    echo "Param num is less than 6. Exit."
    exit 1
  fi
fi
if [ "$kube_job_type" = "single" ];then
  npu_size=$6
  if [ "$#" -lt 6 ];then
    echo "Param num is less than 6. Exit."
    exit 1
  fi
fi

env=debug
if [ -n "$ASCEND_ENV_TYPE" ];then
  env=$ASCEND_ENV_TYPE
  echo "env: $env"
fi

echo "image: ${image}"
echo "install_sglang_from_source: ${install_sglang_from_source}"

SCRIPT_PATH=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
echo "Run path: ${SCRIPT_PATH}"
cd ${sglang_source_path}
git pull
cd ${SCRIPT_PATH}

if [ ! -f ${sglang_source_path}/${test_case} ]; then
  echo "Testcase file is not exist: ${sglang_source_path}/${test_case}"
  exit 1
fi

pip3 install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple kubernetes

current_date=$(date +%Y%m%d)
tc_name=${test_case##*/}
tc_name=${tc_name%.*}
tag_info=$(echo "$image" | cut -d: -f2)
test_data_output_path=${share_disk_root_path}/d00662834/metrics/${tag_info}/${current_date}
mkdir -p ${test_data_output_path}
metrics_data_file=${test_data_output_path}/${tc_name}.txt

cd ${SCRIPT_PATH}

prefix=${share_disk_root_path}/
sglang_source_relative_path=${sglang_source_path#${prefix}}

CMD=(
python3 -u ${perf_test_path}/run_ascend_ci.py
--image $image
--sglang-source-relative-path $sglang_source_relative_path
--metrics-data-file $metrics_data_file
--test-case $test_case
--kube-name-space $NAMESPACE
--kube-job-type $kube_job_type
--env $env
)

if [ "$kube_job_type" = "multi-pd-separation" ];then
  CMD+=(
    --prefill-size $prefill_size
    --decode-size $decode_size
    --router-size $router_size
    --kube-job-name $KUBE_JOB_NAME_MULTI 
  )
fi
if [ "$kube_job_type" = "multi-pd-mix" ];then
  CMD+=(
    --node-size $node_size
    --kube-job-name $KUBE_JOB_NAME_MULTI
  )
fi
if [ "$kube_job_type" = "single" ];then
  CMD+=(
    --npu-size $npu_size
    --kube-job-name $KUBE_JOB_NAME_SINGLE
  )
fi

if [ "$install_sglang_from_source" = "true" ] || [ "$install_sglang_from_source" = "True" ];then
  CMD+=(--install_sglang_from_source)
fi

echo "Run command: ${CMD[*]}"
eval "${CMD[*]}"

if [ -f ${metrics_data_file} ];then
  sed -i "1i\Image: ${image}" ${metrics_data_file}
fi
