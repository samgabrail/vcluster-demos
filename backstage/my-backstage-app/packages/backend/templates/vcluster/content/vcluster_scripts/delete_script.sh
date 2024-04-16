#!/usr/bin/bash

VCLUSTER_NAME=$1
ORIGINAL_KUBECONFIG_BASE64=$2
CF_API_TOKEN=$3
CF_ZONE_ID=$4
TARGET_DOMAIN=$5
WEBHOOK_URL=$6
STUDENT_EMAIL=$7
ACTION=delete

mkdir -p ~/.kube
touch ~/.kube/config

# Define the path to the kubeconfig file
KUBECONFIG_PATH=~/.kube/config

# Decode the original kubeconfig from GitHub Secret
echo $ORIGINAL_KUBECONFIG_BASE64 | base64 -d > $KUBECONFIG_PATH

# Install vCluster
curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/download/v0.19.5/vcluster-linux-amd64" && sudo install -c -m 0755 vcluster /usr/local/bin && rm -f vcluster

vcluster delete ${VCLUSTER_NAME}

# Cleanup
sed "s/<placeholder>/$VCLUSTER_NAME/g" ingress-template.yaml > ingress.yaml
kubectl delete -f ingress.yaml
kubectl delete ns $VCLUSTER_NAME
unset ORIGINAL_KUBECONFIG_BASE64
echo "vCluster has been deleted."

# Delete the DNS Entry in CloudFlare
./deletedns.sh $VCLUSTER_NAME $CF_ZONE_ID $CF_API_TOKEN $TARGET_DOMAIN

# Trigger a webhook to update that the pipeline finished and vcluster is deleted
curl -X POST -H 'Content-Type: application/json' -d '{"STUDENT_EMAIL": "'$STUDENT_EMAIL'", "VCLUSTER_NAME": "'$VCLUSTER_NAME'", "VCLUSTER_KUBECONFIG_BASE64": "'$VCLUSTER_KUBECONFIG_BASE64'", "ACTION": "'$ACTION'"}' $WEBHOOK_URL