#!/bin/bash

set -e

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

echo "Installing ArgoCD..."

kubectl apply -f ${BASE_DIR}/argocd/namespace.yaml

kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "ArgoCD Installed"