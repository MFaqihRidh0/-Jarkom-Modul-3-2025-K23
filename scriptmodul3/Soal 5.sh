#A. Pastikan master mengumumkan zona reverse

# Erendis (10.75.3.3 – MASTER)

#Pastikan blok zona reverse ada dan mengizinkan transfer:

# /etc/bind/named.conf.local
zone "3.75.10.in-addr.arpa" {
  type master;
  file "/etc/bind/zones/db.3.75.10.rev";
  allow-transfer { 10.75.3.4; };  // Amdir (slave)
  also-notify   { 10.75.3.4; };
  notify yes;
};


#Isi file zona reverse (pastikan ada titik di akhir FQDN PTR!):

# /etc/bind/zones/db.3.75.10.rev
$TTL 604800
@   IN  SOA ns1.k23.com. admin.k23.com. (
        2025110101 3600 900 1209600 300 )
@   IN  NS  ns1.k23.com.
@   IN  NS  ns2.k23.com.

3   IN  PTR erendis.k23.com.
4   IN  PTR amdir.k23.com.


#Kalau baru mengubah, naikkan serial (mis. 2025110102).

#Validasi & reload:

named-checkzone 3.75.10.in-addr.arpa /etc/bind/zones/db.3.75.10.rev
pkill -f "named -u bind" 2>/dev/null || true
named -u bind -c /etc/bind/named.conf


#(Jika perlu) buka port 53 untuk Amdir:

iptables -C INPUT -p tcp --dport 53 -s 10.75.3.4 -j ACCEPT || iptables -I INPUT -p tcp --dport 53 -s 10.75.3.4 -j ACCEPT
iptables -C INPUT -p udp --dport 53 -s 10.75.3.4 -j ACCEPT || iptables -I INPUT -p udp --dport 53 -s 10.75.3.4 -j ACCEPT

#B. Pastikan slave siap menerima zona reverse

# Amdir (10.75.3.4 – SLAVE)

#Blok zona slave untuk reverse:

# /etc/bind/named.conf.local
zone "3.75.10.in-addr.arpa" {
  type slave;
  masters { 10.75.3.3; };                 // Erendis
  file "/var/cache/bind/db.3.75.10.rev";  // akan ditulis otomatis
  allow-notify { 10.75.3.3; };
};


#Pastikan direktori & izin ada:

mkdir -p /var/cache/bind
chown -R bind:bind /var/cache/bind


#Reload BIND agar memicu transfer:

pkill -f "named -u bind" 2>/dev/null || true
named -u bind -c /etc/bind/named.conf
sleep 1
ls -l /var/cache/bind/db.3.75.10.rev


#Kalau file belum muncul, cek log:

tail -n 80 /var/log/named.log


#Error yang sering:

#transfer failed/refused → cek allow-transfer/firewall di Erendis.

#not authoritative → salah nama zona (“3.75.10.in-addr.arpa” harus sama persis).

#permission denied → perbaiki chown di /var/cache/bind.

#C. Paksa uji transfer dari slave (diagnostik cepat)

#  Amdir

dig @10.75.3.3 3.75.10.in-addr.arpa SOA +noall +answer
dig @10.75.3.3 3.75.10.in-addr.arpa AXFR | head


#Jika AXFR masih “Transfer failed”, masalahnya di sisi Erendis (izin/iptables/serial).

#Jika AXFR sukses, tapi file belum dibuat, cek langkah B.2/B.3 (izin & reload).

#D. Verifikasi akhir (sesuai tuntutan nomor 5)

# Dari klien mana saja (mis. Minastir/Elendil)

#Alias www (CNAME) ke k23.com:

dig @10.75.3.3 www.k23.com +noall +answer
dig @10.75.3.4 www.k23.com +noall +answer


#TXT “Cincin Sauron” & “Aliansi Terakhir”:

dig @10.75.3.3 TXT elros.k23.com +noall +answer
dig @10.75.3.4 TXT elros.k23.com +noall +answer
dig @10.75.3.3 TXT pharazon.k23.com +noall +answer
dig @10.75.3.4 TXT pharazon.k23.com +noall +answer


#Reverse PTR:

dig -x 10.75.3.3 @10.75.3.3 +noall +answer   # → erendis.k23.com.
dig -x 10.75.3.4 @10.75.3.4 +noall +answer   # → amdir.k23.com.


#Serial zona reverse harus sama di master & slave:

dig @10.75.3.3 SOA 3.75.10.in-addr.arpa +noall +answer
dig @10.75.3.4 SOA 3.75.10.in-addr.arpa +noall +answer