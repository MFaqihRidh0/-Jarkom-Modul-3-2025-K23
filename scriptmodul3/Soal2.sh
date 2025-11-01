#konfigurasi DHCP Server aldarion
apt-get update
apt-get install isc-dhcp-server
dhcpd --version

# nano /etc/default/isc-dhcp-server
INTERFACES="eth0"

#nano /etc/dhcp/dhcpd.conf

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

# Buat file leases jika belum ada
mkdir -p /var/lib/dhcp
[ -f /var/lib/dhcp/dhcpd.leases ] || touch /var/lib/dhcp/dhcpd.leases

# Cek sintaks lalu restart
dhcpd -4 -t -cf /etc/dhcp/dhcpd.conf
service isc-dhcp-server restart
service isc-dhcp-server status

#konfigurasi DHCP relay 
apt-get update
apt-get install isc-dhcp-relay -y
service isc-dhcp-relay start

#nano /etc/default/isc-dhcp-relay
SERVERS="10.75.4.2"
INTERFACES="eth1 eth2 eth3 eth4 eth5"   # semua interface LAN Durin
OPTIONS=""