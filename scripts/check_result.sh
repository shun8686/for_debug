#!/bin/bash

test_set_file=$1

if [ "$#" -lt 1 ];then
  echo "Param num is less than 1. Exit."
  exit 1
fi

SCRIPT_PATH=$(dirname $(readlink -f $0))
cd $SCRIPT_PATH

# check result
failed_test_cases=${test_set_file}.failed
> ${failed_test_cases}
test_set=`cat ${test_set_file}`
for tc_info in ${test_set}
do
    test_case=$(echo $tc_info | cut -d'|' -f2)
    result=$(cat log/${test_case##*/}.log | grep "Serving Benchmark Result" | wc -l)
    if [ ${result} -lt 2 ];then
        echo "${tc_info}" >> ${failed_test_cases}
    fi
done


