sglang_source_path=/data/d00662834/0104_dev/sglang
image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.5-a3-release20260115"
#image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.3.rc2-a3-release20260114"
#image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:main-cann8.3.rc1-a3"

test_case=test/registered/ascend/features/deepep/test_ascend_deepep_auto_qwen3_480b_multi_node.py
node_size=2
echo "==========${test_case}==============="
bash run_multi_pd_mix_base.sh ${sglang_source_path} ${test_case} ${node_size} ${image} > log/${test_case##*/}.log 2>&1


