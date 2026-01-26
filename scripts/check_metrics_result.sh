#!/bin/bash

metrics_path=$1

if [ "$#" -lt 1 ];then
  echo "Param num is less than 1. Exit."
  exit 1
fi

SCRIPT_PATH=$(dirname $(readlink -f $0))
cd $SCRIPT_PATH

# check result
metric_files=`ls ${metrics_path}`
for file in ${metric_files}
do
    result=$(cat ${metrics_path}/${file} | grep "Serving Benchmark Result" | wc -l)
    if [ ${result} -lt 1 ];then
        echo "FAILED: ${file}"
    fi
done


