import unittest
import os
import time

from types import SimpleNamespace
from test_ascend_multi_mix_utils import TestMultiMixUtils
from test_ascend_multi_mix_utils import NIC_NAME, SERVICE_PORT
from sglang.test.few_shot_gsm8k import run_eval as run_eval_few_shot_gsm8k


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
        "SGLANG_DEEPEP_NUM_MAX_DISPATCH_TOKENS_PER_RANK": "32",
        "SGLANG_NPU_USE_MLAPO": "1",
        "SGLANG_NPU_USE_EINSUM_MM": "1",
        "HCCL_INTRA_PCIE_ENABLE": "1",
        "HCCL_INTRA_ROCE_ENABLE": "0",
        "ASCEND_MF_TRANSFER_PROTOCOL": "device_rdma",
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
        "--max-running-requests",
        "32",
        "--disable-radix-cache",
        "--chunked-prefill-size",
        "32768",
        "--disable-cuda-graph",
        "--tp",
        "16",
        "--dp-size",
        "1",
        "--ep-size",
        "16",
        "--moe-a2a-backend",
        "deepep",
        "--deepep-mode",
        "auto",
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

class TestDeepseekR1(TestMultiMixUtils):
    model_config = MODEL_CONFIG

    def test_deepseek_r1(self):
        self.start_server()
        if self.role == "master":
            master_node_ip = os.getenv("POD_IP")
            args = SimpleNamespace(
                num_shots=5,
                data_path=None,
                num_questions=200,
                max_new_tokens=512,
                parallel=128,
                host=f"http://{master_node_ip}",
                port=int(SERVICE_PORT),
            )

            metrics = run_eval_few_shot_gsm8k(args)
            self.assertGreaterEqual(
                metrics["accuracy"],
                0.95,
            )
        else:
            time.sleep(3600)


if __name__ == "__main__":
    unittest.main()
