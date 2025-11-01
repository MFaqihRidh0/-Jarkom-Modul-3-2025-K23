#konfigruasi client CONTOH
auto eth0
iface eth0 inet static
	address 10.75.2.6
	netmask 255.255.255.0
	gateway 10.75.2.1
        up echo "nameserver 192.168.122.1" > /etc/resolv.conf

#konfogurasi Durin
auto eth0
iface eth0 inet dhcp
         up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.75.0.0/16

auto eth1
iface eth1 inet static
	address 10.75.1.1
	netmask 255.255.255.0

auto eth2
iface eth2 inet static
	address 10.75.2.1
	netmask 255.255.255.0

auto eth3
iface eth3 inet static
	address 10.75.3.1
	netmask 255.255.255.0

auto eth4
iface eth4 inet static
	address 10.75.4.1
	netmask 255.255.255.0

auto eth5
iface eth5 inet static
	address 10.75.5.1
	netmask 255.255.255.0