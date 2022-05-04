#copy zscaler certificate
cp proxy.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust

yum --enablerepo=updates clean metadata
yum -y update

# install ntop.org repo
# https://packages.ntop.org/centos-stable/
curl https://packages.ntop.org/centos/ntop.repo > /etc/yum.repos.d/ntop.repo
yum -y install epel-release
yum -y clean all
yum -y update
#yum install pfring-dkms n2disk nprobe ntopng cento
yum -y install nprobe

# Configure network
ip link set eth1 up
ip addr add 192.168.33.11/24 dev eth1
#ip addr add 192.168.33.12/24 dev eth1

# Configure nprobe
echo "-i eth1" >> /etc/nprobe/nprobe.conf
echo "--zmq tcp://192.168.33.10:5556"  >> /etc/nprobe/nprobe.conf
echo "--zmq-probe-mode" >> /etc/nprobe/nprobe.conf

# Start nprobe
systemctl start nprobe

