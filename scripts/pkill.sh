SCRIPT_PATH=$(dirname $(readlink -f $0))
cd ${SCRIPT_PATH}
for server in $(cat server.list | grep -v "#");do
  echo "=========${server}=========="
  ssh root@$server "pkill python"
  ssh root@$server "pkill sglang"
done
