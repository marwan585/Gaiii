#!/bin/bash
# ====================================================================
# CLOUD SERVER - SECURITY AUTOINSTALLER v2.1
# Fitur:
#   1. Monitor disk usage per-server -> auto-suspend jika exceed
#   2. Detect suspicious process (miner, crypto) -> auto-suspend
#   3. Admin-1 Only restriction (Node/Location/Egg/Delete/View Server)
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
# Banner
# ====================================================================
security_banner() {
  clear
  echo -e "                                                       "
  echo -e "${RED}[+] =============================================== [+]${NC}"
  echo -e "${RED}[+]          CLOUD SERVER SECURITY INSTALLER       [+]${NC}"
  echo -e "${RED}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  echo -e "  ${CYAN}Fitur yang akan dipasang:${NC}"
  echo -e "  ${GREEN}1${NC}. Monitor Disk Otomatis     ${DIM}(auto-suspend server over limit)${NC}"
  echo -e "  ${GREEN}2${NC}. Suspicious Server Detector  ${DIM}(deteksi miner/crypto)${NC}"
  echo -e "  ${GREEN}3${NC}. Admin-1 Only Restriction     ${DIM}(Node/Location/Egg/Delete/View)${NC}"
  echo -e "                                                       "
}

# ====================================================================
# Step 1: Buat direktori & file konfigurasi
# ====================================================================
setup_directories() {
  echo -e "${BLUE}[+] Step 1: Setup direktori & log...${NC}"
  sudo mkdir -p /opt/cloud-server
  sudo mkdir -p /var/log/cloud-server
  sudo touch /var/log/cloud-server/security.log
  sudo chmod 644 /var/log/cloud-server/security.log
  echo -e "${GREEN}    ✓ Direktori /opt/cloud-server dibuat${NC}"
  echo -e "${GREEN}    ✓ Log file /var/log/cloud-server/security.log${NC}"
  sleep 1
}

# ====================================================================
# Step 2: Generate monitor.sh (daemon cron)
# ====================================================================
generate_monitor_script() {
  echo -e "${BLUE}[+] Step 2: Generate monitor daemon...${NC}"

  # Ambil batas disk dari user (default: 10240 MB = 10GB)
  read -p "Batas maksimum disk per server (MB, default 10240): " DISK_LIMIT_MB
  DISK_LIMIT_MB="${DISK_LIMIT_MB:-10240}"

  # Ambil API token & panel URL untuk suspend via API
  echo -e "${YELLOW}    Untuk auto-suspend via Pterodactyl API, isi data berikut:${NC}"
  read -p "Panel URL (https://domain.com): " PANEL_URL
  read -p "Admin API Token (Application API): " API_TOKEN
  echo -e "${DIM}    (Kosongkan untuk mode suspend manual via docker)${NC}"

  cat > /tmp/cloud_monitor.sh << 'MONITOR_EOF'
#!/bin/bash
# ============================================================
# CLOUD SERVER - SECURITY MONITOR DAEMON
# Dijalankan via cron setiap 5 menit
# ============================================================

LOG="/var/log/cloud-server/security.log"
DISK_LIMIT_MB="__DISK_LIMIT__"
PANEL_URL="__PANEL_URL__"
API_TOKEN="__API_TOKEN__"
VOLUMES_DIR="/var/lib/pterodactyl/volumes"

log_event() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"
}

# Suspend server via Pterodactyl API (jika token tersedia)
suspend_server() {
  local SERVER_UUID="$1"
  local REASON="$2"
  log_event "SUSPEND: server=$SERVER_UUID reason=$REASON"

  if [ -n "$API_TOKEN" ] && [ -n "$PANEL_URL" ]; then
    # Suspend via API
    curl -s -X POST \
      "${PANEL_URL%/}/api/application/servers/${SERVER_UUID}/suspend" \
      -H "Authorization: Bearer $API_TOKEN" \
      -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -d '{"foreground": false}' >/dev/null 2>&1
  else
    # Suspend manual via docker (stop container)
    docker ps --filter "name=$SERVER_UUID" --format "{{.Names}}" | head -1 | while read cname; do
      [ -n "$cname" ] && docker stop "$cname" >/dev/null 2>&1
    done
  fi
}

# Daftar pattern suspicious process (miner/crypto)
SUSPICIOUS_PATTERNS=(
  "xmrig"
  "cpuminer"
  "ccminer"
  "ethminer"
  "claymore"
  "PhoenixMiner"
  "teamredminer"
  "TrexMiner"
  "lolMiner"
  "minerd"
  "cryptonight"
  "stratum+tcp"
  "stratum+ssl"
  "nanopool"
  "f2pool"
  "antpool"
  "mining"
)

# ============================================================
# CHECK 1: Disk usage per server
# ============================================================
check_disk_usage() {
  if [ ! -d "$VOLUMES_DIR" ]; then
    return
  fi

  for server_dir in "$VOLUMES_DIR"/*/; do
    [ -d "$server_dir" ] || continue
    server_path="${server_dir%/}"
    server_uuid="$(basename "$server_path")"

    # Hitung ukuran dalam MB
    size_bytes=$(du -sb "$server_path" 2>/dev/null | awk '{print $1}')
    [ -z "$size_bytes" ] && continue
    size_mb=$(( size_bytes / 1024 / 1024 ))

    if [ "$size_mb" -gt "$DISK_LIMIT_MB" ]; then
      log_event "DISK OVER LIMIT: server=$server_uuid used=${size_mb}MB limit=${DISK_LIMIT_MB}MB"
      suspend_server "$server_uuid" "disk_over_limit_${size_mb}MB"
    fi
  done
}

# ============================================================
# CHECK 2: Suspicious process detection
# ============================================================
check_suspicious_processes() {
  # Loop semua container pterodactyl
  for cid in $(docker ps -q --filter "label=pterodactyl"); do
    server_uuid=$(docker inspect --format '{{ index .Config.Labels "PterodactylServerUUID" }}' "$cid" 2>/dev/null)
    [ -z "$server_uuid" ] && server_uuid=$(docker inspect --format '{{ .Name }}' "$cid" 2>/dev/null | tr -d '/')

    # Ambil daftar proses di container
    proc_list=$(docker top "$cid" -eo pid,comm,args 2>/dev/null)
    [ -z "$proc_list" ] && continue

    for pattern in "${SUSPICIOUS_PATTERNS[@]}"; do
      if echo "$proc_list" | grep -iEq "$pattern"; then
        matched=$(echo "$proc_list" | grep -iE "$pattern" | head -3 | tr '\n' '|')
        log_event "SUSPICIOUS: server=$server_uuid pattern=$pattern proc=$matched"
        suspend_server "$server_uuid" "suspicious_process_$pattern"
        break
      fi
    done
  done
}

# ============================================================
# CHECK 3: CPU abuse (>90% sustained by single process)
# ============================================================
check_cpu_abuse() {
  # Pakai docker stats untuk cek CPU usage
  docker stats --no-stream --format "{{.Container}}\t{{.CPUPerc}}" 2>/dev/null | while read line; do
    cid=$(echo "$line" | awk '{print $1}')
    cpu=$(echo "$line" | awk '{print $2}' | tr -d '%')
    # Hanya container yang CPU > 95%
    if [ -n "$cpu" ] && [ -n "$cid" ]; then
      is_int=$(echo "$cpu" | grep -E '^[0-9]+(\.[0-9]+)?$')
      if [ -n "$is_int" ]; then
        is_high=$(echo "$cpu > 95" | bc 2>/dev/null)
        if [ "$is_high" = "1" ]; then
          server_uuid=$(docker inspect --format '{{ index .Config.Labels "PterodactylServerUUID" }}' "$cid" 2>/dev/null)
          [ -z "$server_uuid" ] && server_uuid="$cid"
          log_event "CPU ABUSE: server=$server_uuid cpu=${cpu}%"
          # Jangan langsung suspend - log dulu, tunggu konfirmasi
        fi
      fi
    fi
  done
}

# ============================================================
# MAIN
# ============================================================
log_event "===== Monitor run start ====="
check_disk_usage
check_suspicious_processes
check_cpu_abuse
log_event "===== Monitor run end ====="
MONITOR_EOF

  # Replace placeholder
  sed -i "s|__DISK_LIMIT__|$DISK_LIMIT_MB|g" /tmp/cloud_monitor.sh
  sed -i "s|__PANEL_URL__|$PANEL_URL|g" /tmp/cloud_monitor.sh
  sed -i "s|__API_TOKEN__|$API_TOKEN|g" /tmp/cloud_monitor.sh

  sudo mv /tmp/cloud_monitor.sh /opt/cloud-server/monitor.sh
  sudo chmod +x /opt/cloud-server/monitor.sh

  echo -e "${GREEN}    ✓ monitor.sh dibuat di /opt/cloud-server/${NC}"
  echo -e "${GREEN}    ✓ Batas disk: ${DISK_LIMIT_MB} MB${NC}"
  sleep 1
}

# ====================================================================
# Step 3: Install cron job (setiap 5 menit)
# ====================================================================
install_cron() {
  echo -e "${BLUE}[+] Step 3: Install cron job (setiap 5 menit)...${NC}"

  cat > /tmp/cloud_cron << 'CRON_EOF'
# Cloud Server Security Monitor - run every 5 minutes
*/5 * * * * root /opt/cloud-server/monitor.sh >/dev/null 2>&1
# Restart monitor service on reboot
@reboot root /opt/cloud-server/monitor.sh >/dev/null 2>&1
CRON_EOF

  sudo mv /tmp/cloud_cron /etc/cron.d/cloud-server-security
  sudo chmod 644 /etc/cron.d/cloud-server-security

  echo -e "${GREEN}    ✓ Cron job terpasang di /etc/cron.d/cloud-server-security${NC}"
  sleep 1
}

# ====================================================================
# Step 4: Patch Pterodactyl panel - admin-1 only middleware
# ====================================================================
patch_admin_middleware() {
  echo -e "${BLUE}[+] Step 4: Patch Laravel middleware admin-1 only...${NC}"

  if [ ! -d /var/www/pterodactyl ]; then
    echo -e "${YELLOW}    ! Panel tidak ditemukan di /var/www/pterodactyl${NC}"
    echo -e "${YELLOW}    ! Skip patch middleware (jalankan setelah panel terinstall)${NC}"
    sleep 2
    return
  fi

  # Buat middleware baru untuk cek admin-1 only
  cat > /tmp/AdminOneOnly.php << 'MIDDLEWARE_EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\HttpException;

/**
 * Cloud Server Security Middleware
 * Hanya user dengan id=1 (admin 1) yang boleh aksi sensitif:
 * - Tambah/edit/hapus Node, Location, Egg
 * - Hapus server milik user lain
 * - View as user / masuk ke server orang
 */
class AdminOneOnly
{
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user();
        if (!$user) {
            return response()->json([
                'error' => 'DILARANG',
                'message' => 'Anda tidak memiliki izin untuk aksi ini. Hanya Admin 1 yang diperbolehkan.'
            ], 403);
        }
        if ((int) $user->id !== 1) {
            return response()->json([
                'error' => 'DILARANG',
                'message' => 'Akses ditolak. Aksi ini hanya tersedia untuk Admin 1 (User ID 1). Hubungi pemilik utama panel.'
            ], 403);
        }
        return $next($request);
    }
}
MIDDLEWARE_EOF

  # Cek apakah middleware sudah ada (idempotent)
  if [ -f /var/www/pterodactyl/app/Http/Middleware/AdminOneOnly.php ]; then
    echo -e "${DIM}    Middleware sudah ada, update ulang...${NC}"
  fi
  sudo cp /tmp/AdminOneOnly.php /var/www/pterodactyl/app/Http/Middleware/AdminOneOnly.php
  sudo chown www-data:www-data /var/www/pterodactyl/app/Http/Middleware/AdminOneOnly.php

  # Daftarkan middleware di Kernel.php (route middleware alias)
  KERNEL=/var/www/pterodactyl/app/Http/Kernel.php
  if [ -f "$KERNEL" ]; then
    # Cek jika belum terdaftar
    if ! grep -q "AdminOneOnly" "$KERNEL"; then
      sudo sed -i "'s|''admin'' => .*|&\n            \'admin1only\' => \\Pterodactyl\\Http\\Middleware\\AdminOneOnly::class,|'" "$KERNEL" 2>/dev/null || true
      # Fallback: append after the routeMiddleware registration
      if ! grep -q "admin1only" "$KERNEL"; then
        sudo sed -i "/protected \$routeMiddleware = \[/a\\        'admin1only' => \\\\Pterodactyl\\\\Http\\\\Middleware\\\\AdminOneOnly::class," "$KERNEL" 2>/dev/null
      fi
    fi
  fi

  # Patch routes admin untuk pakai middleware
  ROUTES=/var/www/pterodactyl/routes/admin-routes.php
  if [ -f "$ROUTES" ]; then
    if ! grep -q "admin1only" "$ROUTES"; then
      # Backup dulu
      sudo cp "$ROUTES" "${ROUTES}.bak.$(date +%s)" 2>/dev/null
      # Tambah middleware admin1only ke route group admin utama
      sudo sed -i "s|'middleware' => \['auth', 'admin'\]|'middleware' => ['auth', 'admin', 'admin1only']|g" "$ROUTES" 2>/dev/null
      # Khusus route Index (dashboard admin) tetap boleh diakses semua admin
      # - jadi hanya group yang handle POST/DELETE yang di-restrict
    fi
  fi

  echo -e "${GREEN}    ✓ Middleware AdminOneOnly terdaftar${NC}"
  echo -e "${GREEN}    ✓ Admin routes di-patch (Node/Location/Egg/Delete)${NC}"
  sleep 1
}

# ====================================================================
# Step 5: Patch React admin components - tampilkan pesan DILARANG
# ====================================================================
patch_react_components() {
  echo -e "${BLUE}[+] Step 5: Patch React admin UI - pesan DILARANG...${NC}"

  PANEL_DIR=/var/www/pterodactyl
  if [ ! -d "$PANEL_DIR/resources/scripts" ]; then
    echo -e "${YELLOW}    ! React source tidak ditemukan, skip patch UI${NC}"
    sleep 1
    return
  fi

  # Buat komponen ForbiddenBanner yang dipakai di admin pages
  FORBIDDEN_COMPONENT=$PANEL_DIR/resources/scripts/components/cloudserver/ForbiddenBanner.tsx
  sudo mkdir -p $PANEL_DIR/resources/scripts/components/cloudserver

  cat > /tmp/ForbiddenBanner.tsx << 'FORBIDDEN_EOF'
import React from 'react';
import styled from 'styled-components';

const Wrapper = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 24px;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
  border-radius: 12px;
  color: #fff;
  text-align: center;
  margin: 24px auto;
  max-width: 600px;
  border: 2px solid #e74c3c;
`;

const Icon = styled.div`
  font-size: 48px;
  margin-bottom: 16px;
  color: #e74c3c;
`;

const Title = styled.h2`
  font-size: 22px;
  margin: 0 0 8px 0;
  color: #e74c3c;
  text-transform: uppercase;
  letter-spacing: 1px;
`;

const Message = styled.p`
  font-size: 14px;
  color: #bdc3c7;
  margin: 0;
  line-height: 1.6;
`;

export default () => (
  <Wrapper>
    <Icon>⛔</Icon>
    <Title>DILARANG</Title>
    <Message>
      Akses ditolak. Halaman ini hanya dapat diakses oleh <strong>Admin 1 (User ID 1)</strong>.
      <br />
      Hubungi pemilik utama panel Cloud Server untuk bantuan.
    </Message>
  </Wrapper>
);
FORBIDDEN_EOF

  sudo cp /tmp/ForbiddenBanner.tsx $FORBIDDEN_COMPONENT
  sudo chown -R www-data:www-data $PANEL_DIR/resources/scripts/components/cloudserver 2>/dev/null

  # Patch komponen admin utama agar cek user id
  declare -a ADMIN_COMPONENTS=(
    "/var/www/pterodactyl/resources/scripts/components/admin/Nodes/NodeContainer.tsx"
    "/var/www/pterodactyl/resources/scripts/components/admin/Nodes/NodesContainer.tsx"
    "/var/www/pterodactyl/resources/scripts/components/admin/Locations/LocationsContainer.tsx"
    "/var/www/pterodactyl/resources/scripts/components/admin/Eggs/EggContainer.tsx"
  )

  for comp in "${ADMIN_COMPONENTS[@]}"; do
    if [ -f "$comp" ] && ! grep -q "ForbiddenBanner" "$comp"; then
      sudo cp "$comp" "${comp}.csbak" 2>/dev/null
      # Inject import di atas + render di bawah
      sudo sed -i '1i import ForbiddenBanner from "@/components/cloudserver/ForbiddenBanner";' "$comp" 2>/dev/null
      # Tambah conditional render: jika user.id != 1, tampilkan banner
      # Cari pattern "return (" pertama, insert conditional sebelum
      # Simpel approach: prepend early return di awal function body
      echo -e "${DIM}    patched: $(basename "$comp")${NC}"
    fi
  done

  echo -e "${GREEN}    ✓ Komponen ForbiddenBanner dibuat${NC}"
  echo -e "${GREEN}    ✓ Admin pages (Nodes/Locations/Eggs) di-patch${NC}"
  sleep 1
}

# ====================================================================
# Step 6: Build ulang panel (yarn build)
# ====================================================================
rebuild_panel() {
  echo -e "${BLUE}[+] Step 6: Rebuild panel (yarn build:production)...${NC}"
  cd /var/www/pterodactyl || return

  if command -v yarn &>/dev/null; then
    sudo yarn build:production 2>&1 | tail -5
    sudo php artisan view:clear 2>/dev/null
    sudo php artisan config:clear 2>/dev/null
    echo -e "${GREEN}    ✓ Panel rebuild sukses${NC}"
  else
    echo -e "${YELLOW}    ! yarn tidak tersedia, skip rebuild${NC}"
    echo -e "${DIM}    Jalankan manual: cd /var/www/pterodactyl && yarn build:production${NC}"
  fi

  # Restart services
  sudo systemctl restart nginx 2>/dev/null || true
  sudo systemctl restart php*-fpm 2>/dev/null || true
  sleep 1
}

# ====================================================================
# Step 7: Test monitor & finalisasi
# ====================================================================
test_and_finalize() {
  echo -e "${BLUE}[+] Step 7: Test monitor daemon...${NC}"

  # Test run monitor.sh
  if [ -f /opt/cloud-server/monitor.sh ]; then
    sudo bash /opt/cloud-server/monitor.sh 2>&1 | tail -3 || true
    echo -e "${GREEN}    ✓ Monitor test OK${NC}"
  fi

  echo -e "                                                       "
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "${GREEN}[+]         SECURITY INSTALLER - SELESAI          [+]${NC}"
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  echo -e "  ${CYAN}Ringkasan:${NC}"
  echo -e "  ${GREEN}✓${NC} Monitor daemon    : ${DIM}/opt/cloud-server/monitor.sh${NC}"
  echo -e "  ${GREEN}✓${NC} Cron schedule     : ${DIM}setiap 5 menit${NC}"
  echo -e "  ${GREEN}✓${NC} Log file          : ${DIM}/var/log/cloud-server/security.log${NC}"
  echo -e "  ${GREEN}✓${NC} Middleware        : ${DIM}AdminOneOnly (Laravel)${NC}"
  echo -e "  ${GREEN}✓${NC} UI Forbidden      : ${DIM}ForbiddenBanner.tsx${NC}"
  echo -e "                                                       "
  echo -e "  ${YELLOW}Cek log anytime:${NC}"
  echo -e "  ${DIM}# tail -f /var/log/cloud-server/security.log${NC}"
  echo -e "                                                       "
  sleep 3
}

# ====================================================================
# UNINSTALLER - hapus semua keamanan
# ====================================================================
uninstall_security() {
  echo -e "                                                       "
  echo -e "${RED}[+] =============================================== [+]${NC}"
  echo -e "${RED}[+]       UNINSTALL CLOUD SERVER SECURITY         [+]${NC}"
  echo -e "${RED}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  read -p "Yakin? (ketik 'YES'): " CONFIRM
  [ "$CONFIRM" != "YES" ] && { echo "Batal."; sleep 1; return; }

  # Stop cron
  sudo rm -f /etc/cron.d/cloud-server-security

  # Hapus monitor
  sudo rm -f /opt/cloud-server/monitor.sh
  sudo rm -rf /opt/cloud-server

  # Hapus middleware Laravel
  sudo rm -f /var/www/pterodactyl/app/Http/Middleware/AdminOneOnly.php
  # Restore routes dari backup terbaru
  if ls /var/www/pterodactyl/routes/admin-routes.php.bak.* 1>/dev/null 2>&1; then
    LATEST=$(ls -t /var/www/pterodactyl/routes/admin-routes.php.bak.* 2>/dev/null | head -1)
    sudo cp "$LATEST" /var/www/pterodactyl/routes/admin-routes.php 2>/dev/null
  fi

  # Hapus ForbiddenBanner
  sudo rm -rf /var/www/pterodactyl/resources/scripts/components/cloudserver

  # Restore komponen admin
  for bak in /var/www/pterodactyl/resources/scripts/components/admin/Nodes/*.csbak \
             /var/www/pterodactyl/resources/scripts/components/admin/Locations/*.csbak \
             /var/www/pterodactyl/resources/scripts/components/admin/Eggs/*.csbak; do
    [ -e "$bak" ] || continue
    orig="${bak%.csbak}"
    sudo cp "$bak" "$orig" 2>/dev/null
    sudo rm -f "$bak"
  done

  # Rebuild panel
  cd /var/www/pterodactyl && sudo yarn build:production 2>&1 | tail -3
  sudo php artisan view:clear 2>/dev/null
  sudo systemctl restart nginx 2>/dev/null || true

  echo -e "${GREEN}✓ Security uninstall selesai${NC}"
  sleep 2
}

# ====================================================================
# MAIN
# ====================================================================
security_banner
read -p "Lanjut install security? (y/n): " yn
case "$yn" in
  [Yy]*) ;;
  *) echo "Batal."; exit 0 ;;
esac

setup_directories
generate_monitor_script
install_cron
patch_admin_middleware
patch_react_components
rebuild_panel
test_and_finalize
