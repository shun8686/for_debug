export KUBECONFIG=/data/.cache/kb.yaml

#kubectl delete -f k8s_multi_pd_mix.yaml
#kubectl delete -f k8s_multi_pd_separation.yaml

key_word=$1
namespace=sgl-project

key_word=$1
force=$2

if [ -z ${key_word} ];then
    echo "key_word is needed!"
    exit 1
fi

kubectl delete pods $force -n $namespace $(kubectl get pods -n $namespace | grep $key_word | awk '{print $1}')


