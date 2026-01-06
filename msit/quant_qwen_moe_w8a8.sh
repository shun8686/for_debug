cd msit/msmodelslim/example/Qwen3-MOE
python3 quant_qwen_moe_w8a8.py --model_path /data/d00662834/models/Qwen3-30B-A3B \
	--save_path /data/d00662834/models/Qwen3-30B-A3B-w8a8 \
	--anti_dataset ../common/qwen3-moe_anti_prompt_50.json \
	--calib_dataset ../common/qwen3-moe_calib_prompt_50.json \
	--trust_remote_code True

