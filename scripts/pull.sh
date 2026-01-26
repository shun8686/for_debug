image="swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.5-a3-release20260119"

for server in $(cat server.list | grep -v "#");do
  echo "=========${server}=========="
  ssh root@$server "docker pull $image"
done
