#!/bin/bash

set -e

CLUSTER_NAME="devops-lab"

echo "Deleting KIND cluster..."

kind delete cluster --name ${CLUSTER_NAME}

echo "Cluster deleted"