#!/bin/bash
# Installing Rancher on kind k8s cluster on debian

## Install Docker
sudo apt-get -qq update
sudo apt-get -qq -y install ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get -qq -y update
sudo apt-get -qq -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker vagrant


## Install kind
curl -sLo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

## Install helm
curl -s https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get -qq -y install apt-transport-https
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get -qq -y update
sudo apt-get -qq -y install helm

## Install kubectl
sudo apt-get -qq -y install kubernetes-client

## Create kind cluster with extra paths.
kind create cluster --name=rancher --config=/vagrant/cluster.yaml
mkdir -p /home/vagrant/.kube
chown vagrant:vagrant /home/vagrant/.kube
kind get kubeconfig --name=rancher > /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config 
chmod 600 /home/vagrant/.kube/config


## Install nginx
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
sleep 30s;
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=600s

## Install cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl create namespace cert-manager
helm install cert-manager jetstack/cert-manager \
      --namespace cert-manager \
      --version v1.15.1 \
      --set crds.enabled=true
sleep 10s;
kubectl  wait --for=condition=Available apiservice v1.cert-manager.io --timeout=600s

 ## Install Rancher
 helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
 helm repo update
 kubectl create namespace cattle-system
 helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set hostname=rancher.192-168-31-81.sslip.io \
  --set bootstrapPassword=admin \
  --set replicas=1 \
  --version=2.8.5 \
  --set global.cattle.psp.enabled=false

# Install Harbor registry
helm repo add harbor https://helm.goharbor.io
helm repo update
kubectl create namespace harbor
helm install harbor harbor/harbor \
  --version=1.15.0 \
  --namespace harbor \
  --set expose.ingress.hosts.core=harbor.192-168-31-81.sslip.io


# View on web browser
echo "Installation finished!"
echo ""
echo "Access rancher via WEB browser http://192.168.31.81/"
echo "bootstrapPassword: admin"
echo "Change rancher admin password, create API token for terraform"
echo ""
echo "Harbor access: https://harbor.192-168-31-81.sslip.io"
echo "Harbor user: admin"
echo "Harbor password: Harbor12345"
echo ""