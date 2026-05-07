#!/bin/bash

set -e

cd ~

echo "Installing Helm..."

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "Helm Installed Successfully"

helm version