# k3s-alma8
k3s deployment on almalinux 8.

Single node kubernetes k3s installation

## Download k3s (airgap image)
```sh
wget https://github.com/k3s-io/k3s/releases/download/v1.29.0%2Bk3s1/k3s-airgap-images-amd64.tar.gz
gunzip k3s-airgap-images-amd64.tar.gz
wget https://github.com/k3s-io/k3s/releases/download/v1.29.0%2Bk3s1/k3s
wget https://get.k3s.io/ -O install.sh
```

# Install 
```sh
vagrant up
```
# Join to Rancher

In an existing Rancher installation.

Cluster Management > Import Existing.

Registration > Apply the yaml on the k3s node.



# References
- https://docs.k3s.io/installation/airgap
- https://github.com/k3s-io/k3s/releases/tag/v1.29.0%2Bk3s1