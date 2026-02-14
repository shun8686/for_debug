sglang_source_path=/data/d00662834/0104_dev/sglang
image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.5-a3-release20260121"
#image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:main-cann8.3.rc1-a3"

install_sglang_from_source=false

test_case=test/registered/ascend/performance/test_ascend_qwen3_32b_bf16_4p_in6k_out1k5_17_9ms.py
npu_num=8
echo "==========${test_case}==============="
nohup bash run_single_base.sh ${sglang_source_path} ${test_case} ${npu_num} ${image} ${install_sglang_from_source} > log/${test_case##*/}.log 2>&1 &

test_case=test/registered/ascend/performance/test_ascend_qwen3_32b_bf16_4p_in4k_out1k5_11ms.py
npu_num=8
echo "==========${test_case}==============="
nohup bash run_single_base.sh ${sglang_source_path} ${test_case} ${npu_num} ${image} ${install_sglang_from_source} > log/${test_case##*/}.log 2>&1 &

