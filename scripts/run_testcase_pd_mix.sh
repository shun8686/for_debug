sglang_source_path=/data/ascend-ci-share-pkking-sglang/d00662834/dev-0210/sglang
install_sglang_from_source=false
kube_job_type=multi-pd-mix

image=swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.5.0-a3-B025
#image=swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:v0.5.6-ascend-a3
#image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.5-a3-release20260121"
#image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.3.rc2-a3-release20260112"
#image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:main-cann8.3.rc1-a3"

test_case=test/manual/ascend/performance/test_ascend_qwen3_235b_w8a8_16p_in2k_out2k_50ms.py
node_size=2
echo "==========${test_case}==============="
bash run_k8s_test_base.sh ${sglang_source_path} ${test_case} ${image} ${install_sglang_from_source} ${kube_job_type} ${node_size} > log/${test_case##*/}.log 2>&1

