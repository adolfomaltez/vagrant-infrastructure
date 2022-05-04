# Install proxy certificate
vagrant scp proxy.crt default:
cp -rp /home/vagrant/proxy.crt /usr/local/share/ca-certificates/
update-ca-certificates


# Install Ansible
apt-get -y update
apt-get -y install software-properties-common
apt-add-repository -y ppa:ansible/ansible
apt-get -y install ansible

# Install required packages
apt-get -y update
apt-get -y install apt-transport-https ca-certificates curl gnupg lsb-release gnu-tls
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install docker and docker-compose
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
apt-get install -y docker-compose

# Clone AWX repository
git clone https://github.com/ansible/awx.git
cd awx/
git config --global http.postBuffer 1048576000 
git clone -b 17.0.1 https://github.com/ansible/awx.git

# Deploy AWX
KEY=$(openssl rand -hex 32)
cd installer/
nano inventory (edit admin_password=$KEY)
ansible-playbook -i inventory install.yml
