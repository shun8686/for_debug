export KUBECONFIG=/data/.cache/kb.yaml

match_str="sglang-multi-debug"

kubectl get pods -A -o wide | grep ${match_str}
