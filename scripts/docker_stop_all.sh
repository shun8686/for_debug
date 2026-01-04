for server in $(cat server.list | grep -v "#");do
  echo "=========${server}=========="
  ssh root@$server "docker stop $(docker ps | grep sglang | awk '{print $1}')"
done
