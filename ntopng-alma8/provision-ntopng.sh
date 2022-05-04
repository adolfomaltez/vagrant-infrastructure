#copy proxy certificate
cp proxy.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust

# update yum
yum -y update

# install ntop.org repo
# https://packages.ntop.org/centos-stable/
curl https://packages.ntop.org/centos/ntop.repo > /etc/yum.repos.d/ntop.repo
yum -y install epel-release
rpm -ivh http://rpms.remirepo.net/enterprise/remi-release-8.rpm
yum -y install dnf-plugins-core
dnf config-manager --set-enabled powertools
dnf config-manager --set-enabled remi
yum -y clean all
yum -y update

#yum install pfring-dkms n2disk nprobe ntopng cento
yum -y install ntopng

# Configure ntopng
echo "-w=80" >> /etc/ntopng/ntopng.conf
echo "-i tcp://192.168.33.10:5556c" >> /etc/ntopng/ntopng.conf

# Configure network
ip link set enp0s8 up
ip addr add 192.168.33.10/24 dev enp0s8

# Start ntopng
systemctl start redis
systemctl start ntopng

# Pending
# Influxdb
# clickhouse-server