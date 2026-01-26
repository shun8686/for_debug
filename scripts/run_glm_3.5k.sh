sglang_source_path=/data/d00662834/0104_dev/sglang
test_case=test/registered/ascend/performance/test_ascend_glm4.6_w8a8_16p_in3k2_out1k_50ms.py
node_size=2

sh run_multi_pd_mix_base.sh ${sglang_source_path} ${test_case} ${node_size}
