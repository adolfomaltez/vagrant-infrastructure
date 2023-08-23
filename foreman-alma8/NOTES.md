# Install Foreman on Alma8

```sh
dnf -y update
dnf install -y epel-release
dnf install -y https://yum.puppet.com/puppet6-release-el-8.noarch.rpm
dnf module -y reset ruby
dnf module -y enable ruby:2.7
dnf install -y https://yum.theforeman.org/releases/2.5/el8/x86_64/foreman-release.rpm
dnf -y update
dnf install -y foreman-installer

ln -s /boot/efi/EFI/almalinux /boot/efi/EFI/redhat
yum -y install foreman-bootloaders-redhat

hostnamectl set-hostname foreman.mylab.net
systemctl restart systemd-hostnamed


foreman-installer -v \
--enable-foreman-plugin-discovery \
--enable-foreman-plugin-bootdisk \
--foreman-proxy-http=true \
--foreman-proxy-dns true \
--foreman-proxy-tftp true \
--foreman-proxy-puppet true \
--foreman-proxy-puppetca true \
--foreman-proxy-templates true \
--foreman-proxy-logs true 

```


# References
- https://idroot.us/install-foreman-almalinux-8/
- https://wiki.crowncloud.net/?How_to_Change_Hostname_in_AlmaLinux_8
- https://docs.theforeman.org/2.5/Provisioning_Guide/index-foreman-el.html
- https://projects.theforeman.org/projects/foreman/wiki/VMware_ESXi
- http://www.c0t0d0s0.de/esxwithforeman/esxwithforeman.html
