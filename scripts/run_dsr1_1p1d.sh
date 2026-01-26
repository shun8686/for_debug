sglang_source_path=/data/d00662834/0104_dev/sglang

image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.5-a3-release20260119_post2"
#image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.3.rc2-a3-release20260112"
#image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:main-cann8.3.rc1-a3"


test_case=test/registered/ascend/performance/test_ascend_deepseek_r1_w4a8_1p1d_16p_in2k_out2k_50ms.py
prefill_size=1
decode_size=1
echo "==========${test_case}==============="
bash run_pd_separation_base.sh ${sglang_source_path} ${test_case} ${prefill_size} ${decode_size} ${image} > log/${test_case##*/}.log 2>&1

