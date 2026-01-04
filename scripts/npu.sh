for server in $(cat server.list | grep -v "#");do
  echo "=========${server}=========="
  ssh root@$server "npu-smi info"
done
