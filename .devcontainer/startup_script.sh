#!/usr/bin/bash
sudo apt-get update -y

sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> /home/$USER/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
source ~/.bashrc 

echo "✅ brew installed successfully"

brew install derailed/k9s/k9s

sudo apt-get install fzf -y

echo "✅ kubectx, kubens, fzf, homebrew, and k9s installed successfully"

alias k="kubectl"
alias kga="kubectl get all"
alias kgn="kubectl get all --all-namespaces"
alias kdel="kubectl delete"
alias kd="kubectl describe"
alias kg="kubectl get"

echo 'alias k="kubectl"' >> /home/$USER/.bashrc
echo 'alias kga="kubectl get all"' >> /home/$USER/.bashrc
echo 'alias kgn="kubectl get all --all-namespaces"' >> /home/$USER/.bashrc
echo 'alias kdel="kubectl delete"' >> /home/$USER/.bashrc
echo 'alias kd="kubectl describe"' >> /home/$USER/.bashrc
echo 'alias kg="kubectl get"' >> /home/$USER/.bashrc

echo "✅ The following aliases were added:"
echo "alias k=kubectl"
echo "alias kga=kubectl get all"
echo "alias kgn=kubectl get all --all-namespaces"
echo "alias kdel=kubectl delete"
echo "alias kd=kubectl describe"
echo "alias kg=kubectl get"

source ~/.bashrc 
pwd
mkdir -p ~/.kube
touch ~/.kube/config
sudo chmod 600 ~/.kube/config

# Install ArgoCD CLI
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd

# Install ngrok
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list && sudo apt update && sudo apt install ngrok

# Install vcluster
# Install vCluster
curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/download/v0.19.5/vcluster-linux-amd64" && sudo install -c -m 0755 vcluster /usr/local/bin && rm -f vcluster

# Create the vCluster using the unique names
echo "Creating vCluster with name: $VCLUSTER_NAME"

vcluster create ${VCLUSTER_NAME} -n ${VCLUSTER_NAME} --connect=false -f values.yaml

vcluster connect ${VCLUSTER_NAME} --update-current=false --server=https://${VCLUSTER_NAME}.tekanaid.com


# Base64 encode the kubeconfig file at ./kubeconfig.yaml
VCLUSTER_KUBECONFIG_BASE64=$(cat ./kubeconfig.yaml | base64 -w 0)

# Trigger a webhook to update that the pipeline finished and vcluster is created and send over the kubeconfig
curl -X POST -H 'Content-Type: application/json' -d '{"STUDENT_EMAIL": "'$STUDENT_EMAIL'", "VCLUSTER_NAME": "'$VCLUSTER_NAME'", "VCLUSTER_KUBECONFIG_BASE64": "'$VCLUSTER_KUBECONFIG_BASE64'", "ACTION": "'$ACTION'"}' $WEBHOOK_URL

# Cleanup
unset ORIGINAL_KUBECONFIG_BASE64

# Provide the kubeconfig path to the user
echo "vCluster has been set up. Kubeconfig for the vCluster is available at $KUBECONFIG_PATH"