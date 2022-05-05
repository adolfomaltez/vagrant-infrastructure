#!/bin/bash

# Netbox Installation 
# https://docs.netbox.dev/en/stable/

# Install proxy certificate
# vagrant scp proxy.crt default:
# cp -rp /home/vagrant/proxy.crt /usr/local/share/ca-certificates/
cp -rp /vagrant/proxy.crt /usr/local/share/ca-certificates/
update-ca-certificates



# Install Ansible
apt-get -y update
apt-get -y install software-properties-common

# Install required packages
apt-get -y update
apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release net-tools openssl
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install docker and docker-compose
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
apt-get install -y docker-compose

# Clone Netbox
cd /opt
git config --global http.sslVerify false
git config --global http.postBuffer 1048576000 
git clone https://github.com/netbox-community/netbox-docker.git /opt/netbox
cd /opt/netbox
docker-compose build
sed -e 's/8000/80/g' /opt/netbox/docker-compose.override.yml.example  > /opt/netbox/docker-compose.override.yml
docker-compose up -d
echo ""
echo "Web browser http://192.168.33.40/"
echo "user: admin"
echo "password: admin"
echo ""

