### Cryptokit Device Setup

### TODO - all the device setup done previously
sudo apt-get install -y hostapd dnsmasq netstat traceroute openvpn 




### configure openvpn
cd /etc/openvpn
sudo cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf .

### Transfer keys over to the device

### Set up routing from one card to the other
#pull in sysctl file
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
sudo iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
sudo iptables -A FORWARD -i wlan1 -o tun0 -j ACCEPT
sudo iptables -A FORWARD -i tun0 -o wlan1 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables-save > /etc/iptables.restore
echo “up iptables-restore < /etc/iptables.restore” | sudo tee --append /etc/network/interfaces
sudo ifdown wlan1
sudo ifup wlan1

### Set up time server
sudo service ntp start
sudo update-rc.d ntp enable

### set up the server
sudo service openvpn start
sudo update-rc.d openvpn enable

###


