import unittest
import os
import time

from types import SimpleNamespace
from test_ascend_multi_mix_utils import NIC_NAME, SERVICE_PORT, start_server, wait_server_ready
from sglang.test.few_shot_gsm8k import run_eval as run_eval_few_shot_gsm8k # type: ignore
from sglang.test.test_utils import CustomTestCase # type: ignore

MODEL_PATH = "/root/.cache/modelscope/hub/models/vllm-ascend/DeepSeek-R1-0528-W8A8"

MODEL_CONFIG = {
    "model_path": MODEL_PATH,
    "node_envs": {
        "SGLANG_SET_CPU_AFFINITY": "1",
        "PYTORCH_NPU_ALLOC_CONF": "expandable_segments:True",
        "SGLANG_DISAGGREGATION_BOOTSTRAP_TIMEOUT": "600",
        "HCCL_SOCKET_IFNAME": NIC_NAME,
        "GLOO_SOCKET_IFNAME": NIC_NAME,
        "HCCL_BUFFSIZE": "1024",
        "SGLANG_NPU_USE_MLAPO": "1",
        "SGLANG_ENABLE_OVERLAP_PLAN_STREAM": "1",
        "SGLANG_ENABLE_SPEC_V2": "1",
    },
    "other_args": [
        "--trust-remote-code",
        "--nnodes",
        "2",
        "--attention-backend",
        "ascend",
        "--device",
        "npu",
        "--quantization",
        "modelslim",
        "--mem-fraction-static",
        "0.8",
        "--disable-radix-cache",
        "--chunked-prefill-size",
        "32768",
        "--disable-cuda-graph",
        "--tp-size",
        "16",
        "--speculative-algorithm",
        "NEXTN",
        "--speculative-num-steps",
        "1",
        "--speculative-eagle-topk",
        "1",
        "--speculative-num-draft-tokens",
        "2",
    ]
}

class TestDeepseekR1(CustomTestCase):
    @classmethod
    def setUpClass(cls):
        cls.model_config = MODEL_CONFIG
        cls.local_ip = os.getenv("POD_IP")
        hostname = os.getenv("HOSTNAME")
        cls.role = "master" if hostname.endswith("sglang-node-0") else "worker"
        print(f"Init {cls.local_ip} {cls.role=}!")

    def test_a_gsm8k(self):
        print("Starting server...")
        start_server(self.model_config)
        if self.role == "master":
            master_node_ip = os.getenv("POD_IP")
            url = f"http://{master_node_ip}:{SERVICE_PORT}" + "/health"
            wait_server_ready(url)
            args = SimpleNamespace(
                num_shots=5,
                data_path=None,
                num_questions=1319,
                max_new_tokens=512,
                parallel=128,
                host=f"http://{master_node_ip}",
                port=int(SERVICE_PORT),
            )

            metrics = run_eval_few_shot_gsm8k(args)
            print(f"metrics is : {metrics}")
            self.assertGreaterEqual(
                metrics["accuracy"],
                0.95,
            )
        else:
            print("The worker node is ready!")
            time.sleep(3600)


if __name__ == "__main__":
    unittest.main()
