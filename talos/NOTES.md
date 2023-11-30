# Create default pool
- https://www.talos.dev/v1.4/talos-guides/install/virtualized-platforms/vagrant-libvirt/

### Donwload Talos ISO image
    wget  https://github.com/siderolabs/talos/releases/download/v1.4.0/talos-amd64.iso -O talos-amd64.iso
    
### Start VMs
    vagrant up --provider=libvirt
    vagrant status

### Get IPs from VMs
    virsh list | grep talos | awk '{print $2}' | xargs -t -L1 virsh domifaddr

### Install Talos
    talosctl gen config my-cluster https://192.168.121.100:6443 --install-disk /dev/vda

### Edit controlplane.yaml

Replace:
    network: {}
To:
    network:
      interfaces:
        - interface: eth0
          dhcp: true
          vip:
            ip: 192.168.121.100

### Apply the configuration to the initial control plane node:
    talosctl -n 192.168.121.52 apply-config --insecure --file controlplane.yaml

    export TALOSCONFIG=$(realpath ./talosconfig)
    talosctl config endpoint 192.168.121.52 192.168.121.244 192.168.121.125

### Bootstrap the kubernetes cluster
    talosctl -n 192.168.121.52 bootstrap

### Apply the machine configurations to the remaining nodes:
    talosctl -n 192.168.121.244 apply-config --insecure --file controlplane.yaml
    talosctl -n 192.168.121.125 apply-config --insecure --file controlplane.yaml
    talosctl -n 192.168.121.69 apply-config --insecure --file worker.yaml


### After a while, get talos cluster members
    talosctl -n 192.168.121.100 get members

### Interact with kubernetes
    talosctl -n 192.168.121.100 kubeconfig ./kubeconfig
    kubectl --kubeconfig ./kubeconfig get node -owide
    kubectl --kubeconfig ./kubeconfig get pods

## Optional, destroy all
    vagrant destroy -f
    rm talos-amd64.iso


# Notes

## Virsh pool
- https://serverfault.com/questions/840519/how-to-change-the-default-storage-pool-from-libvirt
    virsh pool-define-as --name default --type dir --target /home/taro/vagrant/talos/pool
    virsh pool-start default
    virsh pool-list


virsh list | grep talos | awk '{print $2}' | xargs -t -L1 virsh domifaddr