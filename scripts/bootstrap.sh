#!/bin/bash

set -e

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

echo "Creating KIND Cluster..."
./scripts/create-cluster.sh

echo "Installing Metrics Server..."
./scripts/install-metrics-server.sh

echo "Installing Monitoring Stack..."
./scripts/install-monitoring.sh

echo "Done"