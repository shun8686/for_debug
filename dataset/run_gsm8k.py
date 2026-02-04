import ssl
from types import SimpleNamespace
from sglang.test.few_shot_gsm8k import run_eval as run_gsm8k # type: ignore

ssl._create_default_https_context = ssl._create_unverified_context

hots="127.0.0.1"
port=6688

args = SimpleNamespace(
    num_shots=5,
    data_path=None,
    num_questions=200,
    max_new_tokens=512,
    parallel=128,
    host=f"http://{host}",
    port=int(port),
)
metrics = run_gsm8k(args)
print(metrics)