#!/bin/bash

export KUBECONFIG=/data/.cache/kb.yaml

function add_label() {
    node_name=$1
    kubectl label node ${node_name} nodestatus=debug
}

function delete_label() {
    node_name=$1
    kubectl label node ${node_name} nodestatus-
}

SCRIPT_PATH=$(dirname $(readlink -f $0))
cd ${SCRIPT_PATH}

current_debug_nodes=$(kubectl get nodes --show-labels | grep "nodestatus=debug" | awk '{print $1}')

# add label
for server in $(cat server.list | grep -v "#");do
    already_labeled=false
    for node in ${current_debug_nodes};do
        if [ "${node}" == "${server}" ]; then
            already_labeled=true 
            break
        fi
    done
    if [ "${already_labeled}" != "true" ]; then
        echo "=========Add label: ${server}=========="
        add_label ${server}
    fi
done

# delete label
for server in $(cat server.list | grep "#" | tr -d '#');do
    for node in ${current_debug_nodes};do
        if [ "${node}" == "${server}" ]; then
            echo "=========Delete label: ${server}=========="
            delete_label ${server}
            break
        fi
    done
done

