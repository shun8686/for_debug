# MemFabric Adaptor
pip install mf-adapter==1.0.0


```shell
PYTORCH_VERSION=2.6.0
TORCHVISION_VERSION=0.21.0
TORCH_NPU_VERSION=2.6.0.post3
pip install torch==$PYTORCH_VERSION torchvision==$TORCHVISION_VERSION --index-url https://download.pytorch.org/whl/cpu
pip install torch_npu==$TORCH_NPU_VERSION
```

While there is no resleased versions of 'torch_npu' for 'torch==2.7.1' and 'torch==2.8.0' we provide custom builds of 'torch_npu'. PLATFORM can be 'aarch64' or '
x86_64'

```shell
PLATFORM="aarch64"
PYTORCH_VERSION=2.8.0
TORCHVISION_VERSION=0.23.0
pip install torch==$PYTORCH_VERSION torchvision==$TORCHVISION_VERSION --index-url https://download.pytorch.org/whl/cpu
wget https://sglang-ascend.obs.cn-east-3.myhuaweicloud.com/sglang/torch_npu/torch_npu-${PYTORCH_VERSION}.post2.dev20251120-cp311-cp311-manylinux_2_28_${PLATFORM}
.whl
pip install torch_npu-${PYTORCH_VERSION}.post2.dev20251120-cp311-cp311-manylinux_2_28_${PLATFORM}.whl
```

If you are using other versions of 'torch' install 'torch_npu' from sources, check [installation guide](https://github.com/Ascend/pytorch/blob/master/README.md)

#### Triton on Ascend

We provide our own implementation of Triton for Ascend.

```shell
BISHENG_NAME="Ascend-BiSheng-toolkit_aarch64_20251121.run"
BISHENG_URL="https://sglang-ascend.obs.cn-east-3.myhuaweicloud.com/sglang/triton_ascend/${BISHENG_NAME}"
wget -O "${BISHENG_NAME}" "${BISHENG_URL}" && chmod a+x "${BISHENG_NAME}" && "./${BISHENG_NAME}" --install && rm "${BISHENG_NAME}"
```
```shell
pip install triton-ascend==3.2.0rc4






#### CustomOps
_TODO: to be removed once merged into sgl-kernel-npu._
Additional package with custom operations. DEVICE_TYPE can be "a3" for Atlas A3 server or "910b" for Atlas A2 server.

```shell
DEVICE_TYPE="a3"
wget https://sglang-ascend.obs.cn-east-3.myhuaweicloud.com/ops/CANN-custom_ops-8.2.0.0-$DEVICE_TYPE-linux.aarch64.run
chmod a+x ./CANN-custom_ops-8.2.0.0-$DEVICE_TYPE-linux.aarch64.run
./CANN-custom_ops-8.2.0.0-$DEVICE_TYPE-linux.aarch64.run --quiet --install-path=/usr/local/Ascend/ascend-toolkit/latest/opp
wget https://sglang-ascend.obs.cn-east-3.myhuaweicloud.com/ops/custom_ops-1.0.$DEVICE_TYPE-cp311-cp311-linux_aarch64.whl
pip install ./custom_ops-1.0.$DEVICE_TYPE-cp311-cp311-linux_aarch64.whl
```

#### Installing SGLang from source

```shell
# Use the last release branch
git clone -b v0.5.6.post2 https://github.com/sgl-project/sglang.git
cd sglang
mv python/pyproject_other.toml python/pyproject.toml
pip install -e python[srt_npu]


