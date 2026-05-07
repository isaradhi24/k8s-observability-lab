#!/bin/bash

set -e

echo "Starting Port Forwarding..."

kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring