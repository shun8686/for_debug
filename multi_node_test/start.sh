sglang_source_path=/data/d00662834/for_debug
test_case=multi_node_test/test_case_001.py
node_size=2
image=swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.3.rc2-910b-release1225

bash run_multi_node_test.sh $sglang_source_path $test_case $node_size $image