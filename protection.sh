#!/bin/bash
# ====================================================================
# CLOUD SERVER - PROTECTION INSTALLER v3
# FIX: Tidak modify route files (yang bikin parse error & block admin 1)
#      Langsung patch Controller methods - lebih reliable
#
# Fitur:
#   1. Monitor disk over-limit -> auto-suspend
#   2. Detect suspicious process (miner/crypto) -> auto-suspend
#   3. Admin-1 only restriction - inject check di Controller methods:
#      - NodesController: create, store, edit, update, destroy
#      - LocationsController: store, update, destroy
#      - EggsController: create, store, edit, update, destroy
#      - ServersController: destroy, viewAs (delete server, view as user)
# ====================================================================

BLUE='\033[0;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

PANEL_DIR="${PANEL_DIR:-/var/www/pterodactyl}"

banner() {
  clear
  echo -e "                                                       "
  echo -e "${RED}[+] =============================================== [+]${NC}"
  echo -e "${RED}[+]   CLOUD SERVER PROTECTION v3 - RELIABLE FIX   [+]${NC}"
  echo -e "${RED}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  echo -e "  ${CYAN}Fitur:${NC}"
  echo -e "  ${GREEN}1${NC}. Monitor disk otomatis -> auto-suspend${NC}"
  echo -e "  ${GREEN}2${NC}. Suspicious process detector (miner/crypto)${NC}"
  echo -e "  ${GREEN}3${NC}. Admin-1 only restriction (via Controller patch)${NC}"
  echo -e "                                                       "
  echo -e "  ${DIM}v3: Patch controller LANGSUNG (bukan route file)${NC}"
  echo -e "  ${DIM}    -> Tidak bikin parse error PHP${NC}"
  echo -e "  ${DIM}    -> Admin 1 tetap bisa akses penuh${NC}"
  echo -e "                                                       "
}

check_panel() {
  if [ ! -d "$PANEL_DIR/app/Http/Controllers/Admin" ]; then
    echo -e "${RED}[!] Folder Admin Controller tidak ditemukan di $PANEL_DIR${NC}"
    echo -e "${YELLOW}    Pastikan Pterodactyl panel sudah terinstall dengan benar${NC}"
    exit 1
  fi
}

# ====================================================================
# STEP 1: Setup direktori & log
# ====================================================================
setup_dirs() {
  echo -e "${BLUE}[+] Step 1: Setup direktori & log...${NC}"
  sudo mkdir -p /opt/cloud-server
  sudo mkdir -p /var/log/cloud-server
  sudo touch /var/log/cloud-server/security.log
  sudo chmod 644 /var/log/cloud-server/security.log
  echo -e "${GREEN}    ✓ /opt/cloud-server & /var/log/cloud-server siap${NC}"
  sleep 1
}

# ====================================================================
# STEP 2: Generate monitor daemon
# ====================================================================
generate_monitor() {
  echo -e "${BLUE}[+] Step 2: Generate monitor daemon...${NC}"

  read -p "Batas maksimum disk per server (MB, default 10240): " DISK_LIMIT_MB
  DISK_LIMIT_MB="${DISK_LIMIT_MB:-10240}"
  read -p "Panel URL (https://panel.domain.com, kosong jika tidak pakai API): " PANEL_URL
  read -p "Admin API Token (kosongkan -> pakai docker stop): " API_TOKEN

  cat > /tmp/cloud_monitor.sh << 'MONITOR_EOF'
#!/bin/bash
# Cloud Server - Security Monitor Daemon
LOG="/var/log/cloud-server/security.log"
DISK_LIMIT_MB="__DISK_LIMIT__"
PANEL_URL="__PANEL_URL__"
API_TOKEN="__API_TOKEN__"
VOLUMES_DIR="/var/lib/pterodactyl/volumes"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"; }

suspend_server() {
  local UUID="$1"; local REASON="$2"
  log "SUSPEND: server=$UUID reason=$REASON"
  if [ -n "$API_TOKEN" ] && [ -n "$PANEL_URL" ]; then
    curl -s -X POST "${PANEL_URL%/}/api/application/servers/$UUID/suspend" \
      -H "Authorization: Bearer $API_TOKEN" \
      -H "Accept: application/json" \
      -d '{}' >/dev/null 2>&1
  else
    docker ps --filter "name=$UUID" --format "{{.Names}}" | head -1 | while read cn; do
      [ -n "$cn" ] && docker stop "$cn" >/dev/null 2>&1
    done
  fi
}

SUSPICIOUS_PATTERNS=(xmrig cpuminer ccminer ethminer claymore PhoenixMiner
  teamredminer TrexMiner lolMiner minerd cryptonight "stratum+tcp"
  "stratum+ssl" nanopool f2pool antpool mining ethash)

check_disk() {
  [ -d "$VOLUMES_DIR" ] || return
  for d in "$VOLUMES_DIR"/*/; do
    [ -d "$d" ] || continue
    p="${d%/}"; uuid="$(basename "$p")"
    sb=$(du -sb "$p" 2>/dev/null | awk '{print $1}')
    [ -z "$sb" ] && continue
    sm=$(( sb / 1024 / 1024 ))
    if [ "$sm" -gt "$DISK_LIMIT_MB" ]; then
      log "DISK_OVER: server=$uuid used=${sm}MB limit=${DISK_LIMIT_MB}MB"
      suspend_server "$uuid" "disk_over_${sm}MB"
    fi
  done
}

check_suspicious() {
  for cid in $(docker ps -q --filter "label=pterodactyl"); do
    uuid=$(docker inspect --format '{{ index .Config.Labels "PterodactylServerUUID" }}' "$cid" 2>/dev/null)
    [ -z "$uuid" ] && uuid=$(docker inspect --format '{{ .Name }}' "$cid" | tr -d '/')
    procs=$(docker top "$cid" -eo args 2>/dev/null)
    [ -z "$procs" ] && continue
    for pat in "${SUSPICIOUS_PATTERNS[@]}"; do
      if echo "$procs" | grep -iEq "$pat"; then
        log "SUSPICIOUS: server=$uuid pattern=$pat"
        suspend_server "$uuid" "suspicious_$pat"
        break
      fi
    done
  done
}

log "===== monitor run ====="
check_disk
check_suspicious
log "===== monitor end ====="
MONITOR_EOF

  sed -i "s|__DISK_LIMIT__|$DISK_LIMIT_MB|g" /tmp/cloud_monitor.sh
  sed -i "s|__PANEL_URL__|$PANEL_URL|g" /tmp/cloud_monitor.sh
  sed -i "s|__API_TOKEN__|$API_TOKEN|g" /tmp/cloud_monitor.sh

  sudo mv /tmp/cloud_monitor.sh /opt/cloud-server/monitor.sh
  sudo chmod +x /opt/cloud-server/monitor.sh
  echo -e "${GREEN}    ✓ /opt/cloud-server/monitor.sh (disk limit ${DISK_LIMIT_MB}MB)${NC}"
  sleep 1
}

# ====================================================================
# STEP 3: Install cron
# ====================================================================
install_cron() {
  echo -e "${BLUE}[+] Step 3: Install cron (setiap 5 menit)...${NC}"
  cat > /tmp/cloud_cron << 'CRON_EOF'
# Cloud Server Security Monitor - every 5 minutes
*/5 * * * * root /opt/cloud-server/monitor.sh >/dev/null 2>&1
@reboot root /opt/cloud-server/monitor.sh >/dev/null 2>&1
CRON_EOF
  sudo mv /tmp/cloud_cron /etc/cron.d/cloud-server-security
  sudo chmod 644 /etc/cron.d/cloud-server-security
  echo -e "${GREEN}    ✓ /etc/cron.d/cloud-server-security${NC}"
  sleep 1
}

# ====================================================================
# STEP 4: Patch Controller methods via Python (RELIABLE)
# Tidak modify routes file - langsung inject check di awal method
# Controller yang di-patch:
#   - Admin/NodesController.php
#   - Admin/LocationsController.php
#   - Admin/EggsController.php
#   - Admin/ServersController.php (destroy, viewAs)
# ====================================================================
patch_controllers() {
  echo -e "${BLUE}[+] Step 4: Patch Controller methods (via Python)...${NC}"

  # Pastikan python3 ada
  if ! command -v python3 &>/dev/null; then
    echo -e "${YELLOW}    ! python3 tidak tersedia, install dulu...${NC}"
    sudo apt install -y python3 >/dev/null 2>&1
  fi

  # Tulis Python patcher
  cat > /tmp/cs_patch.py << 'PY_EOF'
import re
import sys
import os

CTRL_DIR = os.environ.get('PANEL_DIR', '/var/www/pterodactyl') + '/app/Http/Controllers/Admin'

# Map: file => list of method names yang harus di-restrict ke admin-1
PATCH_MAP = {
    'NodesController.php':       ['store', 'update', 'destroy', 'create', 'edit', 'delete'],
    'LocationsController.php':   ['store', 'update', 'destroy', 'delete'],
    'EggsController.php':        ['store', 'update', 'destroy', 'create', 'edit', 'delete'],
    'ServersController.php':     ['destroy', 'delete', 'viewAs'],
    'DatabaseHostController.php':['store', 'update', 'destroy'],
    'NestController.php':        ['store', 'update', 'destroy'],
}

MARKER = '// CloudServerProtection-admin1'

def patch_file(filepath, methods):
    if not os.path.exists(filepath):
        print(f"  SKIP (not found): {os.path.basename(filepath)}")
        return 0
    with open(filepath, 'r') as f:
        content = f.read()
    original = content
    patched_count = 0
    for m in methods:
        # Match: public function METHOD(...) { (atau publik dengan return type)
        # Pattern mencari method definition yang BELUM ada marker
        pattern = rf'(public function {m}\s*\([^)]*\)\s*(?::\s*\w+\s*)?\{{)'
        matches = list(re.finditer(pattern, content))
        if not matches:
            continue
        for match in reversed(matches):  # reverse agar index tidak shift
            # FIX: cek MARKER hanya di 80 char SETELAH match end (bukan start+250)
            # Kalau 250, MARKER dari method lain (yg sudah di-patch) ikut ke-detect
            after_match = content[match.end():match.end()+80]
            if MARKER in after_match:
                continue  # sudah di-patch, skip
            # Inject check setelah opening brace
            injection = (
                match.group(0) +
                f'\n        {MARKER}\n' +
                '        if (auth()->user() && (int) auth()->user()->id !== 1) {\n' +
                '            return response()->json(["error" => "DILARANG", "message" => "Akses ditolak. Aksi ini hanya untuk Admin 1 (User ID 1)."], 403);\n' +
                '        }'
            )
            content = content[:match.start()] + injection + content[match.end():]
            patched_count += 1
    if content != original:
        # Backup sekali
        if not os.path.exists(filepath + '.cs.bak'):
            with open(filepath + '.cs.bak', 'w') as f:
                f.write(original)
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"  ✓ {os.path.basename(filepath)}: {patched_count} method di-patch")
    else:
        print(f"  = {os.path.basename(filepath)}: no change (sudah di-patch / method tidak ada)")
    return patched_count

print(f"Patching controllers di: {CTRL_DIR}")
total = 0
for fname, methods in PATCH_MAP.items():
    fpath = os.path.join(CTRL_DIR, fname)
    total += patch_file(fpath, methods)
print(f"\nTotal {total} method di-patch")
PY_EOF

  PANEL_DIR="$PANEL_DIR" sudo -E python3 /tmp/cs_patch.py
  rm -f /tmp/cs_patch.py
  sleep 1
}

# ====================================================================
# STEP 5: Inject Blade notice (badge DILARANG di pojok untuk non-admin-1)
# ====================================================================
patch_blade_notice() {
  echo -e "${BLUE}[+] Step 5: Inject Blade notice (badge DILARANG)...${NC}"

  # Pterodactyl pakai layout admin di resources/views/layouts/admin.blade.php
  # Atau templates/admin.blade.php (tergantung versi)
  CANDIDATES=(
    "$PANEL_DIR/resources/views/layouts/admin.blade.php"
    "$PANEL_DIR/resources/views/templates/admin.blade.php"
    "$PANEL_DIR/resources/views/admin/layouts/app.blade.php"
  )

  NOTICE_MARKER='<!-- CloudServerProtection-notice -->'
  NOTICE_SNIPPET='
<!-- CloudServerProtection-notice -->
@php $csUser = \Illuminate\Support\Facades\Auth::user(); @endphp
@if($csUser && (int) $csUser->id !== 1)
<div id="cs-forbidden-notice" style="position:fixed;bottom:16px;right:16px;background:linear-gradient(135deg,#c0392b,#922b21);color:#fff;padding:14px 20px;border-radius:8px;box-shadow:0 6px 20px rgba(0,0,0,0.3);z-index:99999;font-family:Inter,sans-serif;font-size:13px;max-width:340px;">
  <div style="font-weight:bold;font-size:14px;margin-bottom:4px;">⛔ DILARANG</div>
  <div style="opacity:0.9;line-height:1.5;">
    Anda login sebagai <strong>{{ $csUser->username }}</strong> (admin non-1).<br>
    Aksi sensitif (Node, Location, Egg, hapus server, view-as-user) HANYA untuk <strong>Admin 1</strong>.<br>
    Jika mencoba aksi tersebut, sistem akan menolak (HTTP 403).
  </div>
</div>
@endif
<!-- /CloudServerProtection-notice -->'

  for blade in "${CANDIDATES[@]}"; do
    if [ ! -f "$blade" ]; then
      continue
    fi
    if grep -q "CloudServerProtection-notice" "$blade"; then
      echo -e "${DIM}    Sudah di-patch: $(basename "$blade")${NC}"
      continue
    fi
    sudo cp "$blade" "${blade}.cs.bak" 2>/dev/null
    # Inject sebelum </body> atau </html>
    if grep -q '</body>' "$blade"; then
      sudo python3 -c "
import sys
content = open('$blade').read()
notice = '''$NOTICE_SNIPPET'''
content = content.replace('</body>', notice + '\n</body>', 1)
open('$blade', 'w').write(content)
print('  ✓ Injected:', '$blade')
"
    else
      # Fallback: append di akhir file
      echo "$NOTICE_SNIPPET" | sudo tee -a "$blade" >/dev/null
      echo -e "${GREEN}    ✓ Appended: $(basename "$blade")${NC}"
    fi
    sudo chown www-data:www-data "$blade" 2>/dev/null
    break  # patch satu file cukup
  done

  sleep 1
}

# ====================================================================
# STEP 6: Clear cache & restart
# ====================================================================
finalize_panel() {
  echo -e "${BLUE}[+] Step 6: Clear cache & restart services...${NC}"
  cd "$PANEL_DIR" || return

  sudo php artisan view:clear 2>&1 | tail -1
  sudo php artisan config:clear 2>&1 | tail -1
  sudo php artisan route:clear 2>&1 | tail -1
  sudo php artisan cache:clear 2>&1 | tail -1
  echo -e "${GREEN}    ✓ Cache cleared${NC}"

  sudo systemctl restart nginx 2>/dev/null && echo -e "${GREEN}    ✓ nginx${NC}"
  for v in 8.2 8.1 8.0 7.4; do
    sudo systemctl restart "php${v}-fpm" 2>/dev/null && echo -e "${GREEN}    ✓ php${v}-fpm${NC}" && break
  done
  sudo systemctl restart php-fpm 2>/dev/null || true
  sleep 1
}

# ====================================================================
# STEP 7: Verifikasi PHP tidak parse-error
# ====================================================================
verify_php() {
  echo -e "${BLUE}[+] Step 7: Verifikasi PHP syntax (anti parse-error)...${NC}"
  ERROR_FOUND=0
  for f in "$PANEL_DIR/app/Http/Controllers/Admin/"*.php; do
    [ -f "$f" ] || continue
    ERR=$(sudo php -l "$f" 2>&1)
    if ! echo "$ERR" | grep -q "No syntax errors"; then
      echo -e "${RED}    ✗ ERROR di $(basename "$f"):${NC}"
      echo "$ERR" | head -3
      ERROR_FOUND=1
    fi
  done
  if [ "$ERROR_FOUND" -eq 1 ]; then
    echo -e "${RED}    Ada syntax error! Backup dipulihkan otomatis...${NC}"
    for f in "$PANEL_DIR/app/Http/Controllers/Admin/"*.cs.bak; do
      [ -f "$f" ] || continue
      orig="${f%.cs.bak}"
      sudo cp "$f" "$orig"
      echo -e "${YELLOW}    Restored: $(basename "$orig")${NC}"
    done
    echo -e "${RED}    Install dibatalkan. Panel kembali normal.${NC}"
    exit 1
  fi
  echo -e "${GREEN}    ✓ Semua Controller PHP lulus syntax check${NC}"
  sleep 1
}

# ====================================================================
# Final report
# ====================================================================
finalize_report() {
  echo -e "                                                       "
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "${GREEN}[+]      PROTECTION v3 INSTALL - SELESAI         [+]${NC}"
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  echo -e "  ${CYAN}Yang sudah terpasang:${NC}"
  echo -e "  ${GREEN}✓${NC} Monitor daemon   : ${DIM}/opt/cloud-server/monitor.sh${NC}"
  echo -e "  ${GREEN}✓${NC} Cron schedule    : ${DIM}setiap 5 menit${NC}"
  echo -e "  ${GREEN}✓${NC} Log file         : ${DIM}/var/log/cloud-server/security.log${NC}"
  echo -e "  ${GREEN}✓${NC} Controller patch : ${DIM}NodesController, LocationsController${NC}"
  echo -e "                       ${DIM}EggsController, ServersController${NC}"
  echo -e "  ${GREEN}✓${NC} Blade notice     : ${DIM}badge DILARANG untuk admin non-1${NC}"
  echo -e "  ${GREEN}✓${NC} PHP syntax       : ${DIM}lulus (no parse error)${NC}"
  echo -e "                                                       "
  echo -e "  ${YELLOW}Penting - Cara kerja:${NC}"
  echo -e "  ${DIM}  • Admin 1 (user ID 1) → akses penuh, TIDAK ada larangan${NC}"
  echo -e "  ${DIM}  • Admin lain → lihat dashboard OK, tapi POST/DELETE = 403${NC}"
  echo -e "  ${DIM}  • Method yg di-restrict: store, update, destroy, create, edit${NC}"
  echo -e "                                                       "
  echo -e "  ${YELLOW}Cek log realtime:${NC}"
  echo -e "  ${DIM}  tail -f /var/log/cloud-server/security.log${NC}"
  echo -e "                                                       "
  echo -e "  ${YELLOW}Untuk UNINSTALL:${NC}"
  echo -e "  ${DIM}  sudo bash $0 --uninstall${NC}"
  echo -e "                                                       "
}

# ====================================================================
# Uninstaller
# ====================================================================
do_uninstall() {
  echo -e "${RED}[+] Uninstall Cloud Server Protection v3...${NC}"
  sudo rm -f /etc/cron.d/cloud-server-security
  sudo rm -f /opt/cloud-server/monitor.sh
  sudo rm -rf /opt/cloud-server

  # Restore controllers dari backup
  for f in "$PANEL_DIR/app/Http/Controllers/Admin/"*.cs.bak; do
    [ -f "$f" ] || continue
    orig="${f%.cs.bak}"
    sudo cp "$f" "$orig"
    sudo rm -f "$f"
    echo -e "${GREEN}    ✓ Restored: $(basename "$orig")${NC}"
  done

  # Hapus Blade notice
  for blade in "$PANEL_DIR/resources/views/layouts/admin.blade.php" \
               "$PANEL_DIR/resources/views/templates/admin.blade.php" \
               "$PANEL_DIR/resources/views/admin/layouts/app.blade.php"; do
    [ -f "$blade" ] || continue
    if [ -f "${blade}.cs.bak" ]; then
      sudo cp "${blade}.cs.bak" "$blade"
      sudo rm -f "${blade}.cs.bak"
      echo -e "${GREEN}    ✓ Restored: $(basename "$blade")${NC}"
    fi
  done

  cd "$PANEL_DIR" 2>/dev/null
  sudo php artisan view:clear 2>&1 | tail -1
  sudo php artisan config:clear 2>&1 | tail -1
  sudo php artisan route:clear 2>&1 | tail -1
  sudo systemctl restart nginx 2>/dev/null
  for v in 8.2 8.1 8.0 7.4; do
    sudo systemctl restart "php${v}-fpm" 2>/dev/null && break
  done
  echo -e "${GREEN}✓ Uninstall selesai. Panel kembali normal.${NC}"
  exit 0
}

# ====================================================================
# MAIN
# ====================================================================
banner

if [ "$1" = "--uninstall" ] || [ "$1" = "-u" ]; then
  do_uninstall
fi

check_panel

read -p "Lanjut install protection v3? (y/n): " yn
case "$yn" in
  [Yy]*) ;;
  *) echo "Batal."; exit 0 ;;
esac

setup_dirs
generate_monitor
install_cron
patch_controllers
patch_blade_notice
finalize_panel
verify_php
finalize_report
