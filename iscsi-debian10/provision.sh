#!/bin/bash
#
# Script for provision iscsi server
# https://www.server-world.info/en/note?os=Debian_11&p=iscsi&f=2
# https://wiki.debian.org/SAN/iSCSI/open-iscsi



sudo apt-get update
sudo apt-get -y install tgt
sudo mkdir /var/lib/iscsi_disks
sudo dd if=/dev/zero of=/var/lib/iscsi_disks/disk01.img count=0 bs=1 seek=10G

sudo touch /etc/tgt/conf.d/target01.conf
sudo chmod o+w /etc/tgt/conf.d/target01.conf
sudo echo \
"<target iqn.2018-02.mylab.net:lun1>
    ## provided devicce as a iSCSI target
    backing-store /var/lib/iscsi_disks/disk01.img
    ## iSCSI Initiator's IQN you allow to connect
    #initiator-name iqn.2018-02.mylab.net:lun1
    ## authentication info ( set anyone you like for \"username\", \"password\" )
    #incominguser username password
</target>" > /etc/tgt/conf.d/target01.conf


sudo apt-get install -y open-iscsi xfsprogs
sudo systemctl restart tgt
sudo iscsiadm -m discovery -t sendtargets -p 192.168.31.94 --login
# cfdisk to partition sdc1
sudo lsblk
sudo mkfs.xfs /dev/sdc
sudo iscsiadm --mode node --targetname iqn.2018-02.mylab.net:lun1 --logout
sudo tgtadm --mode target --op show