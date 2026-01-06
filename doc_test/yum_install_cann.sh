sudo curl https://repo.oepkgs.net/ascend/cann/ascend.repo -o /etc/yum.repos.d/ascend.repo && yum makecache

# install toolkit
sudo yum install -y Ascend-cann-toolkit

source /usr/local/Ascend/ascend-toolkit/set_env.sh

# install kernels
sudo yum install -y Atlas-A3-cann-kernels

# install nnal
sudo yum install -y Ascend-cann-nnal

# set envs
source /usr/local/Ascend/nnal/atb/set_env.sh
source /usr/local/Ascend/nnal/asdsip/set_env.sh
