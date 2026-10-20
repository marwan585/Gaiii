#!/bin/bash
# ====================================================================
# CLOUD SERVER - LOADING ANIMATION INSTALLER v2
# FIX: pakai Python untuk inject (bukan awk yang gagal karena sudo)
#      + verifikasi via curl agar pasti berfungsi
#
# Inject animasi loading Cloud Server ke public/index.html
# Animasi tampil di browser tiap user buka panel
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
INDEX_FILE="$PANEL_DIR/public/index.html"

banner() {
  clear
  echo -e "                                                       "
  echo -e "${CYAN}[+] =============================================== [+]${NC}"
  echo -e "${CYAN}[+]   LOADING ANIMATION v2 - RELIABLE INSTALLER   [+]${NC}"
  echo -e "${CYAN}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  echo -e "  ${DIM}v2: pakai Python untuk inject (bukan awk)${NC}"
  echo -e "  ${DIM}    + verifikasi via curl bahwa loader aktif${NC}"
  echo -e "                                                       "
}

# ====================================================================
check_panel() {
  if [ ! -d "$PANEL_DIR" ]; then
    echo -e "${RED}[!] Folder $PANEL_DIR tidak ditemukan!${NC}"
    echo -e "${YELLOW}    Pterodactyl panel belum terinstall?${NC}"
    exit 1
  fi
  if [ ! -f "$INDEX_FILE" ]; then
    echo -e "${RED}[!] File $INDEX_FILE tidak ditemukan!${NC}"
    exit 1
  fi
  echo -e "${GREEN}✓ Panel ditemukan: $INDEX_FILE${NC}"
  echo -e "${DIM}  Ukuran: $(wc -c < "$INDEX_FILE") bytes${NC}"
  sleep 1
}

# ====================================================================
# Generate loader HTML/CSS/JS
# ====================================================================
generate_loader() {
  echo -e "${BLUE}[+] Generate loader HTML/CSS/JS...${NC}"
  cat > /tmp/cloud_loader_block.html << 'LOADER_EOF'
<!-- CLOUD_SERVER_LOADER_START -->
<style>
  #cloud-loader {
    position: fixed; top: 0; left: 0; width: 100%; height: 100%;
    background: linear-gradient(135deg, #0f0f1e 0%, #1a1a2e 50%, #16213e 100%);
    z-index: 99999;
    display: flex; flex-direction: column; align-items: center; justify-content: center;
    transition: opacity 0.6s ease-out;
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  }
  #cloud-loader.fade { opacity: 0; pointer-events: none; }
  .cloud-art {
    color: #4FC3F7;
    font-family: 'Courier New', monospace;
    white-space: pre;
    line-height: 1.15;
    margin-bottom: 28px;
    font-size: 14px;
    text-shadow: 0 0 18px rgba(79, 195, 247, 0.7);
    animation: cloudPulse 1.6s ease-in-out infinite;
  }
  @keyframes cloudPulse {
    0%, 100% { opacity: 0.95; transform: scale(1); }
    50%      { opacity: 0.55; transform: scale(0.98); }
  }
  .loader-title {
    color: #FFB74D;
    font-size: 18px; font-weight: 600; letter-spacing: 2px;
    margin: 0 0 6px 0; text-transform: uppercase;
  }
  .loader-phase {
    color: rgba(255, 255, 255, 0.75); font-size: 12px;
    margin-bottom: 18px; letter-spacing: 0.5px;
  }
  .progress-track {
    width: 280px; height: 6px; background: rgba(255, 255, 255, 0.08);
    border-radius: 4px; overflow: hidden;
    box-shadow: 0 0 12px rgba(79, 195, 247, 0.2) inset;
  }
  .progress-fill {
    width: 0%; height: 100%;
    background: linear-gradient(90deg, #4FC3F7 0%, #FFB74D 100%);
    box-shadow: 0 0 10px rgba(79, 195, 247, 0.6);
    animation: cloudFill 2.2s ease-out forwards;
  }
  @keyframes cloudFill {
    0%{width:0%} 15%{width:15%} 30%{width:32%} 50%{width:55%}
    75%{width:82%} 100%{width:100%}
  }
  .loader-percent {
    color: #4FC3F7; font-size: 11px; margin-top: 10px;
    font-family: 'Courier New', monospace; letter-spacing: 1px;
  }
  .loader-credit {
    color: rgba(255, 255, 255, 0.35); font-size: 10px;
    margin-top: 32px; letter-spacing: 0.5px;
  }
</style>
<div id="cloud-loader">
  <pre class="cloud-art">       .-----------.
    .-'             '-.
   /    [CLOUD]   [ ]  \
  |     SERVER PANEL    |
  |   ___  ___  ___     |
   \  | |  | |  | |    /
    '-._|___|_|___|_.-'
       '--.   .--'
           '-'</pre>
  <div class="loader-title">Cloud Server</div>
  <div class="loader-phase" id="cloud-loader-phase">Initializing Cloud Server Engine...</div>
  <div class="progress-track"><div class="progress-fill"></div></div>
  <div class="loader-percent" id="cloud-loader-percent">0%</div>
  <div class="loader-credit">© Cloud Server Autoinstaller</div>
</div>
<script>
(function() {
  var phases = [
    "Initializing Cloud Server Engine...",
    "Loading Network Stack...",
    "Connecting to Pterodactyl Panel...",
    "Verifying System Permissions...",
    "Mounting Storage Volumes...",
    "Establishing Secure Connection...",
    "Cloud Server Ready!"
  ];
  var phaseEl = document.getElementById('cloud-loader-phase');
  var percentEl = document.getElementById('cloud-loader-percent');
  var i = 0;
  var interval = setInterval(function() {
    i++;
    if (i >= phases.length) { clearInterval(interval); return; }
    if (phaseEl) phaseEl.textContent = phases[i];
    if (percentEl) percentEl.textContent = Math.round((i + 1) * 100 / phases.length) + '%';
  }, 280);
  function hideLoader() {
    setTimeout(function() {
      var loader = document.getElementById('cloud-loader');
      if (!loader) return;
      clearInterval(interval);
      loader.classList.add('fade');
      setTimeout(function() {
        if (loader && loader.parentNode) loader.parentNode.removeChild(loader);
      }, 600);
    }, 1800);
  }
  if (document.readyState === 'complete') hideLoader();
  else window.addEventListener('load', hideLoader);
})();
</script>
<!-- CLOUD_SERVER_LOADER_END -->
LOADER_EOF
  echo -e "${GREEN}    ✓ Loader block dibuat: $(wc -c < /tmp/cloud_loader_block.html) bytes${NC}"
  sleep 1
}

# ====================================================================
# Inject loader via Python (RELIABLE - tidak ada masalah sudo)
# ====================================================================
inject_loader() {
  echo -e "${BLUE}[+] Inject loader ke index.html via Python...${NC}"

  # Pastikan python3
  if ! command -v python3 &>/dev/null; then
    echo -e "${YELLOW}    ! python3 tidak ada, install dulu...${NC}"
    sudo apt install -y python3 >/dev/null 2>&1
  fi

  # Backup original (sekali saja)
  if [ ! -f "$INDEX_FILE.orig" ]; then
    sudo cp "$INDEX_FILE" "$INDEX_FILE.orig"
    echo -e "${GREEN}    ✓ Backup dibuat: $INDEX_FILE.orig${NC}"
  fi

  # Python script - lebih reliable dari awk/sed
  sudo python3 << PYEOF
import re

index_file = "$INDEX_FILE"
loader_file = "/tmp/cloud_loader_block.html"

with open(loader_file, 'r') as f:
    loader = f.read()

with open(index_file, 'r') as f:
    content = f.read()

print(f"  Original size: {len(content)} bytes")

# Hapus block loader lama jika ada (idempotent - support re-install)
pattern = re.compile(r'<!-- CLOUD_SERVER_LOADER_START -->.*?<!-- CLOUD_SERVER_LOADER_END -->', re.DOTALL)
if pattern.search(content):
    print("  Loader lama ditemukan, hapus dulu...")
    content = pattern.sub('', content)
    # Bersihkan baris kosong berlebih
    content = re.sub(r'\n\s*\n\s*\n', '\n\n', content)

# Inject sebelum </body> (atau </html> sebagai fallback)
if '</body>' in content:
    new_content = content.replace('</body>', loader + '\n</body>', 1)
    print("  Inject sebelum </body>")
elif '</html>' in content:
    new_content = content.replace('</html>', loader + '\n</html>', 1)
    print("  Inject sebelum </html> (fallback)")
else:
    new_content = content + '\n' + loader
    print("  Appended di akhir file (fallback)")

with open(index_file, 'w') as f:
    f.write(new_content)

print(f"  New size: {len(new_content)} bytes")
print("  ✓ Injection selesai")
PYEOF

  # Set permission
  sudo chown www-data:www-data "$INDEX_FILE" 2>/dev/null
  sudo chmod 644 "$INDEX_FILE" 2>/dev/null
  sleep 1
}

# ====================================================================
# Verifikasi via grep + curl
# ====================================================================
verify_loader() {
  echo -e "${BLUE}[+] Verifikasi loader terpasang...${NC}"

  # 1. Cek via grep
  if grep -q "CLOUD_SERVER_LOADER_START" "$INDEX_FILE"; then
    echo -e "${GREEN}    ✓ Marker CLOUD_SERVER_LOADER_START ditemukan di index.html${NC}"
  else
    echo -e "${RED}    ✗ Marker tidak ditemukan! Inject gagal.${NC}"
    exit 1
  fi

  # 2. Cek struktur HTML dasar (pastikan tidak rusak)
  if ! grep -q "</html>" "$INDEX_FILE"; then
    echo -e "${RED}    ✗ Struktur HTML rusak! </html> tidak ditemukan.${NC}"
    echo -e "${YELLOW}    Restore dari backup...${NC}"
    sudo cp "$INDEX_FILE.orig" "$INDEX_FILE"
    exit 1
  fi
  echo -e "${GREEN}    ✓ Struktur HTML valid (</html> ada)${NC}"

  # 3. Test curl localhost
  echo -e "${BLUE}    Testing via curl localhost...${NC}"
  HTTP_RESP=$(curl -s -o /tmp/cs_test.html -w "%{http_code}" http://localhost/ 2>/dev/null)
  if [ "$HTTP_RESP" = "200" ]; then
    if grep -q "CLOUD_SERVER_LOADER_START" /tmp/cs_test.html 2>/dev/null; then
      echo -e "${GREEN}    ✓ curl test OK (HTTP 200, loader ada di response)${NC}"
    else
      echo -e "${YELLOW}    ! HTTP 200 tapi loader tidak di response (cache nginx?)${NC}"
      echo -e "${DIM}    Coba: sudo systemctl reload nginx && hard refresh browser${NC}"
    fi
  else
    echo -e "${YELLOW}    ! curl test HTTP $HTTP_RESP (mungkin panel di subpath atau behind SSL)${NC}"
    echo -e "${DIM}    Test manual di browser: buka panel URL & hard refresh (Ctrl+F5)${NC}"
  fi
  rm -f /tmp/cs_test.html
  sleep 1
}

# ====================================================================
# Restart services
# ====================================================================
restart_services() {
  echo -e "${BLUE}[+] Restart web server...${NC}"
  sudo systemctl reload nginx 2>/dev/null && echo -e "${GREEN}    ✓ nginx reloaded${NC}" || \
    sudo systemctl restart nginx 2>/dev/null && echo -e "${GREEN}    ✓ nginx restarted${NC}"
  for v in 8.2 8.1 8.0 7.4; do
    sudo systemctl restart "php${v}-fpm" 2>/dev/null && echo -e "${GREEN}    ✓ php${v}-fpm restarted${NC}" && break
  done
  sudo systemctl restart php-fpm 2>/dev/null || true
  sleep 1
}

# ====================================================================
# Final report
# ====================================================================
finalize() {
  echo -e "                                                       "
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "${GREEN}[+]     LOADING ANIMATION v2 - SELESAI           [+]${NC}"
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  echo -e "  ${CYAN}Animasi loading Cloud Server sudah aktif di panel!${NC}"
  echo -e "                                                       "
  echo -e "  ${YELLOW}Cara lihat animasi:${NC}"
  echo -e "  ${GREEN}1${NC}. Buka panel URL di browser"
  echo -e "  ${GREEN}2${NC}. Hard refresh: ${DIM}Ctrl+Shift+R${NC} atau ${DIM}Ctrl+F5${NC}"
  echo -e "  ${GREEN}3${NC}. Animasi muncul ~1.8 detik, lalu fade out"
  echo -e "                                                       "
  echo -e "  ${YELLOW}File dimodifikasi:${NC}"
  echo -e "  ${DIM}  • $INDEX_FILE (loader injected)${NC}"
  echo -e "  ${DIM}  • $INDEX_FILE.orig (backup original)${NC}"
  echo -e "                                                       "
  echo -e "  ${YELLOW}Untuk UNINSTALL:${NC}"
  echo -e "  ${DIM}  sudo bash $0 --uninstall${NC}"
  echo -e "                                                       "
  echo -e "  ${YELLOW}Troubleshoot jika animasi tidak muncul:${NC}"
  echo -e "  ${DIM}  1. Hard refresh browser (Ctrl+F5)${NC}"
  echo -e "  ${DIM}  2. Cek: grep CLOUD_SERVER_LOADER $INDEX_FILE${NC}"
  echo -e "  ${DIM}  3. Reload: sudo systemctl reload nginx${NC}"
  echo -e "  ${DIM}  4. Cek log: sudo tail -f /var/log/nginx/error.log${NC}"
  echo -e "                                                       "
}

# ====================================================================
# Uninstaller
# ====================================================================
uninstall_loader() {
  echo -e "${YELLOW}[+] Uninstall loading animation...${NC}"
  if [ -f "$INDEX_FILE.orig" ]; then
    sudo cp "$INDEX_FILE.orig" "$INDEX_FILE"
    sudo chown www-data:www-data "$INDEX_FILE" 2>/dev/null
    sudo chmod 644 "$INDEX_FILE" 2>/dev/null
    echo -e "${GREEN}    ✓ Restored dari .orig${NC}"
  else
    # Manual: hapus block dengan Python
    sudo python3 << 'PYEOF'
import re
index_file = "/var/www/pterodactyl/public/index.html"
with open(index_file, 'r') as f:
    content = f.read()
content = re.sub(r'<!-- CLOUD_SERVER_LOADER_START -->.*?<!-- CLOUD_SERVER_LOADER_END -->\n*', '', content, flags=re.DOTALL)
with open(index_file, 'w') as f:
    f.write(content)
print("  ✓ Block loader dihapus via Python")
PYEOF
  fi
  sudo systemctl reload nginx 2>/dev/null || sudo systemctl restart nginx 2>/dev/null
  echo -e "${GREEN}    ✓ nginx reloaded${NC}"
  echo -e "${GREEN}✓ Uninstall selesai${NC}"
  exit 0
}

# ====================================================================
# MAIN
# ====================================================================
banner

if [ "$1" = "--uninstall" ] || [ "$1" = "-u" ]; then
  uninstall_loader
fi

check_panel
generate_loader
inject_loader
restart_services
verify_loader
finalize
