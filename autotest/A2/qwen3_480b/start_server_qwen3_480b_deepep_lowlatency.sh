#pkill -9 python | pkill -9 sglang
#pkill -9 sglang

MODEL_PATH=/data/ascend-ci-share-pkking-sglang/modelscope/hub/models/Qwen3-Coder-480B-A35B-Instruct-w8a8-QuaRot
NIC_NAME=enp189s0f0
NODE_IP=('80.48.37.205' '80.48.37.132')

echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
sysctl -w vm.swappiness=0
sysctl -w kernel.numa_balancing=0
sysctl -w kernel.sched_migration_cost_ns=50000

# 设置PYTHONPATH
#cd /home/chenxu/sglang
#export PYTHONPATH=${PWD}/python:$PYTHONPATH

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

export SGLANG_SET_CPU_AFFINITY=1
export PYTORCH_NPU_ALLOC_CONF=expandable_segments:True
export SGLANG_DISAGGREGATION_BOOTSTRAP_TIMEOUT=600
export HCCL_BUFFSIZE=2100
export HCCL_SOCKET_IFNAME=$NIC_NAME
export GLOO_SOCKET_IFNAME=$NIC_NAME
export HCCL_OP_EXPANSION_MODE=AIV

LOCAL_HOST1=`hostname -I|awk -F " " '{print$1}'`
LOCAL_HOST2=`hostname -I|awk -F " " '{print$2}'`

echo "${LOCAL_HOST1}"
echo "${LOCAL_HOST2}"


for i in "${!NODE_IP[@]}";
do
    if [[ "$LOCAL_HOST1" == "${NODE_IP[$i]}" || "$LOCAL_HOST2" == "${NODE_IP[$i]}" ]];
    then
        echo "${NODE_IP[$i]}"
        NODE_RANK=$i
        python -m sglang.launch_server \
            --model-path ${MODEL_PATH} \
            --host ${NODE_IP[$i]} --port 8001 --trust-remote-code \
            --nnodes 2 --node-rank $NODE_RANK \
            --dist-init-addr ${NODE_IP[0]}:5000 \
            --attention-backend ascend --device npu --quantization modelslim \
            --max-running-requests 96 \
            --context-length 8192 \
            --dtype bfloat16 \
            --chunked-prefill-size 1024 \
            --max-prefill-tokens 458880 \
            --disable-radix-cache \
            --moe-a2a-backend deepep --deepep-mode low_latency \
            --tp-size 8 --dp-size 4 \
            --enable-dp-attention  \
            --enable-dp-lm-head \
            --mem-fraction-static 0.7 \
            --cuda-graph-bs 16 20 24 
        break
    fi
done




