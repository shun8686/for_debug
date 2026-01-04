export KUBECONFIG=/data/.cache/kb.yaml

kubectl get nodes --show-labels | grep "nodestatus=debug"

