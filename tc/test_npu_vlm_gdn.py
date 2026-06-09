import unittest

from sglang.test.ascend.gsm8k_ascend_mixin import GSM8KAscendMixin
from sglang.test.ascend.test_ascend_utils import QWEN3_5_9B_WEIGHTS_PATH
from sglang.test.ci.ci_register import register_npu_ci
from sglang.test.test_utils import CustomTestCase

register_npu_ci(est_time=400, suite="nightly-1-npu-a3", nightly=True)


class TestVlmGdnEnabledMultimodal(GSM8KAscendMixin, CustomTestCase):
    """Testcase: Verify Qwen3.5-9B (GDN hybrid linear attention) GSM8K accuracy >= 0.35 while enabled multimodal on NPU.

    [Test Category] VLM + GDN
    [Test Target] VLM + GDN hybrid linear attention + Ascend NPU
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
        "--enable-multimodal",
        "--mm-attention-backend",
        "ascend_attn",
        "--mamba-ssm-dtype",
        "bfloat16",
    ]


if __name__ == "__main__":
    unittest.main()
