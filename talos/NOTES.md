# Create default pool
- https://www.talos.dev/v1.5/talos-guides/install/virtualized-platforms/vagrant-libvirt/

### Donwload Talos ISO image
```sh
wget --timestamping https://github.com/siderolabs/talos/releases/download/v1.5.5/metal-amd64.iso -O /tmp/metal-amd64.iso
```
    
    
### Start VMs
```sh
vagrant up --provider=libvirt
vagrant status
```

### Get IPs from VMs
```sh
virsh list | grep talos | awk '{print $2}' | xargs -t -L1 virsh domifaddr
```

### Install Talos
```sh
talosctl gen config my-cluster https://192.168.121.100:6443 --install-disk /dev/vda
```

### Edit controlplane.yaml
```sh
Replace:
    network: {}
To:
    network:
      interfaces:
        - interface: eth0
          dhcp: true
          vip:
            ip: 192.168.121.100
```
### Apply the configuration to the initial control plane node:
```sh
talosctl -n 192.168.121.52 apply-config --insecure --file controlplane.yaml
```

```sh
export TALOSCONFIG=$(realpath ./talosconfig)
talosctl config endpoint 192.168.121.52 192.168.121.244 192.168.121.125
```

### Bootstrap the kubernetes cluster
```sh
talosctl -n 192.168.121.52 bootstrap
```

### Apply the machine configurations to the remaining nodes:
```sh
talosctl -n 192.168.121.244 apply-config --insecure --file controlplane.yaml
talosctl -n 192.168.121.125 apply-config --insecure --file controlplane.yaml
talosctl -n 192.168.121.69 apply-config --insecure --file worker.yaml
```

### After a while, get talos cluster members
```sh
talosctl -n 192.168.121.100 get members
```

### Interact with kubernetes
```sh
talosctl -n 192.168.121.100 kubeconfig ./kubeconfig
kubectl --kubeconfig ./kubeconfig get node -owide
kubectl --kubeconfig ./kubeconfig get pods
```

## Optional, destroy all
```sh
vagrant destroy -f
rm /tmp/metal-amd64.iso
```

# Notes

## Virsh pool
- https://serverfault.com/questions/840519/how-to-change-the-default-storage-pool-from-libvirt
```sh
virsh pool-define-as --name default --type dir --target /home/taro/vagrant/talos/pool
virsh pool-start default
virsh pool-list
```

```sh
virsh list | grep talos | awk '{print $2}' | xargs -t -L1 virsh domifaddr
```