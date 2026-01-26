#!/bin/bash

echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
sysctl -w vm.swappiness=0
sysctl -w kernel.numa_balancing=0
sysctl -w kernel.sched_migration_cost_ns=50000

#export PYTHONPATH=$SGLANG_SOURCE_PATH/python:$PYTHONPATH
export SGLANG_SET_CPU_AFFINITY=1

unset https_proxy
unset http_proxy
unset HTTPS_PROXY
unset HTTP_PROXY
unset ASCEND_LAUNCH_BLOCKING

cann_version=$(cat /usr/local/Ascend/ascend-toolkit/latest/aarch64-linux/ascend_toolkit_install.info | grep "^version=")
echo "CANN: ${cann_version}"
if [[ ${cann_version} == version=8.3.* ]];then
    echo "Set env for CANN 8.3"
    source /usr/local/Ascend/ascend-toolkit/set_env.sh
    source /usr/local/Ascend/nnal/atb/set_env.sh
    source /usr/local/Ascend/ascend-toolkit/latest/opp/vendors/customize/bin/set_env.bash
    source /usr/local/Ascend/8.5.0/bisheng_toolkit/set_env.sh
else
    echo "Set env for CANN 8.5"
    source /usr/local/Ascend/cann/set_env.sh
    source /usr/local/Ascend/nnal/atb/set_env.sh
fi


cp /data/ascend-ci-share-pkking-sglang/huggingface/hub/datasets--anon8231489123--ShareGPT_Vicuna_unfiltered/snapshots/192ab2185289094fc556ec8ce5ce1e8e587154ca/ShareGPT_V3_unfiltered_cleaned_split.json /tmp
curl -o /tmp/test.jsonl -L https://gh-proxy.test.osinfra.cn/https://raw.githubusercontent.com/openai/grade-school-math/master/grade_school_math/data/test.jsonl

current_date=$(date +%Y%m%d_%H%M%S)
mkdir -p log
nohup python3 sglang/test/manual/ascend/lts/test_ascend_lts_qwen3_235b_long.py > log/test_ascend_lts_qwen3_235b_long_${current_date}.log 2>&1 &
