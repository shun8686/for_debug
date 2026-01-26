sglang_source_path=/data/d00662834/0104_dev/sglang
image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.5-a3-release20260119_post2"
#image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:main-cann8.3.rc1-a3"

test_case=test/registered/ascend/performance/test_ascend_qwen3_480b_w8a8_8p_in3k5_out1k5_50ms.py
npu_num=16
echo "==========${test_case}==============="
bash run_single_base.sh ${sglang_source_path} ${test_case} ${npu_num} ${image} > log/${test_case##*/}.log 2>&1
