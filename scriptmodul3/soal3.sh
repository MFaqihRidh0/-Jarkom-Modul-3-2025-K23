#A) Pulihkan NAT & FORWARD (jika perlu) — di Durin

#Pastikan klien bisa keluar Internet untuk proses instal:

# aktifkan routing
sysctl -w net.ipv4.ip_forward=1

# NAT ke NAT1 (WAN = eth0)
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# sementara: longgarkan FORWARD dulu biar instal lancar
iptables -P FORWARD ACCEPT
# (opsional) bersihkan aturan FORWARD lama
iptables -F FORWARD

# B) Bootstrap konektivitas APT — di Minastir (10.75.5.2)
# 1) pastikan gateway ke Durin subnet-5
ip route replace default via 10.75.5.1

# 2) beri DNS sementara ke Valinor supaya apt bisa resolve
echo "nameserver 192.168.122.1" > /etc/resolv.conf

# 3) test cepat
ping -c3 10.75.5.1
ping -c3 192.168.122.1
curl -I http://deb.debian.org/  # harus 200/301; kalau gagal, balik ke langkah A


Kalau /etc/apt/sources.list kosong/aneh, isi cepat (Debian 13 = trixie):

. /etc/os-release; CODENAME="${VERSION_CODENAME:-trixie}"
cat >/etc/apt/sources.list <<EOF
deb http://deb.debian.org/debian $CODENAME main contrib non-free non-free-firmware
deb http://deb.debian.org/debian $CODENAME-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security $CODENAME-security main contrib non-free non-free-firmware
EOF

# C) Install BIND9 (tanpa rekomendasi, biar ringan) — di Minastir
apt-get update -o Acquire::ForceIPv4=true
apt-get install -y --no-install-recommends bind9 bind9-utils dnsutils -o Acquire::ForceIPv4=true


# Sekarang direktori /etc/bind seharusnya ada. Error “No such file or directory” di nano akan hilang.

# nano /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    forwarders { 192.168.122.1; };   // upstream Valinor
    recursion yes;
    allow-query { any; };
    dnssec-validation no;
    auth-nxdomain no;
    listen-on { any; };
    listen-on-v6 { any; };
};

#B. mode daemon (background)

named -u bind -c /etc/bind/named.conf
# atau pakai nohup supaya tetap jalan walau terminal ditutup:
nohup named -u bind -c /etc/bind/named.conf >/var/log/named.log 2>&1 &

#PENTINGGGG untuk semua client
nano /etc/resolv.conf
#pakai IP Minastir
nameserver 10.75.5.2

#4) Uji dari Minastir & klien
# di Minastir
dig +short example.com @127.0.0.1
dig +short example.com @10.75.5.2

# Di client lain
dig +short example.com

ping google.com

