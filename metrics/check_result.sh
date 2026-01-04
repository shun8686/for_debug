#!/bin/bash

metrics_path=./20260104
metric_files=`ls ${metrics_path}`
for file in ${metric_files}
do
#    echo ${file}
    result=$(cat ${metrics_path}/${file} | grep "Serving Benchmark Result" | wc -l)
    if [ ${result} -lt 1 ];then
        echo "FAILED: ${metrics_path}/${file}"
    fi
done


