sglang_source_path=/data/d00662834/for_debug
test_case=multi_node_test/deepseek/test_ascend_deepseek_mtp.py
node_size=2
image=swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.3.rc2-910b-release1231

bash run_multi_node_test.sh $sglang_source_path $test_case $node_size $image