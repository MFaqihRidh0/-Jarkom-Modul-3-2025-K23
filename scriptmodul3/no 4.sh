# 1) Erendis (MASTER / ns1)

#Peran: server DNS otoritatif master untuk <xxxx>.com

# a) Pastikan bind9 terpasang & jalan

# jika belum
ip route replace default via 10.75.3.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update -o Acquire::ForceIPv4=true
apt-get install -y --no-install-recommends bind9 bind9-utils dnsutils

# jalankan tanpa systemd (container)
named -u bind -c /etc/bind/named.conf 2>/dev/null || true


# b) Tambahkan zona master

nano /etc/bind/named.conf.local

zone "k23.com" {
    type master;
    file "/etc/bind/zones/db.k23.com";
    allow-transfer { 10.75.3.4; };   // Amdir (slave)
    also-notify   { 10.75.3.4; };
};


# c) File zona otoritatif
#Buat folder & isi file zona:

mkdir -p /etc/bind/zones
nano /etc/bind/zones/db.k23.com


#Isi contoh (ganti IP sesuai host-mu yang sebenarnya):
# nano /etc/bind/zones/db.k23.com
  GNU nano 8.4                                     /etc/bind/zones/db.k23.com *
; Nameserver untuk zona
    IN NS ns1.k23.com.
    IN NS ns2.k23.com.

; Alamat nameserver
ns1 IN A 10.75.3.3     ; Erendis (MASTER)
ns2 IN A 10.75.3.4     ; Amdir   (SLAVE)

; Lokasi penting (ISI DENGAN IP AKTUAL DI TOPOLOGIMU)
palantir   IN A 10.75.4.3
elros      IN A 10.75.1.6
pharazon   IN A 10.75.2.2
elendil    IN A 10.75.1.2
isildur    IN A 10.75.1.3
anarion    IN A 10.75.1.4
galadriel  IN A 10.75.2.6
celeborn   IN A 10.75.2.5
oropher    IN A 10.75.2.4

; Alias contoh
www IN CNAME palantir.k23.com.

# 2) Amdir (SLAVE / ns2)

# Peran: menerima salinan zona dari Erendis

# a) Pasang bind9 & mulai

ip route replace default via 10.75.3.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update -o Acquire::ForceIPv4=true
apt-get install -y --no-install-recommends bind9 bind9-utils dnsutils

# definisi zona slave
nano /etc/bind/named.conf.local


#Isi:

zone "k23.com" {
    type slave;
    file "/var/cache/bind/db.k23.com";
    masters { 10.75.3.3; };  // Erendis (master)
};

#3) Minastir (DNS forwarder semua klien)

#Peran: resolver recursive; forward kueri untuk zona privat ke Erendis/Amdir

#Tambahkan forward-zone agar *.k23.com tidak dilempar ke Internet

nano /etc/bind/named.conf.local

zone "k23.com" {
    type forward;
    forward only;
    forwarders { 10.75.3.3; 10.75.3.4; };  // ns1 & ns2 lokal
};

# 5) Uji dari salah satu klien (mis. Elros)
# pastikan dapat DNS Minastir dari DHCP
dhclient -r eth0 || true
dhclient eth0
cat /etc/resolv.conf      # harus: nameserver 10.75.5.2

# uji resolusi via Minastir
ping -c3 palantir.k23.com
ping -c3 elros.k23.com
ping -c3 pharazon.k23.com
ping -c3 elendil.k23.com
ping -c3 isildur.k23.com
ping -c3 anarion.k23.com
ping -c3 galadriel.k23.com
ping -c3 celegorn.k23.com
ping -c3 oropher.k23.com
