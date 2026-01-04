#!/bin/bash

sglang_source_path=$1
test_set_file=$2
image=$3

if [ "$#" -lt 3 ];then
  echo "Param num is less than 3. Exit."
  exit 1
fi

echo "===========================MULTI-NODE=================================="
MAX_THREADS=1

SCRIPT_PATH=$(dirname $(readlink -f $0))
cd $SCRIPT_PATH

test_set=`cat ${test_set_file}`
for tc_info in ${test_set}
do
    node_size=$(echo $tc_info | cut -d'|' -f1)
    test_case=$(echo $tc_info | cut -d'|' -f2)
    while true
    do
        p_num=$(ps -ef | grep "bash run_multi_pd_mix_base.sh " | grep -v grep | wc -l)
        if ([ ${p_num} -lt ${MAX_THREADS} ]);then
            break
        fi
        sleep 60
    done
    echo "testcase : ${test_case}"
    nohup bash run_multi_pd_mix_base.sh ${sglang_source_path} ${test_case} ${node_size} ${image} > log/${test_case##*/}.log 2>&1 &
    sleep 5
done

# check result
while true
do
    p_num=$(ps -ef | grep "bash run_multi_pd_mix_base.sh " | grep -v grep | wc -l)
    if ([ ${p_num} -eq 0 ]);then
        break
    fi
    sleep 60
done

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
