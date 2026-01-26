SCRIPT_PATH=$(dirname $(readlink -f $0))
cd ${SCRIPT_PATH}
for server in $(cat server.list | grep -v "#");do
  echo "=========${server}=========="
  ssh root@$server "pkill -9 python"
  ssh root@$server "pkill -9 sglang"

  ssh root@$server "lsof -t -i :6677 | xargs -r kill -9"
  ssh root@$server "lsof -t -i :6688 | xargs -r kill -9"
done
