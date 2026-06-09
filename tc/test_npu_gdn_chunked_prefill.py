import unittest

from sglang.test.ascend.gsm8k_ascend_mixin import GSM8KAscendMixin
from sglang.test.ascend.test_ascend_utils import QWEN3_5_9B_WEIGHTS_PATH
from sglang.test.ci.ci_register import register_npu_ci
from sglang.test.test_utils import CustomTestCase

register_npu_ci(est_time=400, suite="nightly-1-npu-a3", nightly=True)


class TestGDNChunkedPrefillEnabled(GSM8KAscendMixin, CustomTestCase):
    """Testcase: Verify Qwen3.5-9B (GDN hybrid linear attention) GSM8K accuracy >= 0.35
    with chunked prefill enabled (size=128) on NPU.

    This covers the GDN + chunked prefill state-passing path in AscendGDNAttnBackend,
    where SSM recurrent state (last_recurrent_state) is serialized between prefill
    chunks. The chunked prefill path is exercised across the GDN linear attention
    layers (Gated DeltaNet blocks), verifying that multi-chunk state transfer
    produces correct generation output.

    Regression coverage for: PR #25839 and any future changes to
    NPU chunked prefill + hybrid linear attention interaction.

    [Test Category] Memory & Scheduling
    [Test Target] --chunked-prefill-size (GDN hybrid linear attention + Ascend NPU)
    """

    model = QWEN3_5_9B_WEIGHTS_PATH
    accuracy = 0.35
    other_args = [
        "--trust-remote-code",
        "--mem-fraction-static",
        "0.8",
        "--attention-backend",
        "ascend",
        "--disable-cuda-graph",
        "--skip-server-warmup",
        "--chunked-prefill-size",
        "128",
        "--max-running-requests",
        "16",
        "--tp-size",
        "2",
        "--mamba-ssm-dtype",
        "bfloat16",
    ]


class TestGDNChunkedPrefillDisabled(GSM8KAscendMixin, CustomTestCase):
    """Testcase: Verify Qwen3.5-9B (GDN hybrid linear attention) GSM8K accuracy >= 0.35
    with chunked prefill disabled on NPU — serves as the baseline reference for the
    enabled variant to detect chunked prefill induced regressions.

    [Test Category] Memory & Scheduling
    [Test Target] --chunked-prefill-size -1 (GDN hybrid linear attention + Ascend NPU, baseline)
    """

    model = QWEN3_5_9B_WEIGHTS_PATH
    accuracy = 0.35
    other_args = [
        "--trust-remote-code",
        "--mem-fraction-static",
        "0.8",
        "--attention-backend",
        "ascend",
        "--disable-cuda-graph",
        "--skip-server-warmup",
        "--chunked-prefill-size",
        "-1",
        "--max-running-requests",
        "16",
        "--tp-size",
        "2",
        "--mamba-ssm-dtype",
        "bfloat16",
    ]


class TestGDNSimpleAPI(unittest.TestCase):
    """Quick sanity check: send a few prompts to GDN model and inspect responses."""

    @classmethod
    def setUpClass(cls):
        import subprocess
        from sglang.test.test_utils import (
            DEFAULT_TIMEOUT_FOR_SERVER_LAUNCH,
            DEFAULT_URL_FOR_TEST,
            popen_launch_server,
        )
        from sglang.srt.utils import kill_process_tree

        cls.model = QWEN3_5_9B_WEIGHTS_PATH
        cls.base_url = DEFAULT_URL_FOR_TEST
        cls.other_args = [
            "--trust-remote-code",
            "--mem-fraction-static",
            "0.8",
            "--attention-backend",
            "ascend",
            "--disable-cuda-graph",
            "--skip-server-warmup",
            "--max-running-requests",
            "4",
            "--tp-size",
            "2",
            "--mamba-ssm-dtype",
            "bfloat16",
        ]
        cls.process = popen_launch_server(
            cls.model,
            cls.base_url,
            timeout=DEFAULT_TIMEOUT_FOR_SERVER_LAUNCH,
            other_args=cls.other_args,
        )
        cls.server_cmd = subprocess.list2cmdline(cls.process.args)
        print(f"\n[SERVER CMD] {cls.server_cmd}")

    @classmethod
    def tearDownClass(cls):
        from sglang.srt.utils import kill_process_tree
        kill_process_tree(cls.process.pid)

    def _send_request(self, prompt, max_tokens=64):
        import requests
        print(f"\n{'='*60}")
        print(f"[PROMPT] {prompt}")
        res = requests.post(
            f"{self.base_url}/generate",
            json={
                "text": prompt,
                "sampling_params": {
                    "temperature": 0,
                    "max_new_tokens": max_tokens,
                },
            },
            timeout=120,
        )
        assert res.status_code == 200, f"HTTP {res.status_code}: {res.text}"
        data = res.json()
        text = data.get("text", "")
        print(f"[RESPONSE] {text}")
        print(f"[TOKENS] prompt={data.get('meta_info', {}).get('prompt_tokens', '?')}, "
              f"completion={data.get('meta_info', {}).get('completion_tokens', '?')}")
        return text

    def test_simple_qa(self):
        prompts = [
            "What is the capital of France? Answer in one word.",
            "What is 2 + 2? Answer in one word.",
            "How many months are in a year? Answer in one word.",
            "What color is the sky on a clear day? Answer in one word.",
            "What is the chemical symbol for water? Answer in one word.",
        ]
        for prompt in prompts:
            text = self._send_request(prompt, max_tokens=16)
            self.assertIsNotNone(text, f"Empty response for: {prompt}")
            self.assertGreater(len(text.strip()), 0, f"Empty response for: {prompt}")

    def test_longer_reasoning(self):
        prompts = [
            "If a train travels 120 km in 2 hours, what is its average speed in km/h? Explain briefly.",
            "Janet has 3 apples. She buys 5 more. Then she gives 2 to her friend. How many does she have now? Explain briefly.",
        ]
        for prompt in prompts:
            text = self._send_request(prompt, max_tokens=128)
            self.assertIsNotNone(text)
            self.assertGreater(len(text.strip()), 0)


if __name__ == "__main__":
    unittest.main()
