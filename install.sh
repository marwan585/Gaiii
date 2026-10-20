#!/bin/bash

# ====================================================================
#  CLOUD SERVER - PTERODACTYL THEME AUTOINSTALLER
#  Version: 2.0
#  Recode By: Cloud Server
#  Original: FOXSTORE
# ====================================================================

# Color palette
BLUE='\033[0;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# ====================================================================
# 2D LOADING ANIMATION - CLOUD SERVER
# Animasi awal saat masuk panel
# ====================================================================
loading_animation() {
  # Frame-frame awan Cloud Server 2D
  declare -a CLOUD_FRAMES=(
"           .--.
        .-'   '-.
       /         \\
      |  CLOUD   |
      |  SERVER  |
       \\         /
        '-.   .-'
           '-'"

"           .--.
        .-'   '-.
       /  [ ]    \\
      |  CLOUD   |
      |  SERVER  |
       \\    [ ]  /
        '-.   .-'
           '-'"

"           .--.
        .-'   '-.
       /  [-]    \\
      |  CLOUD   |
      |  SERVER  |
       \\    [-]  /
        '-.   .-'
           '-'"

"           .--.
        .-'   '-.
       /  [\\|/]  \\
      |  CLOUD   |
      |  SERVER  |
       \\   [/|\\]  /
        '-.   .-'
           '-'"
  )

  declare -a PHASES=(
    "Initializing Cloud Server Engine..."
    "Loading Network Stack..."
    "Connecting to Pterodactyl Panel..."
    "Verifying System Permissions..."
    "Mounting Storage Volumes..."
    "Establishing Secure Connection..."
    "Cloud Server Ready!"
  )

  TOTAL_PHASES=${#PHASES[@]}
  BAR_WIDTH=40

  # Hide cursor selama animasi
  tput civis 2>/dev/null || true

  for i in "${!PHASES[@]}"; do
    # Clear screen
    clear
    echo -e ""
    echo -e "${CYAN}${BOLD}"
    # Tampilkan frame awan
    echo "${CLOUD_FRAMES[$(( i % ${#CLOUD_FRAMES[@]} ))]}"
    echo -e "${NC}"
    echo -e "  ${MAGENTA}Cloud Server Autoinstaller${NC} ${DIM}v2.0${NC}"
    echo -e "  ${DIM}----------------------------------------${NC}"
    echo -e ""
    echo -e "  ${YELLOW}${PHASES[$i]}${NC}"
    echo -e ""

    # Progress bar
    PROGRESS=$(( (i + 1) * BAR_WIDTH / TOTAL_PHASES ))
    printf "  ${GREEN}["
    for j in $(seq 1 $BAR_WIDTH); do
      if [ $j -le $PROGRESS ]; then
        printf "█"
      else
        printf "${DIM}░${NC}${GREEN}"
      fi
    done
    printf "${NC}]${NC}"
    PERCENT=$(( (i + 1) * 100 / TOTAL_PHASES ))
    printf " ${WHITE}%3d%%${NC}\n" "$PERCENT"
    echo -e ""
    echo -e "  ${DIM}Cloud Server © All Rights Reserved${NC}"

    sleep 0.6
  done

  # Tampilkan cursor kembali
  tput cnorm 2>/dev/null || true
  sleep 1
  clear
}

# ====================================================================
# Display welcome message
# ====================================================================
display_welcome() {
  echo -e ""
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "${BLUE}[+]                                                 [+]${NC}"
  echo -e "${BLUE}[+]                AUTO INSTALLER THEMA             [+]${NC}"
  echo -e "${BLUE}[+]                  © CLOUD SERVER                  [+]${NC}"
  echo -e "${BLUE}[+]                                                 [+]${NC}"
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e ""
  echo -e "script ini di buat untuk mempermudah penginstalasian thema pterodactyle,"
  echo -e "Dilarang Keras Share Bebas."
  echo -e ""
  echo -e "${YELLOW}Telegram  :${NC} t.me/CloudServer"
  echo -e "${YELLOW}WhatsApp  :${NC} @CloudServer"
  echo -e "${YELLOW}Credit   :${NC} Cloud Server"
  echo -e ""
  sleep 3
  clear
}

# ====================================================================
# Token validation (Kode Token : cloud)
# ====================================================================
check_token() {
  echo -e ""
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "${BLUE}[+]              VERIFIKASI AKSES                   [+]${NC}"
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e ""
  echo -e "${YELLOW}Masukkan Kode Token untuk melanjutkan:${NC}"
  read -r TOKEN
  if [ "$TOKEN" != "cloud" ]; then
    echo -e "${RED}[!] Kode token salah! Akses ditolak.${NC}"
    echo -e "${DIM}    Hint: Kode token adalah 'cloud'${NC}"
    sleep 2
    exit 1
  fi
  echo -e "${GREEN}[+] Token valid! Melanjutkan...${NC}"
  sleep 1
  clear
}

# ====================================================================
# Update and install jq
# ====================================================================
install_jq() {
  echo -e "                                                       "
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "${BLUE}[+]             UPDATE & INSTALL JQ                 [+]${NC}"
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  sudo apt update && sudo apt install -y jq
  if [ $? -eq 0 ]; then
    echo -e "                                                       "
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "${GREEN}[+]              INSTALL JQ BERHASIL                [+]${NC}"
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
  else
    echo -e "                                                       "
    echo -e "${RED}[+] =============================================== [+]${NC}"
    echo -e "${RED}[+]              INSTALL JQ GAGAL                   [+]${NC}"
    echo -e "${RED}[+] =============================================== [+]${NC}"
    exit 1
  fi
  echo -e "                                                       "
  sleep 1
  clear
}

# ====================================================================
# Install theme (Stellar / Billing / Enigma)
# ====================================================================
install_theme() {
  while true; do
    echo -e "                                                       "
    echo -e "${BLUE}[+] =============================================== [+]${NC}"
    echo -e "${BLUE}[+]                   SELECT THEME                  [+]${NC}"
    echo -e "${BLUE}[+] =============================================== [+]${NC}"
    echo -e "                                                       "
    echo -e "PILIH THEME YANG INGIN DI INSTALL"
    echo "1. stellar"
    echo "2. billing"
    echo "3. enigma"
    echo "x. kembali"
    echo -e "masukan pilihan (1/2/3/x) :"
    read -r SELECT_THEME
    case "$SELECT_THEME" in
      1)
        THEME_URL="https://github.com/marwan585/Gaiii/raw/refs/heads/main/stellar.zip"
        break
        ;;
      2)
        THEME_URL="https://github.com/marwan585/Gaiii/raw/refs/heads/main/billing.zip"
        break
        ;;
      3)
        THEME_URL="https://github.com/marwan585/Gaiii/raw/refs/heads/main/enigma.zip"
        break
        ;;
      x)
        return
        ;;
      *)
        echo -e "${RED}Pilihan tidak valid, silahkan coba lagi.${NC}"
        ;;
    esac
  done

  if [ -e /root/pterodactyl ]; then
    sudo rm -rf /root/pterodactyl
  fi
  wget -q "$THEME_URL"
  sudo unzip -o "$(basename "$THEME_URL")"

  if [ "$SELECT_THEME" -eq 1 ]; then
    echo -e "                                                       "
    echo -e "${BLUE}[+] =============================================== [+]${NC}"
    echo -e "${BLUE}[+]                  INSTALLASI THEMA               [+]${NC}"
    echo -e "${BLUE}[+] =============================================== [+]${NC}"
    echo -e "                                                                   "
    sudo cp -rfT /root/pterodactyl /var/www/pterodactyl
    curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt install -y nodejs
    sudo npm i -g yarn
    cd /var/www/pterodactyl
    yarn add react-feather
    php artisan migrate
    yarn build:production
    php artisan view:clear
    sudo rm /root/stellar.zip
    sudo rm -rf /root/pterodactyl

    echo -e "                                                       "
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "${GREEN}[+]                   INSTALL SUCCESS               [+]${NC}"
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e ""
    sleep 2
    clear
    exit 0

  elif [ "$SELECT_THEME" -eq 2 ]; then
    echo -e "                                                       "
    echo -e "${BLUE}[+] =============================================== [+]${NC}"
    echo -e "${BLUE}[+]                  INSTALLASI THEMA               [+]${NC}"
    echo -e "${BLUE}[+] =============================================== [+]${NC}"
    echo -e "                                                       "
    sudo cp -rfT /root/pterodactyl /var/www/pterodactyl
    curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt install -y nodejs
    npm i -g yarn
    cd /var/www/pterodactyl
    yarn add react-feather
    php artisan billing:install stable
    php artisan migrate
    yarn build:production
    php artisan view:clear
    sudo rm /root/billing.zip
    sudo rm -rf /root/pterodactyl

    echo -e "                                                       "
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "${GREEN}[+]                  INSTALL SUCCESS                [+]${NC}"
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "                                                       "
    sleep 2
    clear
    return

  elif [ "$SELECT_THEME" -eq 3 ]; then
    echo -e "                                                       "
    echo -e "${BLUE}[+] =============================================== [+]${NC}"
    echo -e "${BLUE}[+]                  INSTALLASI THEMA               [+]${NC}"
    echo -e "${BLUE}[+] =============================================== [+]${NC}"
    echo -e "                                                                   "

    echo -e "${YELLOW}Masukkan link wa (https://wa.me...) : ${NC}"
    read LINK_WA
    echo -e "${YELLOW}Masukkan link group (https://.....) : ${NC}"
    read LINK_GROUP
    echo -e "${YELLOW}Masukkan link channel (https://...) : ${NC}"
    read LINK_CHNL

    sudo sed -i "s|LINK_WA|$LINK_WA|g" /root/pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx
    sudo sed -i "s|LINK_GROUP|$LINK_GROUP|g" /root/pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx
    sudo sed -i "s|LINK_CHNL|$LINK_CHNL|g" /root/pterodactyl/resources/scripts/components/dashboard/DashboardContainer.tsx

    sudo cp -rfT /root/pterodactyl /var/www/pterodactyl
    curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    sudo apt install -y nodejs
    sudo npm i -g yarn
    cd /var/www/pterodactyl
    yarn add react-feather
    php artisan migrate
    yarn build:production
    php artisan view:clear
    sudo rm /root/enigma.zip
    sudo rm -rf /root/pterodactyl

    echo -e "                                                       "
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e "${GREEN}[+]                   INSTALL SUCCESS               [+]${NC}"
    echo -e "${GREEN}[+] =============================================== [+]${NC}"
    echo -e ""
    sleep 5
  else
    echo ""
    echo "Pilihan tidak valid. silahkan pilih 1/2/3."
  fi
}

# ====================================================================
# Uninstall theme (kembali ke default)
# ====================================================================
uninstall_theme() {
  echo -e "                                                       "
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "${BLUE}[+]                    DELETE THEME                 [+]${NC}"
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  bash <(curl https://raw.githubusercontent.com/marwan585/Gaiii/master/repair.sh)
  echo -e "                                                       "
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "${GREEN}[+]                 DELETE THEME SUKSES             [+]${NC}"
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  sleep 2
  clear
}

# ====================================================================
# Install Stellar theme (langsung)
# ====================================================================
install_themeSteeler() {
  echo -e "                                                       "
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "${BLUE}[+]                  INSTALLASI THEMA               [+]${NC}"
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "                                                                   "

  wget -O /root/stellar.zip https://github.com/marwan585/Gaiii/raw/refs/heads/main/stellar.zip
  unzip /root/stellar.zip -d /root/pterodactyl
  sudo cp -rfT /root/pterodactyl /var/www/pterodactyl

  curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
  sudo apt install -y nodejs
  sudo npm i -g yarn

  cd /var/www/pterodactyl
  yarn add react-feather
  php artisan migrate
  yarn build:production
  php artisan view:clear

  sudo rm /root/stellar.zip
  sudo rm -rf /root/pterodactyl

  echo -e "                                                       "
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "${GREEN}[+]                   INSTALL SUCCESS               [+]${NC}"
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e ""
  sleep 2
  clear
  exit 0
}

# ====================================================================
# Create node & location
# ====================================================================
create_node() {
  echo -e "                                                       "
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "${BLUE}[+]                    CREATE NODE                  [+]${NC}"
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "                                                       "

  read -p "Masukkan nama lokasi: " location_name
  read -p "Masukkan deskripsi lokasi: " location_description
  read -p "Masukkan domain: " domain
  read -p "Masukkan nama node: " node_name
  read -p "Masukkan RAM (dalam MB): " ram
  read -p "Masukkan jumlah maksimum disk space (dalam MB): " disk_space
  read -p "Masukkan Locid: " locid

  cd /var/www/pterodactyl || { echo "Direktori tidak ditemukan"; exit 1; }

  php artisan p:location:make <<EOF
$location_name
$location_description
EOF

  php artisan p:node:make <<EOF
$node_name
$location_description
$locid
https
$domain
yes
no
no
$ram
$ram
$disk_space
$disk_space
100
8080
2022
/var/lib/pterodactyl/volumes
EOF

  echo -e "                                                       "
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "${GREEN}[+]        CREATE NODE & LOCATION SUKSES             [+]${NC}"
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  sleep 2
  clear
  exit 0
}

# ====================================================================
# Uninstall panel (existing - menggunakan pterodactyl-installer.se)
# ====================================================================
uninstall_panel() {
  echo -e "                                                       "
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "${BLUE}[+]                    UNINSTALL PANEL              [+]${NC}"
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "                                                       "

  bash <(curl -s https://pterodactyl-installer.se) <<EOF
y
y
y
y
EOF

  echo -e "                                                       "
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "${GREEN}[+]                 UNINSTALL PANEL SUKSES           [+]${NC}"
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  sleep 2
  clear
  exit 0
}

# ====================================================================
# Configure Wings
# ====================================================================
configure_wings() {
  echo -e "                                                       "
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "${BLUE}[+]                    CONFIGURE WINGS              [+]${NC}"
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "                                                       "

  read -p "Masukkan token Configure menjalankan wings: " wings
  eval "$wings"
  sudo systemctl start wings

  echo -e "                                                       "
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "${GREEN}[+]                 CONFIGURE WINGS SUKSES           [+]${NC}"
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  sleep 2
  clear
  exit 0
}

# ====================================================================
# Hack back panel (tambah user admin)
# ====================================================================
hackback_panel() {
  echo -e "                                                       "
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "${BLUE}[+]                    HACK BACK PANEL              [+]${NC}"
  echo -e "${BLUE}[+] =============================================== [+]${NC}"
  echo -e "                                                       "

  read -p "Masukkan Username Panel: " user
  read -p "password login: " psswdhb

  cd /var/www/pterodactyl || { echo "Direktori tidak ditemukan"; exit 1; }

  php artisan p:user:make <<EOF
yes
hackback@gmail.com
$user
$user
$user
$psswdhb
EOF

  echo -e "                                                       "
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "${GREEN}[+]                 AKUN TELAH DI ADD                [+]${NC}"
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  sleep 2
  exit 0
}

# ====================================================================
# Ubah password VPS
# ====================================================================
ubahpw_vps() {
  echo -e "                                                       "
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "${GREEN}[+]                    UBAH PASSWORD VPS            [+]${NC}"
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "                                                       "

  read -p "Masukkan Pw Baru: " pw
  read -p "Masukkan Ulang Pw Baru: " pw2

  if [ "$pw" != "$pw2" ]; then
    echo -e "${RED}[!] Password tidak cocok!${NC}"
    sleep 2
    return
  fi

  passwd <<EOF
$pw
$pw
EOF

  echo -e "                                                       "
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "${GREEN}[+]                 GANTI PW VPS SUKSES             [+]${NC}"
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  sleep 2
  exit 0
}

# ####################################################################
# ===================== FITUR BARU v2.0 ==============================
# ####################################################################

# ====================================================================
# UNINSTALL CLOUD - HAPUS SEMUA TENTANG PTERODACTYL OTOMATIS
# Menghapus: services, panel, wings, database, user, cron, nginx, dll
# ====================================================================
uninstall_cloud() {
  echo -e "                                                       "
  echo -e "${RED}[+] =============================================== [+]${NC}"
  echo -e "${RED}[+]              UNINSTALL CLOUD - FULL WIPE        [+]${NC}"
  echo -e "${RED}[+] =============================================== [+]${NC}"
  echo -e "${RED}[+]  SEMUA DATA PTERODACTYL AKAN DIHAPUS PERMANEN  [+]${NC}"
  echo -e "${RED}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  echo -e "${YELLOW}PERINGATAN:${NC}"
  echo -e "  Operasi ini akan menghapus SECARA TOTAL semua komponen"
  echo -e "  Pterodactyl di server Anda, termasuk:"
  echo -e "  ${CYAN}•${NC} Pterodactyl Panel (/var/www/pterodactyl)"
  echo -e "  ${CYAN}•${NC} Wings Daemon (/etc/systemd/system/wings.service)"
  echo -e "  ${CYAN}•${NC} Database MySQL 'pterodactyl'"
  echo -e "  ${CYAN}•${NC} User system 'pterodactyl'"
  echo -e "  ${CYAN}•${NC} Nginx/Apache vhost untuk pterodactyl"
  echo -e "  ${CYAN}•${NC} Cron jobs & systemd units terkait"
  echo -e "  ${CYAN}•${NC} /var/lib/pterodactyl, /etc/pterodactyl"
  echo -e "  ${CYAN}•${NC} /root/pterodactyl, /root/*.zip"
  echo -e "                                                       "

  # Konfirmasi ganda untuk safety
  read -p "Yakin ingin LANJUT? Ketik 'UNINSTALL' (huruf besar) untuk konfirmasi: " CONFIRM
  if [ "$CONFIRM" != "UNINSTALL" ]; then
    echo -e "${GREEN}[+] Operasi dibatalkan. Aman.${NC}"
    sleep 2
    return
  fi

  read -p "Konfirmasi sekali lagi (ketik 'YES'): " CONFIRM2
  if [ "$CONFIRM2" != "YES" ]; then
    echo -e "${GREEN}[+] Operasi dibatalkan. Aman.${NC}"
    sleep 2
    return
  fi

  echo -e "                                                       "
  echo -e "${BLUE}[+] Memulai proses uninstall penuh...${NC}"
  echo -e "                                                       "
  sleep 1

  # Daftar langkah uninstall (auto, tanpa interaksi user)
  declare -a STEPS=(
    "1|Stop & disable systemd services (wings, pterodactyl workers)"
    "2|Stop web server (nginx/apache2) terkait pterodactyl"
    "3|Stop & disable redis (jika khusus pterodactyl)"
    "4|Hapus pterodactyl panel directory /var/www/pterodactyl"
    "5|Hapus wings binary & config /etc/pterodactyl, /usr/local/bin/wings"
    "6|Hapus systemd unit files (pterodactyl.service, wings.service, ptq*.service)"
    "7|Reload systemd daemon"
    "8|Drop database MySQL 'pterodactyl' & user DB"
    "9|Hapus Nginx/Apache vhost untuk pterodactyl"
    "10|Hapus cron jobs pterodactyl"
    "11|Hapus user system 'pterodactyl'"
    "12|Hapus direktori sisa: /var/lib/pterodactyl, /var/log/pterodactyl"
    "13|Hapus file sementara di /root (pterodactyl/, *.zip)"
    "14|Cleanup: apt autoremove, clear cache"
    "15|Finalisasi: daemon-reload, restart web server"
  )

  TOTAL_STEPS=${#STEPS[@]}
  BAR_WIDTH=35

  for step in "${STEPS[@]}"; do
    NUM="${step%%|*}"
    DESC="${step##*|}"
    clear
    echo -e "                                                       "
    echo -e "${RED}[+] =============================================== [+]${NC}"
    echo -e "${RED}[+]              UNINSTALL CLOUD IN PROGRESS       [+]${NC}"
    echo -e "${RED}[+] =============================================== [+]${NC}"
    echo -e "                                                       "
    echo -e "  ${CYAN}Step ${NUM}/${TOTAL_STEPS}${NC}: ${DESC}"
    echo -e "                                                       "

    # Progress bar
    PROGRESS=$(( NUM * BAR_WIDTH / TOTAL_STEPS ))
    printf "  ${GREEN}["
    for j in $(seq 1 $BAR_WIDTH); do
      if [ $j -le $PROGRESS ]; then
        printf "█"
      else
        printf "${DIM}░${NC}${GREEN}"
      fi
    done
    PERCENT=$(( NUM * 100 / TOTAL_STEPS ))
    printf "${NC}] %3d%%${NC}\n" "$PERCENT"
    echo -e "                                                       "

    # Eksekusi step yang sesuai
    case "$NUM" in
      1)
        sudo systemctl stop wings 2>/dev/null || true
        sudo systemctl disable wings 2>/dev/null || true
        sudo systemctl stop 'pteroq.service' 2>/dev/null || true
        sudo systemctl disable 'pteroq.service' 2>/dev/null || true
        # Stop semua service yang namanya mengandung "ptero"
        for svc in $(systemctl list-units --type=service --all 2>/dev/null | grep -i ptero | awk '{print $1}'); do
          sudo systemctl stop "$svc" 2>/dev/null || true
          sudo systemctl disable "$svc" 2>/dev/null || true
        done
        ;;
      2)
        sudo systemctl stop nginx 2>/dev/null || true
        sudo systemctl stop apache2 2>/dev/null || true
        ;;
      3)
        # Hanya stop redis, jangan remove (redis bisa untuk service lain)
        sudo systemctl stop redis-server 2>/dev/null || true
        ;;
      4)
        sudo rm -rf /var/www/pterodactyl 2>/dev/null || true
        ;;
      5)
        sudo rm -rf /etc/pterodactyl 2>/dev/null || true
        sudo rm -f /usr/local/bin/wings 2>/dev/null || true
        sudo rm -f /usr/bin/wings 2>/dev/null || true
        ;;
      6)
        sudo rm -f /etc/systemd/system/pterodactyl.service 2>/dev/null || true
        sudo rm -f /etc/systemd/system/wings.service 2>/dev/null || true
        sudo rm -f /etc/systemd/system/pteroq.service 2>/dev/null || true
        sudo rm -f /etc/systemd/system/pteroq@.service 2>/dev/null || true
        # Hapus semua unit file yang mengandung "ptero"
        for f in /etc/systemd/system/*ptero*.service /etc/systemd/system/*wings*.service; do
          [ -e "$f" ] && sudo rm -f "$f"
        done
        ;;
      7)
        sudo systemctl daemon-reload 2>/dev/null || true
        ;;
      8)
        # Drop database pterodactyl jika mysql/mariadb terinstall
        if command -v mysql &>/dev/null; then
          # Coba beberapa cara koneksi DB
          sudo mysql -e "DROP DATABASE IF EXISTS pterodactyl;" 2>/dev/null || \
          sudo mysql -u root -e "DROP DATABASE IF EXISTS pterodactyl;" 2>/dev/null || true
          sudo mysql -e "DROP USER IF EXISTS 'pterodactyl'@'localhost';" 2>/dev/null || \
          sudo mysql -u root -e "DROP USER IF EXISTS 'pterodactyl'@'localhost';" 2>/dev/null || true
          sudo mysql -e "DROP USER IF EXISTS 'pterodactyl'@'127.0.0.1';" 2>/dev/null || true
          echo -e "    ${DIM}(database dropped)${NC}"
        else
          echo -e "    ${DIM}(mysql tidak ditemukan, skip)${NC}"
        fi
        ;;
      9)
        # Hapus vhost nginx untuk pterodactyl
        sudo rm -f /etc/nginx/sites-enabled/pterodactyl.conf 2>/dev/null || true
        sudo rm -f /etc/nginx/sites-available/pterodactyl.conf 2>/dev/null || true
        sudo rm -f /etc/nginx/conf.d/pterodactyl.conf 2>/dev/null || true
        # Hapus vhost apache
        sudo rm -f /etc/apache2/sites-enabled/pterodactyl.conf 2>/dev/null || true
        sudo rm -f /etc/apache2/sites-available/pterodactyl.conf 2>/dev/null || true
        ;;
      10)
        # Hapus cron jobs pterodactyl
        if [ -f /etc/cron.d/pterodactyl ]; then
          sudo rm -f /etc/cron.d/pterodactyl
        fi
        # Hapus entry crontab root yang mengandung pterodactyl
        if [ -f /var/spool/cron/crontabs/root ]; then
          sudo sed -i '/pterodactyl/d' /var/spool/cron/crontabs/root 2>/dev/null || true
        fi
        ;;
      11)
        # Hapus user system pterodactyl
        if id "pterodactyl" &>/dev/null; then
          sudo userdel -r pterodactyl 2>/dev/null || sudo userdel pterodactyl 2>/dev/null || true
        fi
        ;;
      12)
        sudo rm -rf /var/lib/pterodactyl 2>/dev/null || true
        sudo rm -rf /var/log/pterodactyl 2>/dev/null || true
        sudo rm -rf /tmp/pterodactyl 2>/dev/null || true
        ;;
      13)
        sudo rm -rf /root/pterodactyl 2>/dev/null || true
        sudo rm -f /root/stellar.zip /root/billing.zip /root/enigma.zip 2>/dev/null || true
        ;;
      14)
        sudo apt-get autoremove -y 2>/dev/null || true
        sudo apt-get clean 2>/dev/null || true
        ;;
      15)
        sudo systemctl daemon-reload 2>/dev/null || true
        sudo systemctl restart nginx 2>/dev/null || sudo systemctl restart apache2 2>/dev/null || true
        ;;
    esac

    sleep 0.8
  done

  # Hasil akhir
  clear
  echo -e "                                                       "
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "${GREEN}[+]           UNINSTALL CLOUD - SELESAI            [+]${NC}"
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  echo -e "  ${CYAN}Berikut yang telah dihapus dari server:${NC}"
  echo -e "  ${GREEN}✓${NC} Pterodactyl Panel & semua file terkait"
  echo -e "  ${GREEN}✓${NC} Wings Daemon & systemd unit files"
  echo -e "  ${GREEN}✓${NC} Database MySQL 'pterodactyl' & user DB"
  echo -e "  ${GREEN}✓${NC} User system 'pterodactyl'"
  echo -e "  ${GREEN}✓${NC} Nginx/Apache vhost configuration"
  echo -e "  ${GREEN}✓${NC} Cron jobs & temporary files"
  echo -e "  ${GREEN}✓${NC} Cache apt dibersihkan"
  echo -e "                                                       "
  echo -e "  ${YELLOW}Server Anda sekarang bersih dari Pterodactyl.${NC}"
  echo -e "  ${YELLOW}Disarankan reboot server untuk hasil optimal.${NC}"
  echo -e "                                                       "
  sleep 4
  clear
  exit 0
}

# ====================================================================
# CARA PENGGUNAAN DARI 0 + PENJELASAN SEMUA OPSI
# Tutorial lengkap untuk user baru
# ====================================================================
cara_penggunaan() {
  clear
  echo -e "                                                       "
  echo -e "${CYAN}[+] =============================================== [+]${NC}"
  echo -e "${CYAN}[+]         CARA PENGGUNAAN DARI NOL (0)           [+]${NC}"
  echo -e "${CYAN}[+]         CLOUD SERVER AUTOINSTALLER v2.0       [+]${NC}"
  echo -e "${CYAN}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  pause_for_user

  # ---------- TAHAP 1: SYARAT AWAL ----------
  clear
  echo -e "${YELLOW}=== TAHAP 1: PERSIAPAN SERVER ===${NC}"
  echo -e ""
  echo -e "Sebelum menggunakan script ini, pastikan:"
  echo -e ""
  echo -e "  ${CYAN}1.${NC} Server VPS fresh install OS berikut:"
  echo -e "     ${GREEN}✓${NC} Ubuntu 20.04 / 22.04"
  echo -e "     ${GREEN}✓${NC} Debian 10 / 11 / 12"
  echo -e ""
  echo -e "  ${CYAN}2.${NC} Akses root (login sebagai root atau sudo)"
  echo -e "     ${DIM}# sudo -i${NC}"
  echo -e ""
  echo -e "  ${CYAN}3.${NC} Minimum spesifikasi hardware:"
  echo -e "     ${GREEN}✓${NC} RAM: minimal 1 GB (2 GB disarankan)"
  echo -e "     ${GREEN}✓${NC} Disk: minimal 10 GB"
  echo -e "     ${GREEN}✓${NC} CPU: 1 core minimum"
  echo -e ""
  echo -e "  ${CYAN}4.${NC} Pterodactyl Panel sudah terinstall"
  echo -e "     ${DIM}Script ini untuk install TEMA, bukan panel itu sendiri.${NC}"
  echo -e "     ${DIM}Install panel via: https://pterodactyl-installer.se${NC}"
  echo -e ""
  pause_for_user

  # ---------- TAHAP 2: INSTALL SCRIPT ----------
  clear
  echo -e "${YELLOW}=== TAHAP 2: MENJALANKAN SCRIPT INI ===${NC}"
  echo -e ""
  echo -e "Jalankan perintah berikut di terminal sebagai root:"
  echo -e ""
  echo -e "  ${GREEN}bash <(curl -s https://raw.githubusercontent.com/marwan585/Gaiii/master/install.sh)${NC}"
  echo -e ""
  echo -e "Atau, jika menggunakan file lokal:"
  echo -e ""
  echo -e "  ${GREEN}sudo bash install.sh${NC}"
  echo -e ""
  echo -e "Saat diminta, masukkan kode token:"
  echo -e "  ${MAGENTA}Kode Token : cloud${NC}"
  echo -e ""
  echo -e "Setelah token dimasukkan, akan muncul menu utama dengan"
  echo -e "animasi loading Cloud Server dan opsi-opsi pilihan."
  echo -e ""
  pause_for_user

  # ---------- TAHAP 3: MENU UTAMA ----------
  clear
  echo -e "${YELLOW}=== TAHAP 3: PENJELASAN MENU UTAMA ===${NC}"
  echo -e ""
  echo -e "Berikut penjelasan setiap opsi pada menu:"
  echo -e ""
  echo -e "${CYAN}1. Install Theme${NC}"
  echo -e "   ${DIM}Install tema pterodactyl (Stellar / Billing / Enigma)${NC}"
  echo -e "   ${DIM}Pilih salah satu dari 3 tema yang tersedia.${NC}"
  echo -e ""
  echo -e "${CYAN}2. Uninstall Theme${NC}"
  echo -e "   ${DIM}Kembalikan tema ke default pterodactyl (original)${NC}"
  echo -e "   ${DIM}Tidak menghapus panel, hanya menghapus tema custom.${NC}"
  echo -e ""
  echo -e "${CYAN}3. Configure Wings${NC}"
  echo -e "   ${DIM}Konfigurasi Wings Daemon dari auto-deploy token${NC}"
  echo -e "   ${DIM}Token didapat dari panel: Admin > Nodes > tab Deploy.${NC}"
  echo -e "   ${DIM}Paste token ke sini, wings akan otomatis start.${NC}"
  echo -e ""
  echo -e "${CYAN}4. Create Node${NC}"
  echo -e "   ${DIM}Buat lokasi & node baru di panel secara otomatis${NC}"
  echo -e "   ${DIM}Perlu input: nama lokasi, deskripsi, domain, RAM, disk.${NC}"
  echo -e ""
  pause_for_user

  clear
  echo -e "${CYAN}5. Uninstall Panel${NC}"
  echo -e "   ${DIM}Uninstall Pterodactyl Panel via pterodactyl-installer.se${NC}"
  echo -e "   ${DIM}Lebih ringan daripada 'Uninstall Cloud', hanya hapus panel.${NC}"
  echo -e ""
  echo -e "${CYAN}6. Stellar Theme${NC}"
  echo -e "   ${DIM}Install tema Stellar secara langsung (shortcut)${NC}"
  echo -e "   ${DIM}Sama dengan opsi 1 > pilih 1, tapi lebih cepat.${NC}"
  echo -e ""
  echo -e "${CYAN}7. Hack Back Panel${NC}"
  echo -e "   ${DIM}Tambahkan user admin baru ke panel (akses darurat)${NC}"
  echo -e "   ${DIM}Berguna bila lupa password admin. Minta username + pw.${NC}"
  echo -e ""
  echo -e "${CYAN}8. Ubah Pw VPS${NC}"
  echo -e "   ${DIM}Ganti password root VPS dengan cepat${NC}"
  echo -e "   ${DIM}Perlu input password baru (2x konfirmasi).${NC}"
  echo -e ""
  echo -e "${RED}9. Uninstall Cloud  [FITUR BARU v2.0]${NC}"
  echo -e "   ${RED}HAPUS SEMUA TENTANG PTERODACTYL OTOMATIS${NC}"
  echo -e "   ${DIM}Termasuk: panel, wings, database, user, cron,${NC}"
  echo -e "   ${DIM}nginx vhost, systemd units, file sementara.${NC}"
  echo -e "   ${DIM}Hanya gunakan jika ingin reset total server!${NC}"
  echo -e ""
  echo -e "${MAGENTA}10. Cara Penggunaan  [FITUR BARU v2.0]${NC}"
  echo -e "   ${DIM}Tampilkan tutorial ini (yang sedang Anda baca)${NC}"
  echo -e "   ${DIM}Panduan lengkap dari nol + penjelasan semua opsi.${NC}"
  echo -e ""
  echo -e "${CYAN}x. Exit${NC}"
  echo -e "   ${DIM}Keluar dari script Cloud Server${NC}"
  echo -e ""
  pause_for_user

  # ---------- TAHAP 4: ALUR KERJA REKOMENDASI ----------
  clear
  echo -e "${YELLOW}=== TAHAP 4: ALUR KERJA REKOMENDASI (FRESH SERVER) ===${NC}"
  echo -e ""
  echo -e "Untuk user baru, ikuti urutan berikut:"
  echo -e ""
  echo -e "  ${CYAN}STEP 1${NC}  Pastikan server fresh & terinstall pterodactyl panel"
  echo -e "          ${DIM}# bash <(curl -s https://pterodactyl-installer.se)${NC}"
  echo -e ""
  echo -e "  ${CYAN}STEP 2${NC}  Jalankan script ini & masukkan kode token 'cloud'"
  echo -e "          ${DIM}# bash install.sh${NC}"
  echo -e ""
  echo -e "  ${CYAN}STEP 3${NC}  Pilih opsi 1 (Install Theme) > pilih tema"
  echo -e "          ${DIM}1 = Stellar  |  2 = Billing  |  3 = Enigma${NC}"
  echo -e ""
  echo -e "  ${CYAN}STEP 4${NC}  Tunggu proses install (build yarn + migrate)"
  echo -e "          ${DIM}±5-10 menit tergantung spesifikasi server${NC}"
  echo -e ""
  echo -e "  ${CYAN}STEP 5${NC}  (Opsional) Buat node baru lewat opsi 4 (Create Node)"
  echo -e "          ${DIM}Isi: nama lokasi, domain, RAM, disk space, locid${NC}"
  echo -e ""
  echo -e "  ${CYAN}STEP 6${NC}  (Opsional) Configure Wings lewat opsi 3"
  echo -e "          ${DIM}Paste auto-deploy token dari panel > Nodes > Deploy${NC}"
  echo -e ""
  echo -e "  ${CYAN}STEP 7${NC}  Akses panel lewat browser. Selesai!"
  echo -e "          ${DIM}http://domain-anda.com${NC}"
  echo -e ""
  pause_for_user

  # ---------- TAHAP 5: TIPS & TROUBLESHOOTING ----------
  clear
  echo -e "${YELLOW}=== TAHAP 5: TIPS & TROUBLESHOOTING ===${NC}"
  echo -e ""
  echo -e "${CYAN}Tema Enigma butuh 3 link:${NC}"
  echo -e "  ${GREEN}•${NC} Link WhatsApp (https://wa.me...)"
  echo -e "  ${GREEN}•${NC} Link Group (https://...)"
  echo -e "  ${GREEN}•${NC} Link Channel (https://...)"
  echo -e "  ${DIM}Link akan ditampilkan di dashboard tema.${NC}"
  echo -e ""
  echo -e "${CYAN}Jika install gagal di tengah jalan:${NC}"
  echo -e "  ${GREEN}•${NC} Cek koneksi internet (wget, curl butuh akses)"
  echo -e "  ${GREEN}•${NC} Pastikan disk space cukup (min 5 GB free)"
  echo -e "  ${GREEN}•${NC} Cek log di /var/log/syslog"
  echo -e "  ${GREEN}•${NC} Coba opsi 2 (Uninstall Theme) lalu install ulang"
  echo -e ""
  echo -e "${CYAN}Jika ingin RESET TOTAL server:${NC}"
  echo -e "  ${RED}•${NC} Gunakan opsi 9 (Uninstall Cloud) - HATI-HATI!"
  echo -e "  ${DIM}Semua data pterodactyl akan hilang permanen.${NC}"
  echo -e "  ${DIM}Konfirmasi ganda: ketik 'UNINSTALL' lalu 'YES'.${NC}"
  echo -e ""
  echo -e "${CYAN}Jika lupa password admin panel:${NC}"
  echo -e "  ${GREEN}•${NC} Gunakan opsi 7 (Hack Back Panel)"
  echo -e "  ${DIM}Akan dibuatkan user admin baru.${NC}"
  echo -e ""
  echo -e "${CYAN}Setelah install tema, jangan lupa:${NC}"
  echo -e "  ${GREEN}•${NC} Restart nginx: ${DIM}sudo systemctl restart nginx${NC}"
  echo -e "  ${GREEN}•${NC} Restart php-fpm: ${DIM}sudo systemctl restart php8.X-fpm${NC}"
  echo -e "  ${GREEN}•${NC} Clear cache panel: ${DIM}php artisan view:clear${NC}"
  echo -e ""
  pause_for_user

  # ---------- PENUTUP ----------
  clear
  echo -e "                                                       "
  echo -e "${CYAN}[+] =============================================== [+]${NC}"
  echo -e "${CYAN}[+]              END OF TUTORIAL                   [+]${NC}"
  echo -e "${CYAN}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  echo -e "  ${MAGENTA}Cloud Server Autoinstaller${NC} ${DIM}v2.0${NC}"
  echo -e "  ${DIM}Telegram : t.me/CloudServer${NC}"
  echo -e "  ${DIM}WhatsApp : @CloudServer${NC}"
  echo -e "  ${DIM}Credit   : Cloud Server (Recode)${NC}"
  echo -e "  ${DIM}Original : FOXSTORE${NC}"
  echo -e "                                                       "
  echo -e "  ${YELLOW}Tekan ENTER untuk kembali ke menu...${NC}"
  read -r
  clear
}

# Helper: pause until user press Enter
pause_for_user() {
  echo -e ""
  echo -e "${YELLOW}Tekan ENTER untuk lanjut...${NC}"
  read -r
}

# ====================================================================
# MENU 11: INSTALL KEAMANAN (protection.sh)
# ====================================================================
install_security() {
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [ -f "$SCRIPT_DIR/protection.sh" ]; then
    sudo bash "$SCRIPT_DIR/protection.sh"
  else
    bash <(curl -s https://raw.githubusercontent.com/marwan585/Gaiii/master/protection.sh)
  fi
}

# ====================================================================
# MENU 12: UNINSTALL KEAMANAN
# ====================================================================
uninstall_security() {
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [ -f "$SCRIPT_DIR/protection.sh" ]; then
    sudo bash "$SCRIPT_DIR/protection.sh" --uninstall
  else
    bash <(curl -s https://raw.githubusercontent.com/marwan585/Gaiii/master/protection.sh) --uninstall
  fi
}

# ====================================================================
# MENU 14: INSTALL LOADING ANIMATION (loading-animation.sh)
# ====================================================================
install_loading_animation() {
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [ -f "$SCRIPT_DIR/loading-animation.sh" ]; then
    sudo bash "$SCRIPT_DIR/loading-animation.sh"
  else
    bash <(curl -s https://raw.githubusercontent.com/marwan585/Gaiii/master/loading-animation.sh)
  fi
}

# ====================================================================
# MENU 15: UNINSTALL LOADING ANIMATION
# ====================================================================
uninstall_loading_animation() {
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [ -f "$SCRIPT_DIR/loading-animation.sh" ]; then
    sudo bash "$SCRIPT_DIR/loading-animation.sh" --uninstall
  else
    bash <(curl -s https://raw.githubusercontent.com/marwan585/Gaiii/master/loading-animation.sh) --uninstall
  fi
}

# ====================================================================
# MENU 13: AUTO INSTALL FULL
# Panel + Node + Wings + Security + Stellar Theme (1 command)
# ====================================================================
auto_install_full() {
  clear
  echo -e "                                                       "
  echo -e "${MAGENTA}[+] =============================================== [+]${NC}"
  echo -e "${MAGENTA}[+]       AUTO INSTALL FULL - ALL IN ONE          [+]${NC}"
  echo -e "${MAGENTA}[+]  Panel + Node + Wings + Stellar + Security   [+]${NC}"
  echo -e "${MAGENTA}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  echo -e "  ${YELLOW}Script ini akan menginstall SEMUA komponen:${NC}"
  echo -e "  ${CYAN}1${NC}. Pterodactyl Panel       ${DIM}(via pterodactyl-installer.se)${NC}"
  echo -e "  ${CYAN}2${NC}. Wings Daemon           ${DIM}(service game server)${NC}"
  echo -e "  ${CYAN}3${NC}. Location + Node         ${DIM}(via php artisan)${NC}"
  echo -e "  ${CYAN}4${NC}. Tema Stellar            ${DIM}(install langsung)${NC}"
  echo -e "  ${CYAN}5${NC}. Paket Keamanan         ${DIM}(disk-limit + suspicious + admin-1)${NC}"
  echo -e "                                                       "
  echo -e "  ${RED}PERINGATAN:${NC}"
  echo -e "  ${DIM}  • VPS harus FRESH (belum install pterodactyl)${NC}"
  echo -e "  ${DIM}  • Domain harus sudah A-record ke IP VPS${NC}"
  echo -e "  ${DIM}  • Proses total ±30-60 menit tergantung VPS${NC}"
  echo -e "                                                       "
  read -p "Lanjut? (y/n): " yn
  case "$yn" in
    [Yy]*) ;;
    *) return ;;
  esac

  # Cek apakah panel sudah terinstall
  SKIP_PANEL=0
  if [ -d /var/www/pterodactyl ]; then
    echo -e "${YELLOW}  ! Panel sudah terinstall di /var/www/pterodactyl${NC}"
    read -p "Skip install panel & lanjut Wings+Node+Theme+Security? (y/n): " yn2
    case "$yn2" in
      [Yy]*) SKIP_PANEL=1 ;;
      *) echo "Batal."; return ;;
    esac
  fi

  # ---------- KUMPULKAN SEMUA INFO UPFRONT ----------
  clear
  echo -e "${BLUE}=== FORM SETUP (isi semua dulu, lalu proses auto) ===${NC}"
  echo -e ""
  read -p "Domain panel (FQDN, mis. panel.domain.com): " FQDN
  [ -z "$FQDN" ] && { echo -e "${RED}Domain wajib diisi!${NC}"; return; }

  read -p "Email admin (mis. admin@email.com): " ADMIN_EMAIL
  [ -z "$ADMIN_EMAIL" ] && { echo -e "${RED}Email wajib diisi!${NC}"; return; }

  read -p "Username admin (default: admin): " ADMIN_USER
  ADMIN_USER="${ADMIN_USER:-admin}"

  read -s -p "Password admin: " ADMIN_PASS; echo
  [ -z "$ADMIN_PASS" ] && { echo -e "${RED}Password wajib diisi!${NC}"; return; }

  read -p "Timezone (default: Asia/Jakarta): " TIMEZONE
  TIMEZONE="${TIMEZONE:-Asia/Jakarta}"

  read -p "RAM Node (MB, default: 2048): " NODE_RAM
  NODE_RAM="${NODE_RAM:-2048}"

  read -p "Disk Node (MB, default: 20480): " NODE_DISK
  NODE_DISK="${NODE_DISK:-20480}"

  read -p "Batas disk per server (MB, default: 10240): " DISK_LIMIT
  DISK_LIMIT="${DISK_LIMIT:-10240}"

  API_TOKEN=""
  read -p "Admin API Token (opsional, untuk auto-suspend via API - bisa diisi nanti): " API_TOKEN

  # Ringkasan
  clear
  echo -e "${GREEN}=== RINGKASAN YANG AKAN DIINSTALL ===${NC}"
  echo -e "  ${CYAN}Domain   :${NC} $FQDN"
  echo -e "  ${CYAN}Email    :${NC} $ADMIN_EMAIL"
  echo -e "  ${CYAN}Username :${NC} $ADMIN_USER"
  echo -e "  ${CYAN}Password :${NC} $(echo "$ADMIN_PASS" | sed 's/./*/g')"
  echo -e "  ${CYAN}Timezone :${NC} $TIMEZONE"
  echo -e "  ${CYAN}RAM Node :${NC} ${NODE_RAM} MB"
  echo -e "  ${CYAN}Disk Node:${NC} ${NODE_DISK} MB"
  echo -e "  ${CYAN}Disk Limit/server:${NC} ${DISK_LIMIT} MB"
  echo -e "  ${CYAN}API Token:${NC} ${API_TOKEN:+(diisi)}${API_TOKEN:-(kosong, akan pakai docker stop)}"
  echo -e "  ${CYAN}Tema     :${NC} Stellar"
  echo -e "  ${CYAN}Security :${NC} Disk-limit + Suspicious + Admin-1 only"
  echo -e ""
  read -p "Konfirmasi mulai install? (ketik 'MULAI'): " CONFIRM
  [ "$CONFIRM" != "MULAI" ] && { echo "Batal."; return; }

  # ---------- STEP 1: INSTALL PANEL ----------
  if [ "$SKIP_PANEL" -eq 0 ]; then
    clear
    echo -e "${BLUE}=== STEP 1/5: INSTALL PTERODACTYL PANEL ===${NC}"
    echo -e "${YELLOW}Panduan isi installer (gunakan info Anda):${NC}"
    echo -e "  ${CYAN}1${NC}. Pilih: ${GREEN}Panel${NC} (menu 1)"
    echo -e "  ${CYAN}2${NC}. Database: ${GREEN}tekan Enter untuk default${NC} (auto-generate password)"
    echo -e "  ${CYAN}3${NC}. Redis: ${GREEN}tekan Enter untuk default${NC}"
    echo -e "  ${CYAN}4${NC}. Timezone: ${GREEN}$TIMEZONE${NC}"
    echo -e "  ${CYAN}5${NC}. Email admin: ${GREEN}$ADMIN_EMAIL${NC}"
    echo -e "  ${CYAN}6${NC}. Username admin: ${GREEN}$ADMIN_USER${NC}"
    echo -e "  ${CYAN}7${NC}. Password admin: ${GREEN}$ADMIN_PASS${NC}"
    echo -e "  ${CYAN}8${NC}. Domain/FQDN: ${GREEN}$FQDN${NC}"
    echo -e "  ${CYAN}9${NC}. Webserver: ${GREEN}nginx (1)${NC}"
    echo -e "  ${CYAN}10${NC}. SSL Let's Encrypt: ${GREEN}yes${NC} (butuh domain aktif)"
    echo -e "  ${CYAN}11${NC}. Email Let's Encrypt: ${GREEN}$ADMIN_EMAIL${NC}"
    echo -e ""
    echo -e "${YELLOW}Tekan ENTER untuk membuka installer...${NC}"
    read
    bash <(curl -s https://pterodactyl-installer.se)
    clear
    echo -e "${GREEN}✓ Step 1 selesai (Panel)${NC}"
    sleep 2
  else
    echo -e "${YELLOW}⚠ Skip Step 1 (panel sudah ada)${NC}"
    sleep 1
  fi

  # ---------- STEP 2: INSTALL WINGS ----------
  clear
  echo -e "${BLUE}=== STEP 2/5: INSTALL WINGS DAEMON ===${NC}"
  echo -e "${YELLOW}Panduan isi installer:${NC}"
  echo -e "  ${CYAN}1${NC}. Pilih: ${GREEN}Wings${NC} (menu 2)"
  echo -e "  ${CYAN}2${NC}. Panel URL: ${GREEN}https://$FQDN${NC}"
  echo -e "  ${CYAN}3${NC}. SSL: ${GREEN}yes${NC}"
  echo -e ""
  echo -e "${YELLOW}Tekan ENTER untuk membuka installer Wings...${NC}"
  read
  bash <(curl -s https://pterodactyl-installer.se)
  clear
  echo -e "${GREEN}✓ Step 2 selesai (Wings)${NC}"
  sleep 2

  # ---------- STEP 3: CREATE LOCATION + NODE ----------
  clear
  echo -e "${BLUE}=== STEP 3/5: CREATE LOCATION + NODE ===${NC}"
  cd /var/www/pterodactyl 2>/dev/null || { echo -e "${RED}Folder /var/www/pterodactyl tidak ada! Panel belum terinstall?${NC}"; return; }

  echo -e "${DIM}Membuat location default...${NC}"
  php artisan p:location:make <<EOF 2>&1 | tail -3
Default
Lokasi default
EOF

  # Ambil location ID terbaru (asumsi auto-increment, cari ID terbesar)
  LOCID=$(php artisan p:location:list 2>/dev/null | grep -oE '^\| [0-9]+' | grep -oE '[0-9]+' | sort -n | tail -1)
  [ -z "$LOCID" ] && LOCID=1
  echo -e "${DIM}Location ID: $LOCID${NC}"

  echo -e "${DIM}Membuat node utama...${NC}"
  php artisan p:node:make <<EOF 2>&1 | tail -5
Node 1
Node utama
$LOCID
https
$FQDN
yes
no
no
$NODE_RAM
$NODE_RAM
$NODE_DISK
$NODE_DISK
100
8080
2022
/var/lib/pterodactyl/volumes
EOF

  echo -e "${GREEN}✓ Step 3 selesai (Location #$LOCID + Node 1)${NC}"
  sleep 2

  # ---------- STEP 4: INSTALL STELLAR THEME ----------
  clear
  echo -e "${BLUE}=== STEP 4/5: INSTALL STELLAR THEME ===${NC}"

  # Cek apakah sudah install node 16 & yarn
  if ! command -v yarn &>/dev/null; then
    echo -e "${DIM}Setup Node.js & Yarn...${NC}"
    curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash - >/dev/null 2>&1
    sudo apt install -y nodejs >/dev/null 2>&1
    sudo npm i -g yarn >/dev/null 2>&1
  fi

  # Download & extract stellar
  if [ ! -f /root/stellar.zip ]; then
    echo -e "${DIM}Download stellar.zip...${NC}"
    wget -q -O /root/stellar.zip https://github.com/marwan585/Gaiii/raw/refs/heads/master/stellar.zip
  fi

  if [ -e /root/pterodactyl ]; then sudo rm -rf /root/pterodactyl; fi
  sudo unzip -o /root/stellar.zip -d /root/pterodactyl >/dev/null 2>&1
  sudo cp -rfT /root/pterodactyl /var/www/pterodactyl

  cd /var/www/pterodactyl
  echo -e "${DIM}Install dependencies + build...${NC}"
  yarn add react-feather 2>&1 | tail -2
  php artisan migrate 2>&1 | tail -3
  yarn build:production 2>&1 | tail -3
  php artisan view:clear 2>&1 | tail -1
  sudo rm -f /root/stellar.zip
  sudo rm -rf /root/pterodactyl

  echo -e "${GREEN}✓ Step 4 selesai (Stellar theme terpasang)${NC}"
  sleep 2

  # ---------- STEP 5: INSTALL SECURITY ----------
  clear
  echo -e "${BLUE}=== STEP 5/5: INSTALL SECURITY (disk-limit + suspicious + admin-1) ===${NC}"

  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [ -f "$SCRIPT_DIR/security.sh" ]; then
    # Pre-answer security.sh prompts: y (lanjut), disk_limit, panel_url, api_token
    printf 'y\n%s\nhttps://%s\n%s\n' "$DISK_LIMIT" "$FQDN" "$API_TOKEN" | sudo bash "$SCRIPT_DIR/security.sh" 2>&1 | tail -10
  else
    echo -e "${YELLOW}  ! security.sh tidak ditemukan lokal, skip${NC}"
    echo -e "${DIM}    Jalankan manual: pilih menu 11 setelah ini${NC}"
    sleep 2
  fi

  # ---------- SELESAI ----------
  clear
  echo -e "                                                       "
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "${GREEN}[+]       AUTO INSTALL FULL - SELESAI!            [+]${NC}"
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  echo -e "  ${CYAN}Panel URL  :${NC} https://$FQDN"
  echo -e "  ${CYAN}Admin user :${NC} $ADMIN_USER"
  echo -e "  ${CYAN}Admin email:${NC} $ADMIN_EMAIL"
  echo -e "  ${CYAN}Node       :${NC} Node 1 (RAM ${NODE_RAM}MB, Disk ${NODE_DISK}MB)"
  echo -e "  ${CYAN}Tema       :${NC} Stellar"
  echo -e "  ${CYAN}Security   :${NC} Aktif (disk-limit ${DISK_LIMIT}MB/server)"
  echo -e "                                                       "
  echo -e "  ${YELLOW}Langkah selanjutnya yang perlu Anda lakukan manual:${NC}"
  echo -e "  ${GREEN}1${NC}. Buka https://$FQDN → login sebagai $ADMIN_USER"
  echo -e "  ${GREEN}2${NC}. Buat Application API Token (Admin → API)"
  echo -e "  ${GREEN}3${NC}. Set token tsb ke monitor: ${DIM}sudo sed -i 's|__API_TOKEN__|TOKEN_ANDA|' /opt/cloud-server/monitor.sh${NC}"
  echo -e "  ${GREEN}4${NC}. Buat egg (Minecraft, CS:GO, dll) di panel: Admin → Eggs"
  echo -e "  ${GREEN}5${NC}. Buat server test → cek jalan"
  echo -e "                                                       "
  echo -e "  ${YELLOW}Cek log security:${NC}"
  echo -e "  ${DIM}# tail -f /var/log/cloud-server/security.log${NC}"
  echo -e "                                                       "
  sleep 5
  clear
}

# ====================================================================
# MAIN SCRIPT
# ====================================================================
clear

# 1. Jalankan loading animation Cloud Server saat masuk panel
loading_animation

# 2. Welcome message
display_welcome

# 3. Install jq (dependency)
install_jq

# 4. Verifikasi token akses
check_token

# 5. Main menu loop
while true; do
  clear
  echo -e "                                                                     "
  echo -e "${CYAN}        _ . _       ${RED}_,gggggggggg.                                     ${NC}"
  echo -e "${CYAN}      (_) | |     ${RED},ggggggggggggggggg.                                   ${NC}"
  echo -e "${CYAN}      | | | |   ${RED},ggggg        gggggggg.                                 ${NC}"
  echo -e "${CYAN}      | | | |  ${RED},ggg'               'ggg.                                ${NC}"
  echo -e "${CYAN}     _| |_|_|_${RED}',gg       ,ggg.      'ggg:                              ${NC}"
  echo -e "${CYAN}    |__   __|  ${RED}'ggg      ,gg'''  .    ggg       Auto Installer Cloud Server   ${NC}"
  echo -e "${CYAN}       | |     ${RED}gggg      gg     ,     ggg      ---------------------------  ${NC}"
  echo -e "${CYAN}       | |     ${RED}ggg:     gg.     -   ,ggg       • Telegram : t.me/CloudServer   ${NC}"
  echo -e "${CYAN}       | |     ${RED} ggg:     ggg._    _,ggg        • Credit   : Cloud Server    ${NC}"
  echo -e "${CYAN}       | |     ${RED} ggg.    '.'''ggggggp          • Support  : Cloud Server    ${NC}"
  echo -e "${CYAN}       |_|     ${RED}  'ggg    '-.__                                         ${NC}"
  echo -e "${RED}                 ggg                                                   ${NC}"
  echo -e "${RED}                   ggg                                                 ${NC}"
  echo -e "${RED}                     ggg.                                              ${NC}"
  echo -e "${RED}                       ggg.                                            ${NC}"
  echo -e "${RED}                          b.                                           ${NC}"
  echo -e "                                                                     "
  echo -e "${YELLOW}=== BERIKUT LIST MENU ===${NC}"
  echo -e "${CYAN} 1${NC}. Install Theme        ${DIM}(Stellar / Billing / Enigma)${NC}"
  echo -e "${CYAN} 2${NC}. Uninstall Theme      ${DIM}(kembali ke default)${NC}"
  echo -e "${CYAN} 3${NC}. Configure Wings      ${DIM}(setup daemon dari token)${NC}"
  echo -e "${CYAN} 4${NC}. Create Node          ${DIM}(lokasi + node baru)${NC}"
  echo -e "${CYAN} 5${NC}. Uninstall Panel      ${DIM}(uninstall pterodactyl panel)${NC}"
  echo -e "${CYAN} 6${NC}. Stellar Theme        ${DIM}(install langsung stellar)${NC}"
  echo -e "${CYAN} 7${NC}. Hack Back Panel      ${DIM}(tambah admin darurat)${NC}"
  echo -e "${CYAN} 8${NC}. Ubah Pw VPS          ${DIM}(ganti password root)${NC}"
  echo -e "${RED} 9${NC}. ${RED}Uninstall Cloud${NC}      ${DIM}${YELLOW}[NEW]${NC} ${DIM}hapus SEMUA pterodactyl otomatis${NC}"
  echo -e "${MAGENTA}10${NC}. ${MAGENTA}Cara Penggunaan${NC}    ${DIM}${YELLOW}[NEW]${NC} ${DIM}tutorial dari nol + opsi${NC}"
  echo -e "${RED}11${NC}. ${RED}Install Keamanan${NC}    ${DIM}${YELLOW}[NEW]${NC} ${DIM}disk-limit + suspicious + admin-1 only${NC}"
  echo -e "${RED}12${NC}. ${RED}Uninstall Keamanan${NC} ${DIM}${YELLOW}[NEW]${NC} ${DIM}hapus semua paket keamanan${NC}"
  echo -e "${MAGENTA}13${NC}. ${MAGENTA}AUTO INSTALL FULL${NC}   ${DIM}${YELLOW}[NEW v2.2]${NC} ${DIM}Panel+Wings+Node+Stellar+Security 1 klik${NC}"
  echo -e "${CYAN}14${NC}. ${CYAN}Install Loading Anim${NC}  ${DIM}${YELLOW}[NEW v2.3]${NC} ${DIM}pasang animasi Cloud Server ke panel${NC}"
  echo -e "${CYAN}15${NC}. ${CYAN}Uninstall Loading${NC}    ${DIM}${YELLOW}[NEW v2.3]${NC} ${DIM}hapus animasi dari panel${NC}"
  echo -e "${CYAN} x${NC}. Exit"
  echo -e ""
  echo -e "${YELLOW}Masukkan pilihan (1-15/x):${NC} "
  read -r MENU_CHOICE
  clear

  case "$MENU_CHOICE" in
    1) install_theme ;;
    2) uninstall_theme ;;
    3) configure_wings ;;
    4) create_node ;;
    5) uninstall_panel ;;
    6) install_themeSteeler ;;
    7) hackback_panel ;;
    8) ubahpw_vps ;;
    9) uninstall_cloud ;;
    10) cara_penggunaan ;;
    11) install_security ;;
    12) uninstall_security ;;
    13) auto_install_full ;;
    14) install_loading_animation ;;
    15) uninstall_loading_animation ;;
    x)
      echo -e "${GREEN}[+] Keluar dari Cloud Server Autoinstaller.${NC}"
      echo -e "${DIM}    Terima kasih telah menggunakan!${NC}"
      sleep 2
      exit 0
      ;;
    *)
      echo -e "${RED}[!] Pilihan tidak valid, silahkan coba lagi.${NC}"
      sleep 1
      ;;
  esac
done
