from types import SimpleNamespace
from sglang.test.few_shot_gsm8k import run_eval as run_eval_gsm8k # type: ignore

expect_accuracy=0.7
num_shots=8
data_path=None
num_questions=200
max_new_tokens=512
parallel=128

SERVICE_PORT=6677

args = SimpleNamespace(
    num_shots=num_shots,
    data_path=data_path,
    num_questions=num_questions,
    max_new_tokens=max_new_tokens,
    parallel=parallel,
    host="http://127.0.0.1",
    port=SERVICE_PORT,
)
print("Starting gsm8k test...")
metrics = run_eval_gsm8k(args)
print(metrics)