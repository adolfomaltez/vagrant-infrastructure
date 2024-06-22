#!/bin/bash
# Installing Zabbix 7.0 on debian

# Configure locales to en_US.UTF8
sudo su
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
locale-gen

# Install Zabbix repository
wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_7.0-1+debian12_all.deb
dpkg -i zabbix-release_7.0-1+debian12_all.deb
apt-get update

# Install zabbix packages
apt-get install -y zabbix-server-pgsql postgresql-15 zabbix-frontend-php php8.2-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent

# Create zabbix postgresql user and database
sudo -u postgres psql -c "CREATE USER zabbix WITH PASSWORD 'zabbix';"
sudo -u postgres createdb -O zabbix zabbix
zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix 

# Config zabbix password
sed -i -e 's/#\ DBPassword=/DBPassword=zabbix/g' /etc/zabbix/zabbix_server.conf

#  Configure nginx server
sed -i '/server {/a\ \ \ \ \ \ \ \ \ server_name\ \ \ \ \ 192.168.31.94;' /etc/zabbix/nginx.conf
sed -i '/server {/a\ \ \ \ \ \ \ \ \ listen\ \ \ \ \ \ \ \ \ \ 80;' /etc/zabbix/nginx.conf

# Restart zabbix services
sudo systemctl restart zabbix-server zabbix-agent nginx php8.2-fpm

# View on web browser
echo "View on your WEB browser http://192.168.31.94/ to finish the zabbix configuration"
echo "User: Admin"
echo "Password: zabbix"