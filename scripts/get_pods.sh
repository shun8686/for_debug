export KUBECONFIG=/data/.cache/kb.yaml

match_str1="sglang-multi-debug"
match_str2="sglang-single-debug"

kubectl get pods -A -o wide | grep -E "${match_str1}|${match_str2}"
