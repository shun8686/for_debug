#!/bin/bash
source ~/.bashrc

sglang_source_path=/data/d00662834/0104_dev/sglang
#export PYTHONPATH=$sglang_source_path/python:$PYTHONPATH
#image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.3.rc2-a3-release20260112"
image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.5-a3-release20260113"
#image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:main-cann8.3.rc1-a3"

SCRIPT_PATH=$(dirname $(readlink -f $0))
cd $SCRIPT_PATH

case_type=$1
run_failed_case=$2
test_set_tail=""
if [ -n "$run_failed_case" ];then
    test_set_tail=".failed"
fi

function pd_test() {
    bash batch_run_pd.sh ${sglang_source_path} testcase_pd_all${test_set_tail} ${image} 2>&1
}

function multi_test() {
    bash batch_run_multi.sh ${sglang_source_path} testcase_multi_all${test_set_tail} ${image} 2>&1
}


function single_test() {
    bash batch_run_single.sh ${sglang_source_path} testcase_single_all${test_set_tail} ${image} 2>&1
}

case "$case_type" in
    pd)
        pd_test
    ;;
    m)
        multi_test
    ;;
    s)
        single_test
    ;;
    *)
        pd_test
        multi_test
        single_test
    ;;
esac

