export KUBECONFIG=/data/.cache/kb.yaml

match_str="sglang-single-debug"

kubectl get pods -A -o wide | grep ${match_str}
