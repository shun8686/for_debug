from types import SimpleNamespace
import requests
from sglang.test.few_shot_gsm8k import run_eval
import os

OUTPUT_DIR = "./profiler_dir"

def _start_profile(**kwargs):
    """Start profiling with optional parameters."""
    requests.post(
        f"http://127.0.0.1:6688/start_profile",
        json=kwargs if kwargs else None,
    )
    # self.assertEqual(response.status_code, 200)

def gsm8k():
    #print(f"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
    #_start_profile(start_step="300",num_steps=3)
    #print(f"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
    args = SimpleNamespace(
        num_shots=5,
        data_path="/mnt/share/l00850654/test/GSM8K.jsonl",
        num_questions=100,
        max_new_tokens=512,
        parallel=32,
        host="http://127.0.0.1",
        port=2345,
    )
    print("start")
    # args = SimpleNamespace(
    #     num_shots=5,
    #     data_path=None,
    #     num_questions=200,
    #     max_new_tokens=512,
    #     parallel=128,
    #     host=f"http://{self.base_host}",
    #     port=int(self.lb_port),
    # )

    metrics = run_eval(args)
    print(f"{metrics=}")
    print(f"{metrics['accuracy']=}")
    # self.assertGreater(metrics["accuracy"], 0.7)

    # def test_gsm8k(self):


        # self.assertGreater(metrics["accuracy"], 0.62)
if __name__ == "__main__":
    # os.environ["SGLANG_TORCH_PROFILER_DIR"] = OUTPUT_DIR
    gsm8k()
