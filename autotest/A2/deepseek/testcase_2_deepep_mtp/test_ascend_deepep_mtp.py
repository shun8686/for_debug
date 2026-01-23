import unittest
import os
import time

from types import SimpleNamespace
from sglang.test.few_shot_gsm8k import run_eval as run_gsm8k # type: ignore
from sglang.test.test_utils import CustomTestCase # type: ignore


class TestDeepseekR1(CustomTestCase):

    @classmethod
    def setUpClass(cls):
        cls.role = "master"

    def test_deepseek_r1(self):
      
        master_node_ip = "127.0.0.1"
        server_port = "6688"
        url = f"http://{master_node_ip}:{server_port}" + "/health"
        args = SimpleNamespace(
            num_shots=5,
            data_path=None,
            num_questions=200,
            max_new_tokens=512,
            parallel=128,
            host=f"http://{master_node_ip}",
            port=int(server_port),
        )

        metrics = run_gsm8k(args)
        print(f"metrics is : {metrics}")
        self.assertGreaterEqual(
            metrics["accuracy"],
            0.95,
        )

if __name__ == "__main__":
    unittest.main()
