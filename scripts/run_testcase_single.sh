sglang_source_path=/data/ascend-ci-share-pkking-sglang/d00662834/dev-0210/sglang
install_sglang_from_source=false
kube_job_type=single

image=swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.5.0-a3-B025
#image=swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:v0.5.6-ascend-a3
#image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.5-a3-release20260121"
#image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:main-cann8.3.rc1-a3"


test_case=test/registered/ascend/performance/test_ascend_qwen3_32b_w8a8_2p_in3k5_out1k5_50ms.py
npu_size=4
echo "==========${test_case}==============="
bash run_k8s_test_base.sh ${sglang_source_path} ${test_case} ${image} ${install_sglang_from_source} ${kube_job_type} ${npu_size} > log/${test_case##*/}.log 2>&1


