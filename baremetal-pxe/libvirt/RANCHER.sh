# Install Rancher on kind k8s cluster

## Variables:
USER=vagrant
HOSTNAME=192-168-10-13.sslip.io

# docker
echo 'Installing docker ...';
sudo apt-get update
sudo apt-get -y install ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get -y update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker $USER


# kind
echo 'Installing kind ...'
curl -Lo /home/vagrant/kind https://kind.sigs.k8s.io/dl/v0.18.0/kind-linux-amd64
chmod +x /home/vagrant/kind
sudo mv /home/vagrant/kind /usr/local/bin/kind

# helm
echo 'Installing helm ...'
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get -y install apt-transport-https
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get -y install helm

# kubectl
echo 'Installing kubectl ...'
sudo apt-get -y install kubernetes-client


# Create kind cluster with extra paths.
echo 'Creating kind cluster ...'
kind create cluster --name=rancher --config=/home/vagrant/cluster.yaml

## Apply CRDs: nginx, cert-manager
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

## Install cert-manager (helm)
### Apply CRDs
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.2/cert-manager.crds.yaml

### Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io

### Update your local Helm chart repository cache
helm repo update


### Install the cert-manager Helm chart
kubectl create namespace cert-manager
helm install cert-manager jetstack/cert-manager \
      --namespace cert-manager \
      --version v1.12.2

## Install Rancher
echo 'Installing Rancher ...'

### Add the Rancher Helm repository
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable

### Update your local Helm chart repository cache
helm repo update

echo "Wait 5 minutes for nginx ..."
sleep 5m;

### Create namespace
kubectl create namespace cattle-system

### Install the Rancher Helm chart
helm install rancher rancher-stable/rancher \
  --wait --timeout 30m \
  --namespace cattle-system \
  --set hostname=$HOSTNAME \
  --set bootstrapPassword=admin \
  --set replicas=1 \
  --version=2.7.5 \
  --set global.cattle.psp.enabled=false


### Alternative: letsEncrypt certificate
#helm install rancher rancher-stable/rancher \
#  --namespace cattle-system \
#  --set hostname=rancher.192-168-10-12.sslip.io \
#  --set bootstrapPassword=admin \
#  --set replicas=1 \
#  --version=2.7.4 \
#  --set global.cattle.psp.enabled=false \
#  --set ingress.tls.source=letsEncrypt \
#  --set letsEncrypt.email=user@mail.net \
#  --set letsEncrypt.ingress.class=nginx


## Some commands for kind to load docker image on kind
#docker pull rancher/fleet-agent:v0.7.0
#kind load docker-image rancher/fleet-agent:v0.7.0 --name rancher --nodes rancher-control-plane

## Create rancher API token

echo "Rancher is installed!"
echo "Now, you have to manually change Rancher admin password and create API token!"
echo "Wait for Rancher to be ready on: https://$HOSTNAME/"

### References:
#- https://docs.docker.com/engine/install/debian/#install-using-the-repository
#- https://kind.sigs.k8s.io/docs/user/quick-start/
#- https://kind.sigs.k8s.io/docs/user/quick-start/#installation
#- https://kind.sigs.k8s.io/docs/user/ingress/#ingress-nginx
#- https://ranchermanager.docs.rancher.com/pages-for-subheaders/install-upgrade-on-a-kubernetes-cluster