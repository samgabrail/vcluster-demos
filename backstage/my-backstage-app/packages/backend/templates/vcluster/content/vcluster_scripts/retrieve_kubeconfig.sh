#!/usr/bin/bash

VCLUSTER_NAME=$1
ORIGINAL_KUBECONFIG_BASE64=$2

mkdir -p ~/.kube
touch ~/.kube/config

# Define the path to the kubeconfig file
KUBECONFIG_PATH=~/.kube/config

# Decode the original kubeconfig from GitHub Secret
echo $ORIGINAL_KUBECONFIG_BASE64 | base64 -d > $KUBECONFIG_PATH

# Install vCluster
curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/download/v0.19.5/vcluster-linux-amd64" && sudo install -c -m 0755 vcluster /usr/local/bin && rm -f vcluster

vcluster connect ${VCLUSTER_NAME} --update-current=false --server=https://${VCLUSTER_NAME}.tekanaid.com

# Base64 encode the kubeconfig file at ./kubeconfig.yaml
VCLUSTER_KUBECONFIG_BASE64=$(cat ./kubeconfig.yaml | base64 -w 0)

# Cleanup
unset ORIGINAL_KUBECONFIG_BASE64

# Provide the kubeconfig path to the user
echo "vCluster has been set up. Kubeconfig for the vCluster is available at $KUBECONFIG_PATH"