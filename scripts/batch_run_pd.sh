#!/bin/bash

sglang_source_path=$1
test_set_file=$2
image=$3

if [ "$#" -lt 3 ];then
  echo "Param num is less than 3. Exit."
  exit 1
fi

echo "===========================PD-SEPARATION=================================="

SCRIPT_PATH=$(dirname $(readlink -f $0))
cd $SCRIPT_PATH

test_set=`cat ${test_set_file}`
for tc_info in ${test_set}
do
    prefill_size=$(echo $tc_info | cut -d'|' -f1)
    decode_size=$(echo $tc_info | cut -d'|' -f2)
    test_case=$(echo $tc_info | cut -d'|' -f3)
    echo "testcase : ${test_case}"
    echo "bash run_pd_separation_base.sh ${sglang_source_path} ${test_case} ${prefill_size} ${decode_size} ${image} > log/${test_case##*/}.log 2>&1"
    bash run_pd_separation_base.sh ${sglang_source_path} ${test_case} ${prefill_size} ${decode_size} ${image} > log/${test_case##*/}.log 2>&1
done

# check result
failed_test_cases=${test_set_file}.failed
> ${failed_test_cases}
for tc_info in ${test_set}
do
    test_case=$(echo $tc_info | cut -d'|' -f2)
    result=$(cat log/${test_case##*/}.log | grep "Serving Benchmark Result" | wc -l)
    if [ ${result} -lt 2 ];then
        echo "${tc_info}" >> ${failed_test_cases}
    fi
done
