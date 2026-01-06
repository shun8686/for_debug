conda config --add channels https://repo.huaweicloud.com/ascend/repos/conda/

conda list | grep ascend-toolkit

conda search ascend::cann-toolkit

# install toolkit

conda install ascend::cann-toolkit

source /root/anaconda3/envs/sglang/Ascend/ascend-toolkit/set_env.sh

conda list | grep cann

# install kernels

conda install ascend::a3-cann-kernels

# install nnal

conda install ascend::cann-nnal

source /root/anaconda3/envs/sglang/Ascend/nnal/atb/set_env.sh

source /root/anaconda3/envs/sglang/Ascend/nnal/asdsip/set_env.sh

conda list | grep cann
