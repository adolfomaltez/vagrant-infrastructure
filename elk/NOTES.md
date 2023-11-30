# ELK server in-place upgrade

Current server:
- Centos 7.8.2004
- 1 usb pendrive for LUKS key
- raid1 nvme disk pair (mdadm)
- 8x disks 8TB each 7200rpm (one mount point per disk)
- Metadata on the same (slow) disk
- 4x ELK instances

Upgrade:
- AlmaLinux 8.7
- 1 usb pendrive for LUKS key
- raid1 nvme disk pair (mdadm)
- 8x disks 8TB each 7200rpm (mdadm raid5 (7+1) single mount point [/mount/d0])
- Metadata on raid1 nvme disks (nested mount?) or (symlinks?) need to try this!
- 4x ELK instances per node




## mdadm Raid5 example

Install packages
```sh
yum install mdadm cryptsetup
```

List disk
```sh
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINT
```

Create a RAID5 with 8 disks (for ELK data)
```sh
mdadm --create --verbose /dev/md0 --level=5 --raid-devices=8 /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg /dev/sdh /dev/sdi /dev/sdj
```

Create a RAID1 with 2 disks (for OS)
```sh
mdadm --create --verbose /dev/md1 --level=1 --raid-devices=2 /dev/sdk /dev/sdl
```


View raid status:
```sh
cat /proc/mdstat
```
Save mdadm configuration:
```sh
mkdir /etc/mdadm
mdadm --detail --scan | tee -a /etc/mdadm/mdadm.conf
```

Create and mount filesystem:
```sh
mkdir -p /mount/crypt
mkdir -p /mount/d0
# Create folder to mount devices
# /mount/crypt for USB pendrive
# /mount/d0 for raid5

# Format raid6 device with XFS
mkfs.xfs /dev/md0
mount /dev/md0 /mount/d0

# check free space
df -h -x devtmpfs -x tmpfs

# update initramfs
update-initramfs -u

# Add filesystem to fstab
echo '/dev/md0 /mount/d0 xfs defaults,nofail,discard 0 0' >> /etc/fstab 
```


Optional Caution Delete a mdadm volume
```sh
mdadm --stop /dev/md0
mdadm --remove /dev/md0
```


Install USB cryptokey
```sh
mkdir -p /mount/crypt
cfdisk /dev/sdb
mkfs.xfs /dev/sdb1
mount /dev/sdb1 /mount/crypt
```

Add USB to fstab
```sh
```




# Install Elasticsearch
```sh
dnf -y install wget java-1.8.0-openjdk.x86_64

java -version
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.9.2-x86_64.rpm

rpm -ivh elasticsearch-7.9.2-x86_64.rpm

vi /etc/elasticsearch/elasticsearch.yml

systemctl enable elasticsearch.service
systemctl start elasticsearch.service
```

# Try Elasticsearch
```sh
curl -X GET 'http://192.168.10.51:9200'
```


# Migrating Centos 7.8 to AlmaLinux 8.7

Upgrade the current Centos 7 system
```sh
yum update
```

Once all upgraded, reboot
```sh
reboot
```

Verify current OS version (Centos 7.9)
```sh
cat /etc/centos-release
```

## Migrate Centos 7 to AlmaLinux 8

Install ELevate
```sh
yum install -y http://repo.almalinux.org/elevate/elevate-release-latest-el7.noarch.rpm
```

Install Leapp
```sh
yum install -y leapp-upgrade leapp-data-almalinux
```

Start pre-upgrade check
```sh 
leapp preupgrade
```

Start upgrade
```sh 
leapp upgrade
```

Reboot
```sh
reboot
```

Check the upgraded version
```sh
cat /etc/redhat-release 
```


# Notes

Block devices missing after the upgrade.
Install following packages:
```sh
dnf -y install elrepo-release
dnf -y install kmod-mptsas
reboot
```


# Upgrade Elasticsearch 7 to 8

# References
[Tutorial Elasticsearch installation on Centos 7](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-elasticsearch-on-centos-7)

[How to migrate Centos7 to AlmaLinux 8: Step-by-step](https://linuxiac.com/centos-7-to-almalinux-8-migration-guide/)


