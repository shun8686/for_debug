sglang_source_path=/data/d00662834/0104_dev/sglang
image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.3.rc2-a3-release20260108"
#image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:main-cann8.3.rc1-a3"


for ((i=1;i<=10;i++));do

test_case=test/manual/ascend/performance/test_ascend_deepseek_r1_w8a8_2p1d_32p_in3k5_out1k_20ms.py
prefill_size=2
decode_size=2
echo "==========${test_case}==============="
bash run_pd_separation_base.sh ${sglang_source_path} ${test_case} ${prefill_size} ${decode_size} ${image} > log/loop/${test_case##*/}_${i}.log 2>&1

test_case=test/manual/ascend/performance/test_ascend_deepseek_r1_w8a8_2p1d_32p_in3k5_out1k5_20ms.py
prefill_size=2
decode_size=2
echo "==========${test_case}==============="
bash run_pd_separation_base.sh ${sglang_source_path} ${test_case} ${prefill_size} ${decode_size} ${image}  > log/loop/${test_case##*/}_${i}.log 2>&1

done
