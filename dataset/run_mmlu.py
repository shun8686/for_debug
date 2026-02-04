import ssl
from types import SimpleNamespace
from sglang.test.run_eval import run_eval

ssl._create_default_https_context = ssl._create_unverified_context

base_url="http://127.0.0.1:6688"
model="/mnt/share/weights/DeepSeek-V3.2-W8A8"

args = SimpleNamespace(
    base_url=base_url,
    model=model,
    eval_name="mmlu",
    num_examples=128,
    num_threads=32,
    thinking_mode="deepseek-v3",
#   repeat=5
)
metrics = run_eval(args)
print(metrics)