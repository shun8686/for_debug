#!/bin/bash
source ~/.bashrc

sglang_source_path=/data/ascend-ci-share-pkking-sglang/d00662834/dev-0210/sglang
install_sglang_from_source=false

image=swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.5.0-a3-B025
#image=swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:v0.5.6-ascend-a3
#image=swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.5-a3-release20260121
#image=swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.3.rc2-a3-release20260112
#image=swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:main-cann8.3.rc1-a3

SCRIPT_PATH=$(dirname $(readlink -f $0))
cd $SCRIPT_PATH
rm -rf log/*.log

case_type=$1
run_failed_case=$2
test_set_tail=""
if [ -n "$run_failed_case" ];then
    test_set_tail=".failed"
fi

# set k8s node label for full execution
if [ "${case_type}" == "all" ];then
    cat server.list.perf > server.list
    bash update_k8s_label.sh
fi

# clean env
bash ${SCRIPT_PATH}/pkill.sh

function pd_test() {
    bash batch_run_pd_separation.sh ${sglang_source_path} testcase_pd_all${test_set_tail} ${image} ${install_sglang_from_source} 2>&1
}

function pd_test_2node() {
    bash batch_run_pd_separation.sh ${sglang_source_path} testcase_pd_2node${test_set_tail} ${image} ${install_sglang_from_source} 2>&1
}

function multi_test() {
    bash batch_run_pd_mix.sh ${sglang_source_path} testcase_multi_all${test_set_tail} ${image} ${install_sglang_from_source} 2>&1
}

function single_test() {
    bash batch_run_single.sh ${sglang_source_path} testcase_single_all${test_set_tail} ${image} ${install_sglang_from_source} 2>&1
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
    c)
        pd_test
        multi_test
    ;;
    t)
	pd_test_2node
	multi_test
#	single_test
    ;;
    *)
        pd_test
        multi_test
        single_test
    ;;
esac

cat testcase_pd_all.failed > log/testcase.failed
cat testcase_multi_all.failed >> log/testcase.failed
cat testcase_single_all.failed >> log/testcase.failed

cat testcase_pd_all.poor > log/testcase.poor
cat testcase_multi_all.poor >> log/testcase.poor
cat testcase_single_all.poor  >> log/testcase.poor

# backup logs while full execution
if [ "${case_type}" == "all" ];then
    log_new=log_$(date +%Y%m%d)
    mkdir $log_new
    mv log/* $log_new
fi
