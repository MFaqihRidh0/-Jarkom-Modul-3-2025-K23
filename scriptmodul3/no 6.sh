authoritative;

# ===== Subnet 1: Keluarga Manusia (10.75.1.0/24) =====
subnet 10.75.1.0 netmask 255.255.255.0 {
  option routers           10.75.1.1;
  option subnet-mask       255.255.255.0;
  option broadcast-address 10.75.1.255;
  option domain-name-servers 10.75.5.2;   # DNS Minastir (ubah bila perlu)
  option domain-name "k23.com";

  # Default untuk subnet Manusia (boleh tetap ada)
  default-lease-time 1800;    # 30 menit
  max-lease-time     3600;    # 60 menit

  # Pool dinamis Manusia + lease time spesifik (override subnet)
  pool {
    range 10.75.1.6  10.75.1.34;
    default-lease-time 1800;  # 30 menit
    max-lease-time     3600;  # 60 menit
  }
  pool {
    range 10.75.1.68 10.75.1.94;
    default-lease-time 1800;  # 30 menit
    max-lease-time     3600;  # 60 menit
  }
}

# ===== Subnet 2: Keluarga Peri (10.75.2.0/24) =====
subnet 10.75.2.0 netmask 255.255.255.0 {
  option routers           10.75.2.1;
  option subnet-mask       255.255.255.0;
  option broadcast-address 10.75.2.255;
  option domain-name-servers 192.168.122.1;  # atau 10.75.5.2 jika ingin via Minastir

  # Default untuk subnet Peri
  default-lease-time 600;     # 10 menit
  max-lease-time     3600;    # 60 menit

  # Pool dinamis Peri + lease time spesifik
  pool {
    range 10.75.2.35 10.75.2.67;
    default-lease-time 600;   # 10 menit
    max-lease-time     3600;  # 60 menit
  }
  pool {
    range 10.75.2.96 10.75.2.121;
    default-lease-time 600;   # 10 menit
    max-lease-time     3600;  # 60 menit
  }
}

# ===== Subnet 3: Segmen Khamul (10.75.3.0/24) =====
# Tidak ada pool dinamis; hanya opsi & reservasi Khamul
subnet 10.75.3.0 netmask 255.255.255.0 {
  option routers           10.75.3.1;
  option subnet-mask       255.255.255.0;
  option broadcast-address 10.75.3.255;
  option domain-name-servers 192.168.122.1;  # atau 10.75.5.2
}

# Reservasi agar Khamul SELALU mendapat 10.75.3.95
host khamul {
  hardware ethernet AA:BB:CC:DD:EE:FF;   # GANTI dengan MAC eth0 Khamul
  fixed-address 10.75.3.95;
}

# ===== Subnet 4: Lokal Aldarion (10.75.4.0/24) =====
subnet 10.75.4.0 netmask 255.255.255.0 { }
