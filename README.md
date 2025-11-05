# LAPRES Praktikum Komunikasi Data dan Jaringan Komputer Modul 3 - K-23

## Anggota
1. M. Faqih Ridho - 5027241123
2. Kaisar Hanif Pratama - 5027241029


## Pengerjaan

### Nomor 1
konfigruasi client IP static (sesuaikan IP address)
```
auto eth0
iface eth0 inet static
	address 10.75.2.6
	netmask 255.255.255.0
	gateway 10.75.2.1
        up echo "nameserver 192.168.122.1" > /etc/resolv.conf
```

Konfigurasi klient IP dinamis 

```
auto eth0
iface eth0 inet dhcp

up echo nameserver 19.2.168.122.1 > /etc/resolv.conf
```

konfogurasi Durin
```
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
```

<img width="712" height="137" alt="image" src="https://github.com/user-attachments/assets/51856107-74c7-44bb-94d7-44ceac02a85f" />

<img width="689" height="140" alt="image" src="https://github.com/user-attachments/assets/9d0ff831-add1-47a4-b83f-b09fb72157b1" />



### Nomor 2

konfigurasi DHCP Server aldarion
```
apt-get update
apt-get install isc-dhcp-server
dhcpd --version
```

nano /etc/default/isc-dhcp-server
```
INTERFACES="eth0"
```

nano /etc/dhcp/dhcpd.conf

```
authoritative;

# ===== Subnet 1: Keluarga Manusia (10.75.1.0/24) =====
subnet 10.75.1.0 netmask 255.255.255.0 {
  option routers           10.75.1.1;
  option subnet-mask       255.255.255.0;
  option broadcast-address 10.75.1.255;
  option domain-name-servers 10.75.5.2;
  option domain-name "k23.com";

  # Lease: Manusia 30 menit, maksimum 1 jam
  default-lease-time 1800;    # 30m
  max-lease-time     3600;    # 60m

  # Dua rentang pool
  range 10.75.1.6   10.75.1.34;
  range 10.75.1.68  10.75.1.94;
}

# ===== Subnet 2: Keluarga Peri (10.75.2.0/24) =====
subnet 10.75.2.0 netmask 255.255.255.0 {
  option routers           10.75.2.1;
  option subnet-mask       255.255.255.0;
  option broadcast-address 10.75.2.255;
  option domain-name-servers 192.168.122.1;

  # Lease: Peri 10 menit, maksimum 1 jam
  default-lease-time 600;     # 10m
  max-lease-time     3600;    # 60m

  range 10.75.2.35  10.75.2.67;
  range 10.75.2.96  10.75.2.121;
}

# ===== Subnet 3: Segmen Khamul (10.75.3.0/24) =====
# Tidak ada pool dinamis; hanya opsi & reservasi Khamul
subnet 10.75.3.0 netmask 255.255.255.0 {
  option routers           10.75.3.1;
  option subnet-mask       255.255.255.0;
  option broadcast-address 10.75.3.255;
  option domain-name-servers 192.168.122.1;
}

# Reservasi agar Khamul SELALU mendapat 10.75.3.95
host khamul {
  hardware ethernet AA:BB:CC:DD:EE:FF;   # GANTI dengan MAC eth0 Khamul
  fixed-address 10.75.3.95;
}

# ===== Subnet 4: Lokal Aldarion (10.75.4.0/24) =====
# Wajib dideklarasikan karena interface Aldarion (eth0) berada di sini.
# Tidak ada pool yang dibagikan pada subnet ini.
subnet 10.75.4.0 netmask 255.255.255.0 { }
```

Buat file leases jika belum ada
```
mkdir -p /var/lib/dhcp
[ -f /var/lib/dhcp/dhcpd.leases ] || touch /var/lib/dhcp/dhcpd.leases
```

Cek sintaks lalu restart
```
dhcpd -4 -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status
```
konfigurasi DHCP relay (Durin)
```
apt-get update
apt-get install isc-dhcp-relay -y
service isc-dhcp-relay start
```

lalu buka nano /etc/default/isc-dhcp-relay (Durin)

```
SERVERS="10.75.4.2"
INTERFACES="eth1 eth2 eth3 eth4 eth5"   # semua interface LAN Durin
OPTIONS=""
```

**Gilgalad**

<img width="827" height="317" alt="image" src="https://github.com/user-attachments/assets/c97249e6-0f08-417d-8016-8c4ad89bcb0e" />

**Amandil**

<img width="668" height="450" alt="soal 2 amandil" src="https://github.com/user-attachments/assets/9e5a3568-d550-425f-ac78-ff4daeaf2135" />




### Nomor 3

**A) Pulihkan NAT & FORWARD (jika perlu) — di Durin**

Pastikan klien bisa keluar Internet untuk proses instal:

**aktifkan routing**
```
sysctl -w net.ipv4.ip_forward=1
```
NAT ke NAT1 (WAN = eth0)

```
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

**sementara: longgarkan FORWARD dulu biar instal lancar**
iptables -P FORWARD ACCEPT

**(opsional) bersihkan aturan FORWARD lama**
iptables -F FORWARD

**B) Bootstrap konektivitas APT — di Minastir (10.75.5.2)**

1) pastikan gateway ke Durin subnet-5
   
```   
ip route replace default via 10.75.5.1
```
2) beri DNS sementara ke Valinor supaya apt bisa resolve
   
```   
echo "nameserver 192.168.122.1" > /etc/resolv.conf
```
4) test cepat
   
```
ping -c3 10.75.5.1
ping -c3 192.168.122.1
curl -I http://deb.debian.org/  # harus 200/301; kalau gagal, balik ke langkah A
```

**Kalau /etc/apt/sources.list kosong/aneh, isi cepat (Debian 13 = trixie):**

. /etc/os-release; CODENAME="${VERSION_CODENAME:-trixie}"
cat >/etc/apt/sources.list <<EOF
deb http://deb.debian.org/debian $CODENAME main contrib non-free non-free-firmware
deb http://deb.debian.org/debian $CODENAME-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security $CODENAME-security main contrib non-free non-free-firmware
EOF

C) Install BIND9 (tanpa rekomendasi, biar ringan) — di Minastir

```
apt-get update -o Acquire::ForceIPv4=true
apt-get install -y --no-install-recommends bind9 bind9-utils dnsutils -o Acquire::ForceIPv4=true
```

Sekarang direktori /etc/bind seharusnya ada. Error “No such file or directory” di nano akan hilang.

nano /etc/bind/named.conf.options

```
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
```

**B. mode daemon (background)**

```
named -u bind -c /etc/bind/named.conf
atau pakai nohup supaya tetap jalan walau terminal ditutup:
nohup named -u bind -c /etc/bind/named.conf >/var/log/named.log 2>&1 &
```

**PENTINGGGG untuk semua client**
```
nano /etc/resolv.conf
#pakai IP Minastir
nameserver 10.75.5.2
```
<img width="717" height="161" alt="hasil nomer 3 ping google com" src="https://github.com/user-attachments/assets/5eb2f491-076a-49b9-bfe6-56bf3d33a057" />


4) Uji dari Minastir & klien
**di Minastir**
```
dig +short example.com @127.0.0.1
dig +short example.com @10.75.5.2
```

**Di client lain**
```
dig +short example.com
ping google.com
```

**Hasil dari Minastir**

<img width="419" height="152" alt="nomer 3 hasil dari minastir" src="https://github.com/user-attachments/assets/7a3b58cd-d963-40d0-9d9d-978d988d3663" />

**Klient lain**

<img width="416" height="123" alt="nomer 3 hasil dari klient lain" src="https://github.com/user-attachments/assets/88a99a36-4f6a-4760-93d4-7672eaf46172" />

<img width="717" height="161" alt="hasil nomer 3 ping google com" src="https://github.com/user-attachments/assets/a5399655-feea-450c-8868-04341880672a" />




### Nomor 4

1) Erendis (MASTER / ns1)

Peran: server DNS otoritatif master untuk <xxxx>.com

a) Pastikan bind9 terpasang & jalan

**jika belum**
```
ip route replace default via 10.75.3.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update -o Acquire::ForceIPv4=true
apt-get install -y --no-install-recommends bind9 bind9-utils dnsutils
```
jalankan tanpa systemd (container)

```
named -u bind -c /etc/bind/named.conf 2>/dev/null || true
```

b) Tambahkan zona master

nano /etc/bind/named.conf.local

zone "k23.com" {
    type master;
    file "/etc/bind/zones/db.k23.com";
    allow-transfer { 10.75.3.4; };   // Amdir (slave)
    also-notify   { 10.75.3.4; };
};


c) File zona otoritatif
#Buat folder & isi file zona:

mkdir -p /etc/bind/zones
nano /etc/bind/zones/db.k23.com


Isi contoh (ganti IP sesuai host-mu yang sebenarnya):

nano /etc/bind/zones/db.k23.com

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

 2) Amdir (SLAVE / ns2)

 Peran: menerima salinan zona dari Erendis

 a) Pasang bind9 & mulai

ip route replace default via 10.75.3.1
echo "nameserver 192.168.122.1" > /etc/resolv.conf
apt-get update -o Acquire::ForceIPv4=true
apt-get install -y --no-install-recommends bind9 bind9-utils dnsutils

definisi zona slave
nano /etc/bind/named.conf.local

Isi:

```
zone "k23.com" {
    type slave;
    file "/var/cache/bind/db.k23.com";
    masters { 10.75.3.3; };  // Erendis (master)
};
```

#3) Minastir (DNS forwarder semua klien)

Peran: resolver recursive; forward kueri untuk zona privat ke Erendis/Amdir

Tambahkan forward-zone agar *.k23.com tidak dilempar ke Internet

masuk ke nano /etc/bind/named.conf.local lalu konfigurasikan zone

```
zone "k23.com" {
    type forward;
    forward only;
    forwarders { 10.75.3.3; 10.75.3.4; };  // ns1 & ns2 lokal
};
```

### 5) Uji dari salah satu klien (mis. Elros)
### pastikan dapat DNS Minastir dari DHCP
```
dhclient -r eth0 || true
dhclient eth0
cat /etc/resolv.conf      # harus: nameserver 10.75.5.2
```

### uji resolusi via Minastir
ping -c3 palantir.k23.com
ping -c3 elros.k23.com
ping -c3 pharazon.k23.com
ping -c3 elendil.k23.com
ping -c3 isildur.k23.com
ping -c3 anarion.k23.com
ping -c3 galadriel.k23.com
ping -c3 celegorn.k23.com
ping -c3 oropher.k23.com

**Hasil Diliat dari Amdir**
<img width="563" height="78" alt="nomer 4 amdir" src="https://github.com/user-attachments/assets/859c178b-a1e5-4ec2-bc87-091da96339ec" />

**Hasil Diliat dari Erendis**

<img width="500" height="194" alt="nomer 4 erendis" src="https://github.com/user-attachments/assets/8338993e-561e-4a9f-8e1f-0149f9748190" />

**Hasil nomer 4 membuat DNS**

<img width="467" height="460" alt="hasil nomer 4 ping DNS" src="https://github.com/user-attachments/assets/8b97fc71-4dd5-4ff5-b1e5-92eeebcd6732" />


### Nomor 5
A. Skrip untuk Erendis (MASTER – 10.75.3.3)

Jalankan di Erendis sebagai root. Ini menimpa file BIND terkait.
```
#!/usr/bin/env bash
set -euo pipefail

DOMAIN="k23.com"
SERIAL="$(date +%Y%m%d%H)"
MASTER_IP="10.75.3.3"
SLAVE_IP="10.75.3.4"
```

**Direktori zona**
```
mkdir -p /etc/bind/zones
chown -R root:bind /etc/bind/zones
```

**named.conf.options (autoritatif-only, izinkan query dari mana pun)**
```
cat >/etc/bind/named.conf.options <<'EOF'
options {
    directory "/var/cache/bind";
    recursion no;
    allow-query { any; };
    listen-on { any; };
    dnssec-validation no;
};
EOF
```

**named.conf.local (zona master + reverse)**
```
cat >/etc/bind/named.conf.local <<EOF
zone "${DOMAIN}" {
    type master;
    file "/etc/bind/zones/db.${DOMAIN}";
    allow-transfer { ${SLAVE_IP}; };
    also-notify   { ${SLAVE_IP}; };
    notify yes;
};

zone "10.75.10.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.3.75.10.rev";
    allow-transfer { ${SLAVE_IP}; };
    also-notify   { ${SLAVE_IP}; };
    notify yes;
};
EOF
```

**File zona forward (lengkap dengan CNAME & TXT)**
```
cat >/etc/bind/zones/db.${DOMAIN} <<EOF
\$TTL 604800
@   IN  SOA ns1.${DOMAIN}. admin.${DOMAIN}. (
        ${SERIAL} 3600 900 1209600 300 )

    IN  NS  ns1.${DOMAIN}.
    IN  NS  ns2.${DOMAIN}.

ns1 IN  A   ${MASTER_IP}      ; Erendis
ns2 IN  A   ${SLAVE_IP}       ; Amdir

; APEX pointing to Palantir
@   IN  A   10.75.4.3
www IN  CNAME   ${DOMAIN}.

; Host penting
palantir    IN A 10.75.4.3
elros       IN A 10.75.1.6
pharazon    IN A 10.75.2.2
elendil     IN A 10.75.1.2
isildur     IN A 10.75.1.3
anarion     IN A 10.75.1.4
galadriel   IN A 10.75.2.6
celeborn    IN A 10.75.2.5
oropher     IN A 10.75.2.4

; TXT rahasia (sesuai soal)
elros       IN TXT "Cincin Sauron"
pharazon    IN TXT "Aliansi Terakhir"
EOF

# Zona reverse untuk 10.75.3.{3,4}
cat >/etc/bind/zones/db.3.75.10.rev <<'EOF'
$TTL 604800
@   IN  SOA ns1.k23.com. admin.k23.com. (
        2025110101 3600 900 1209600 300 )
    IN  NS  ns1.k23.com.
    IN  NS  ns2.k23.com.

3   IN  PTR erendis.k23.com.
4   IN  PTR amdir.k23.com.
EOF
```

**Validasi & muat**

```
named-checkconf
named-checkzone "${DOMAIN}" /etc/bind/zones/db.${DOMAIN}
named-checkzone 10.75.10.in-addr.arpa /etc/bind/zones/db.3.75.10.rev
```

**Start/Reload named (tanpa systemd)**

```
pkill -f "named -u bind" 2>/dev/null || true
sleep 1
named -u bind -c /etc/bind/named.conf >/var/log/named.log 2>&1 &
sleep 1
```

**Paksa notifikasi ke slave**
```
rndc reload ${DOMAIN} 2>/dev/null || true
rndc reload 10.75.10.in-addr.arpa 2>/dev/null || true
rndc notify ${DOMAIN} 2>/dev/null || true
rndc notify 10.75.10.in-addr.arpa 2>/dev/null || true
```
echo "[MASTER] selesai. Cek: dig @${MASTER_IP} ${DOMAIN} SOA +noall +answer"

B. Skrip untuk Amdir (SLAVE – 10.75.3.4)

#Jalankan di Amdir sebagai root.

#!/usr/bin/env bash
set -euo pipefail

DOMAIN="k23.com"
MASTER_IP="10.75.3.3"

mkdir -p /var/cache/bind
chown -R bind:bind /var/cache/bind
chmod 775 /var/cache/bind

cat >/etc/bind/named.conf.options <<'EOF'
options {
    directory "/var/cache/bind";
    recursion no;
    allow-query { any; };
    listen-on { any; };
    dnssec-validation no;
};
EOF

cat >/etc/bind/named.conf.local <<EOF
zone "${DOMAIN}" {
    type slave;
    file "/var/cache/bind/db.${DOMAIN}";
    masters { ${MASTER_IP}; };
    allow-notify { ${MASTER_IP}; };
};

zone "10.75.10.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.3.75.10.rev";
    masters { ${MASTER_IP}; };
    allow-notify { ${MASTER_IP}; };
};
EOF

named-checkconf

pkill -f "named -u bind" 2>/dev/null || true
sleep 1
named -u bind -c /etc/bind/named.conf >/var/log/named.log 2>&1 &
sleep 1

**Bersihkan cache file lama & tarik ulang**
```
rm -f /var/cache/bind/db.${DOMAIN} /var/cache/bind/db.3.75.10.rev || true
rndc retransfer ${DOMAIN} 2>/dev/null || true
rndc retransfer 10.75.10.in-addr.arpa 2>/dev/null || true
sleep 1

echo "[SLAVE] selesai. Cek: ls -l /var/cache/bind/db.${DOMAIN}"
```
C. Perintah uji (jalankan dari klien mana pun, atau langsung di Erendis/Amdir)
 
**Master vs slave serial harus sama**
```
dig @10.75.3.3 k23.com SOA +noall +answer
dig @10.75.3.4 k23.com SOA +noall +answer
```
1) Alias www (CNAME → apex)
```
dig @10.75.3.3 www.k23.com +noall +answer
dig @10.75.3.4 www.k23.com +noall +answer
```
3) TXT rahasia
```
dig @10.75.3.3 TXT elros.k23.com +noall +answer
dig @10.75.3.4 TXT elros.k23.com +noall +answer
dig @10.75.3.3 TXT pharazon.k23.com +noall +answer
dig @10.75.3.4 TXT pharazon.k23.com +noall +answer
```

**Hasil dari nomer 5**

<img width="947" height="398" alt="soal nomer 5 hasil" src="https://github.com/user-attachments/assets/3b16c6fc-cd35-4d45-a909-619eab2a6d59" />


### Nomor 6

**Jalankan di ALdarion**

1. Jalankan nano /etc/dhcp/dhcpd.conf lalu isi dengan konfigurasi sebagai berikut :

```
authoritative;

# ===== Subnet 1: Keluarga Manusia (10.75.1.0/24) =====
subnet 10.75.1.0 netmask 255.255.255.0 {
  option routers              10.75.1.1;
  option subnet-mask          255.255.255.0;
  option broadcast-address    10.75.1.255;
  option domain-name-servers  10.75.5.2;   # DNS internal (Minastir)
  option domain-name          "k23.com";

  # fallback subnet
  default-lease-time 1800;    # 30m
  max-lease-time     3600;    # 60m

  pool {
    range 10.75.1.6  10.75.1.34;
    default-lease-time 1800;
    max-lease-time     3600;
  }
  pool {
    range 10.75.1.68 10.75.1.94;
    default-lease-time 1800;
    max-lease-time     3600;
  }
}

# ===== Subnet 2: Keluarga Peri (10.75.2.0/24) =====
subnet 10.75.2.0 netmask 255.255.255.0 {
  option routers              10.75.2.1;
  option subnet-mask          255.255.255.0;
  option broadcast-address    10.75.2.255;
  option domain-name-servers  10.75.5.2;   # samakan ke DNS internal (boleh 192.168.122.1 kalau diminta soal)
  default-lease-time 600;     # 10m
  max-lease-time     3600;    # 60m

  pool {
    range 10.75.2.35 10.75.2.67;
    default-lease-time 600;
    max-lease-time     3600;
  }
  pool {
    range 10.75.2.96 10.75.2.121;
    default-lease-time 600;
    max-lease-time     3600;
  }
}

# ===== Subnet 3: Segmen Khamul (10.75.3.0/24) =====
subnet 10.75.3.0 netmask 255.255.255.0 {
  option routers              10.75.3.1;
  option subnet-mask          255.255.255.0;
  option broadcast-address    10.75.3.255;
  option domain-name-servers  10.75.5.2;
}

# Reservasi Khamul (ganti MAC!)
host khamul {
  hardware ethernet AA:BB:CC:DD:EE:FF;   # ganti dgn MAC eth0 Khamul (ip -br link show)
  fixed-address 10.75.3.95;
}

# ===== Subnet 4: Lokal Aldarion (10.75.4.0/24) =====
subnet 10.75.4.0 netmask 255.255.255.0 { }
```

2. “Bersihkan” state di server (Aldarion)
stop dulu
```
systemctl stop isc-dhcp-server 2>/dev/null || service isc-dhcp-server stop
```

backup & kosongkan database lease

```
cp -a /var/lib/dhcp/dhcpd.leases /var/lib/dhcp/dhcpd.leases.bak 2>/dev/null || true
: > /var/lib/dhcp/dhcpd.leases
```

pastikan config OK
```
dhcpd -t -cf /etc/dhcp/dhcpd.conf
```

start lagi

```
systemctl start isc-dhcp-server 2>/dev/null || service isc-dhcp-server start
```

**Test di klient keluarga manusia**

```
ip addr flush dev eth0
rm -f /var/lib/dhcp/dhclient*.leases

dhclient -r eth0 || true
dhclient -v -lf /var/lib/dhcp/dhclient.eth0.leases -pf /run/dhclient.eth0.pid eth0

# cek lease time dari file (bukan dari "renewal in ...")
grep -m1 -Eo 'option dhcp-lease-time[ ]+[0-9]+' /var/lib/dhcp/dhclient.eth0.leases \
| awk '{print "Lease seconds:", $3}'
```

**Test di klient keluarga peri**

1) Siapkan klien DHCP (kalau belum ada)

```
apt-get update && apt-get install -y isc-dhcp-client
```

2) Bersihkan jejak lama
```
ip addr flush dev eth0
rm -f /var/lib/dhcp/dhclient*.leases
```

3) Minta lease baru
```
dhclient -r eth0 || true
dhclient -v -lf /var/lib/dhcp/dhclient.eth0.leases -pf /run/dhclient.eth0.pid eth0
```

4) Verifikasi IP harus di subnet & pool Manusia
```
ip -4 -o addr show dev eth0 | awk '{print "IP:",$4}'
```

5) Baca durasi lease dari file (bukan "renewal in ...")
```
grep -m1 -Eo 'option dhcp-lease-time[ ]+[0-9]+' /var/lib/dhcp/dhclient.eth0.leases \
| awk '{print "Lease seconds:", $3}'
```

**Hasil dari klient keluarga manusia**

<img width="638" height="325" alt="hasil nomer 6 finalll" src="https://github.com/user-attachments/assets/59070451-39dc-49dc-84cd-6de4e9ff6ca5" />

**Hasil dari klient keluarga peri**

<img width="817" height="449" alt="hasil nomer 6 untuk manusia" src="https://github.com/user-attachments/assets/15f3ab58-7eaa-4ab9-91e6-328321baf08d" />


