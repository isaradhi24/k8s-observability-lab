#!/bin/bash

set -e

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

echo "Installing Monitoring Stack..."

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

kubectl apply -f ${BASE_DIR}/monitoring/namespace.yaml

helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f ${BASE_DIR}/monitoring/kube-prom-stack-values.yaml

echo "Monitoring Stack Installed"