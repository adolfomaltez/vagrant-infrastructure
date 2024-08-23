# Install virtualbox + vagrant on debian 12

Install debian 12:

### Add fastrack repository
```sh
echo 'deb https://fasttrack.debian.net/debian-fasttrack/ bookworm-fasttrack main contrib' >> /etc/apt/sources.list
apt-get update
```

### Install vagrant + virtualbox
```sh
apt-get install -y vagrant virtualbox virtualbox-ext-pack
```

## References:
- https://wiki.debian.org/VirtualBox
- https://fasttrack.debian.net/