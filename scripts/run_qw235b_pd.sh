sglang_source_path=/data/d00662834/0104_dev/sglang
image=swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.5-a3-release20260121
#image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:main-cann8.3.rc1-a3"

test_case=test/registered/ascend/performance/test_ascend_qwen3_235b_w8a8_1p1d_24p_in3k5_out1k5_50ms.py
prefill_size=1
decode_size=2
echo "==========${test_case}==============="
sh run_pd_separation_base.sh ${sglang_source_path} ${test_case} ${prefill_size} ${decode_size} ${image} > log/${test_case##*/}.log 2>&1


