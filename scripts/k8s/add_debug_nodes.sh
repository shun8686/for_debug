export KUBECONFIG=/data/.cache/kb.yaml

# 192.168.0.184
node_name=$1

if [ "$#" -lt 1 ];then
  echo "Param num is less than 1. Exit."
  exit 1
fi

kubectl label node ${node_name} nodestatus=debug

kubectl get nodes --show-labels | grep "nodestatus=debug"
