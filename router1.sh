# Setup Router-1
bash <<EOF2
sed -i 's/ubuntu/router1/g' /etc/hostname
sed -i 's/ubuntu/router1/g' /etc/hosts
hostname router1
add-apt-repository -y ppa:cz.nic-labs/bird
apt-get update
apt-get install bird traceroute
cat >> /etc/network/interfaces << EOF 
auto enp0s8
iface enp0s8 inet static
   address 192.168.10.21
   netmask 255.255.255.0
EOF
/etc/init.d/networking restart
cat > /etc/bird/bird.conf << EOF1 
# Configure logging
log syslog { info, remote, warning, error, auth, fatal, bug };

router id 192.168.10.21;

filter haproxy_vip {
 if net ~ 172.16.2.0/24 then accept;
 else reject;
}

protocol kernel {
 scan time 10;
 import all;
 export all;
 learn;
}

protocol device {
 scan time 10;
}

protocol direct {
 interface "enp0s8";
}

protocol bgp haproxy1 {
 local as 65000;
 export none;
 import filter haproxy_vip;
 source address 192.168.10.21;
 neighbor 192.168.10.1 as 65000;
 default bgp_local_pref 300;
}

protocol bgp haproxy2 {
 local as 65000;
 export none;
 import filter haproxy_vip;
 source address 192.168.10.21;
 neighbor 192.168.10.3 as 65000;
 default bgp_local_pref 200;
}
EOF1
exit
EOF2