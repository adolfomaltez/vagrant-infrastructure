# Install k3s on Alma8 machine

# Copy all the needed k3s binaries and files (airgap-image) to the vagrant box
sudo mkdir -p /var/lib/rancher/k3s/agent/images/
sudo mkdir -p /var/lib/rancher/k3s/server/manifests/
sudo cp /vagrant/k3s /usr/local/bin/
sudo cp /vagrant/k3s-airgap-images-amd64.tar /var/lib/rancher/k3s/agent/images/
sudo cp /vagrant/antrea.yaml /var/lib/rancher/k3s/server/manifests/
sudo chmod +x /vagrant/install.sh
sudo chmod +x /usr/local/bin/k3s

## Install k3s single server (default CNI)
#INSTALL_K3S_SKIP_DOWNLOAD=true /vagrant/install.sh
#sudo chmod +r /etc/rancher/k3s/k3s.yaml

## Install k3s single server + Antrea CNI
INSTALL_K3S_SKIP_DOWNLOAD=true /vagrant/install.sh --flannel-backend=none --disable-network-policy
sudo chmod +r /etc/rancher/k3s/k3s.yaml
