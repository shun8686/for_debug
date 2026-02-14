#!/bin/bash

sglang_source_path=$1
test_set_file=$2
image=$3
install_sglang_from_source=$4

if [ "$#" -lt 4 ];then
  echo "Param num is less than 4. Exit."
  exit 1
fi

run_k8s="bash run_k8s_test_base.sh "

echo "===========================PD-SEPARATION=================================="
KUBE_JOB_TYPE=multi-pd-separation

SCRIPT_PATH=$(dirname $(readlink -f $0))
cd $SCRIPT_PATH

test_set=`cat ${test_set_file}`
for tc_info in ${test_set}
do

    prefill_size=$(echo $tc_info | cut -d'|' -f1)
    decode_size=$(echo $tc_info | cut -d'|' -f2)
    test_case=$(echo $tc_info | cut -d'|' -f3)
    echo "testcase : ${test_case}"
    echo "${run_k8s} ${sglang_source_path} ${test_case} ${image} ${install_sglang_from_source} ${KUBE_JOB_TYPE} ${prefill_size} ${decode_size} > log/${test_case##*/}.log 2>&1"
    ${run_k8s} ${sglang_source_path} ${test_case} ${image} ${install_sglang_from_source} ${KUBE_JOB_TYPE} ${prefill_size} ${decode_size} > log/${test_case##*/}.log 2>&1

    sleep 60
done

# check result

failed_test_cases=${test_set_file}.failed
poor_test_cases=${test_set_file}.poor
> ${failed_test_cases}
> ${poor_test_cases}
for tc_info in ${test_set}
do
    test_case=$(echo $tc_info | cut -d'|' -f3)
    result=$(cat log/${test_case##*/}.log | grep "Serving Benchmark Result" | wc -l)
    ok_num=$(cat log/${test_case##*/}.log | grep "^OK$" | wc -l)
    if [ ${result} -lt 2 ];then
    echo "${tc_info}" >> ${failed_test_cases}
    elif [ "${ok_num}" -ne 1 ];then
	echo "${tc_info}" >> ${poor_test_cases}
    fi
done

