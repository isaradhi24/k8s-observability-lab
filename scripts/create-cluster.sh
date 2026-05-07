#!/bin/bash

set -e
BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

CLUSTER_NAME="devops-lab"

echo "Creating KIND Cluster..."

if kind get clusters | grep -q "${CLUSTER_NAME}"; then
  echo "Cluster ${CLUSTER_NAME} already exists."
  kubectl get nodes --context kind-${CLUSTER_NAME}
   exit 0 
else
  kind create cluster \
    --name ${CLUSTER_NAME} \
    --config ${BASE_DIR}/kind/kind-multi.yaml
  echo "Cluster ${CLUSTER_NAME} Created"
fi

kubectl get nodes