import os
os.environ['HF_ENDPOINT'] = 'https://hf-mirror.com'
from huggingface_hub import snapshot_download

model_path = './'
snapshot_download(
        repo_id="Zjcxy-SmartAI/Eagle3-Qwen3-32B-zh",
        local_dir=model_path,
        max_workers=8
)
