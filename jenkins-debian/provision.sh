#!/bin/bash

echo "Installing utilities"
sudo apt-get -qq update
sudo apt-get -qq install -y gpg curl net-tools git ca-certificates curl

echo "Installing Docker"
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get -qq install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose
sudo usermod -aG docker vagrant
sudo usermod -aG docker jenkins

echo "Adding jenkins keys"
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "Updating apt-get"
sudo apt-get -qq update && sudo apt-get -qq upgrade

echo "Installing default-java"
sudo apt-get -y -q install fontconfig openjdk-17-jre

echo "Installing jenkins"  
sudo apt-get -y install jenkins

echo "Skipping the initial setup"
echo 'JAVA_ARGS="-Djenkins.install.runSetupWizard=false"' | sudo tee -a /etc/default/jenkins > /dev/null

echo "Setting up users"
sudo rm -rf /var/lib/jenkins/init.groovy.d
sudo mkdir /var/lib/jenkins/init.groovy.d
sudo cp -v /vagrant/01_globalMatrixAuthorizationStrategy.groovy /var/lib/jenkins/init.groovy.d/
sudo cp -v /vagrant/02_createAdminUser.groovy /var/lib/jenkins/init.groovy.d/

sudo service jenkins start
sleep 1m

echo "Installing jenkins plugins"
JENKINSPWD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
rm -f jenkins_cli.jar.*
wget -q http://localhost:8080/jnlpJars/jenkins-cli.jar
while IFS= read -r line
do
  list=$list' '$line
done < /vagrant/jenkins-plugins.txt
java -jar ./jenkins-cli.jar -auth admin:$JENKINSPWD -s http://localhost:8080 install-plugin $list

echo "Restarting Jenkins"
sudo service jenkins restart

sleep 1m
