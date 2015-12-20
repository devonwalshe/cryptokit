#!/bin/bash 

### VPN Server Setup Script ###

### Get initial access and login

## Update apt
sudo apt-get update

## Install VPN and move it
sudo apt-get install -Y openvpn
sudo cp -r /usr/share/doc/openvpn /etc/openvpn

## Move openvpn folder

## Install easy-rsa and move folder
sudo apt-get install -Y easy-rsa
sudo cp -r /usr/share/easy-rsa /etc/openvpn

### TODO - These step should be done on offline server

## install CA
sudo -s
source vars
./clean-all
./build-ca
./build-key-server cryptokit-vpn-server
./build-dh
cd keys/
cp cryptokit-vpn-server.crt cryptokit-vpn-server.key ca.crt dh2048.pem /etc/openvpn/

### tmp folder for working files
sudo mkdir /tmp/openvpn
sudo chmod go+w /tmp/openvpn

### copy the example config to the directory
gzip -d /etc/openvpn/examples/sample-config-files/server.conf.gz 
sudo cp /etc/openvpn/examples/sample-config-files/server.conf /etc/openvpn/server.conf

### Edit the file as needed

### Get back to ubuntu user
exit

### set up the service
sudo service openvpn start
sudo rc-update.d openvpn enable

### Set up the routing
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

### Edit sysctl file with option: net.ipv4.ip_forward=1

# ## Enable all incoming connections on UDP 1194
# sudo iptables -A INPUT -i eth0 -m state --state NEW -p udp --dport 1194 -j ACCEPT
#
# ## Masquerade as connected clients on the internet by pushing all traffic through the network to eth0
# sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
#
# ## Forward traffic from clients to the destination on the internet
# sudo iptables -A FORWARD -i tun0 -j ACCEPT
#
# ## Return internet traffic to the right client that match RELATED and ESTABLISHED rules
# sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

### Amazon firewall settings
iptables -A INPUT -i tun+ -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

# Setup new admin user
sudo adduser cryptokit_admin
sudo gpasswd -a cryptokit_admin sudo

## Change user to cryptokit_admin
su cryptokit_admin

# Move VPN key to new user .ssh folder
mkdir -p /home/cryptokit_admin/.ssh; mv /home/ubuntu/.ssh/authorized_keys $_
chown -R /home/cryptokit_admin/.ssh
chmod 700 /home/cryptokit_admin/.ssh
chmod 600 /home/cryptokit_admin/.ssh/authorized_keys


### Disable password auth for ubuntu user
