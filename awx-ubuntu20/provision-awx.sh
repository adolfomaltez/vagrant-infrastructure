#!/bin/bash

# Install proxy certificate
# vagrant scp proxy.crt default:
# cp -rp /home/vagrant/proxy.crt /usr/local/share/ca-certificates/
cp -rp /vagrant/proxy.crt /usr/local/share/ca-certificates/
update-ca-certificates


# Install Ansible
apt-get -y update
apt-get -y install software-properties-common
apt-add-repository -y ppa:ansible/ansible
apt-get -y install ansible

# Install required packages
apt-get -y update
apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release gnu-tls openssl
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install docker and docker-compose
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
apt-get install -y docker-compose

# Clone AWX repository
git config --global http.sslVerify false
git config --global http.postBuffer 1048576000 
git clone -b 17.0.1 --depth 1 https://github.com/ansible/awx.git /opt/awx

# Deploy AWX
KEY=$(openssl rand -hex 32)
cd /opt/awx/installer/
echo admin_password=$KEY >> /opt/awx/installer/inventory
ansible-playbook -i inventory install.yml

# Finished
echo "Web browser to http://192.168.33.30"
echo "user: admin" 
echo "password: $KEY"
