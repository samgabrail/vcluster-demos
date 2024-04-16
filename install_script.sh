# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
 
# Install Crossplane
helm repo add crossplane-stable \
    https://charts.crossplane.io/stable
helm repo update
helm upgrade --install crossplane crossplane-stable/crossplane \
    --namespace crossplane-system --create-namespace --wait

cd ./crossplane
kubectl apply -f ./providers/
kubectl wait --for=condition=healthy provider.pkg.crossplane.io \
    --all --timeout=300s

sleep 5

kubectl apply -f ./provider-configs/
kubectl apply -f xrds.yaml
kubectl apply -f compositions.yaml

# Install Backstage
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add backstage https://backstage.github.io/charts
kubectl create ns backstage

