# Setup Haproxy-1
bash <<EOF2
sed -i 's/ubuntu/haproxy1/g' /etc/hostname
sed -i 's/ubuntu/haproxy1/g' /etc/hosts
hostname haproxy1
add-apt-repository -y ppa:cz.nic-labs/bird
apt-get update
apt-get install bird traceroute
cat >> /etc/network/interfaces << EOF 
auto enp0s8
iface enp0s8 inet static
   address 192.168.10.1
   netmask 255.255.255.0
auto lo:0
  iface lo:0 inet static
  address 172.16.2.11
  netmask 255.255.255.255
auto lo:1
  iface lo:1 inet static
  address 172.16.2.12
  netmask 255.255.255.255
auto lo:2
  iface lo:2 inet static
  address 172.16.2.13
  netmask 255.255.255.255
EOF
/etc/init.d/networking restart
cat > /etc/bird/bird.conf << EOF1 
log syslog all;
router id 192.168.10.1;

protocol device {
 scan time 10;
}

protocol static VIPs {
 route 172.16.2.11/32 via 192.168.10.1;
 route 172.16.2.12/32 via 192.168.10.1;
 route 172.16.2.13/32 via 192.168.10.1;
}

protocol bgp {
 import none;
 export filter {
  if proto = "VIPs" then accept;
  reject;
 };
 local as 65000;
 source address 192.168.10.1;
 neighbor 192.168.10.21 as 65000;
}
EOF1
exit
EOF2