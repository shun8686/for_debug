#pkill -9 python | pkill -9 sglang
echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
sysctl -w vm.swappiness=0
sysctl -w kernel.numa_balancing=0
sysctl -w kernel.sched_migration_cost_ns=50000

export SGLANG_SET_CPU_AFFINITY=1
# 设置PYTHONPATH

#export PYTHONPATH=${PWD}/python:$PYTHONPATH
unset https_proxy
unset http_proxy
unset HTTPS_PROXY
unset HTTP_PROXY
unset ASCEND_LAUNCH_BLOCKING

source /usr/local/Ascend/ascend-toolkit/set_env.sh
source /usr/local/Ascend/nnal/atb/set_env.sh
source /usr/local/Ascend/ascend-toolkit/latest/opp/vendors/customize/bin/set_env.bash
source /usr/local/Ascend/8.5.0/bisheng_toolkit/set_env.sh

MODEL_PATH=/home/weights/vllm-ascend/DeepSeek-R1-0528-W8A8

export PYTORCH_NPU_ALLOC_CONF=expandable_segments:True
export SGLANG_DISAGGREGATION_BOOTSTRAP_TIMEOUT=600

LOCAL_HOST1=`hostname -I|awk -F " " '{print$1}'`
LOCAL_HOST2=`hostname -I|awk -F " " '{print$2}'`

echo "${LOCAL_HOST1}"
echo "${LOCAL_HOST2}"
export HCCL_SOCKET_IFNAME=enp189s0f0
export GLOO_SOCKET_IFNAME=enp189s0f0

export HCCL_BUFFSIZE=1024
export SGLANG_NPU_USE_MLAPO=1
export SGLANG_ENABLE_OVERLAP_PLAN_STREAM=1
export SGLANG_ENABLE_SPEC_V2=1

NODE_RANK=0

python -m sglang.launch_server --model-path $MODEL_PATH \
        --host 127.0.0.1 --port 6688 --trust-remote-code --nnodes 2 --node-rank $NODE_RANK  \
        --dist-init-addr 61.47.16.106:5000 \
        --attention-backend ascend --device npu --quantization modelslim  \
        --mem-fraction-static 0.8 --disable-radix-cache \
        --chunked-prefill-size 32768 --disable-cuda-graph \
        --tp-size 16 \
        --speculative-algorithm NEXTN \
        --speculative-num-steps 1 --speculative-eagle-topk 1 --speculative-num-draft-tokens 2


exit 1
python -m sglang.bench_serving --dataset-name random --backend sglang --host 127.0.0.1 --port 7439 --max-concurrency 480 --random-input-len 2048 --random-output-len 2048 --num-prompts 480 --random-range-ratio 1
