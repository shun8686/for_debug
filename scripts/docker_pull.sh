for server in $(cat server.list | grep -v "#");do
  echo "=========${server}=========="
  ssh root@$server "docker pull swr.cn-southwest-2.myhuaweicloud.com/base_image/dockerhub/lmsysorg/sglang:cann8.3.rc2-a3-release1230"
done
