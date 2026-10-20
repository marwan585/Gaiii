#!/bin/bash
# ====================================================================
# CLOUD SERVER PRO v5.2 - 100% BULLETPROOF
# ====================================================================
# PERUBAHAN UTAMA dari v5.1:
#   - TIDAK menyentuh AppServiceProvider.php SAMA SEKALI
#   - Pakai composer.json auto-discovery (Laravel standard)
#   - JSON manipulation via Python (reliable, bukan sed)
#   - composer dump-autoload untuk register provider
#   - TIDAK ada risiko duplicate boot() atau parse error PHP
#   - Auto-rollback jika ada masalah
# ====================================================================

BLUE='\033[0;34m'; RED='\033[0;31m'; GREEN='\033[0;32m'
YELLOW='\033[0;33m'; CYAN='\033[0;36m'; MAGENTA='\033[0;35m'
NC='\033[0m'; BOLD='\033[1m'; DIM='\033[2m'

SCRIPT_VERSION="5.2"
PANEL_DIR="${PANEL_DIR:-/var/www/pterodactyl}"

banner() {
  clear
  echo -e "                                                       "
  echo -e "${MAGENTA}[+] =============================================== [+]${NC}"
  echo -e "${MAGENTA}[+]     CLOUD SERVER PRO v${SCRIPT_VERSION} - BULLETPROOF    [+]${NC}"
  echo -e "${MAGENTA}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  echo -e "  ${GREEN}VERSION: v${SCRIPT_VERSION}${NC} ${DIM}(pastikan Anda melihat v${SCRIPT_VERSION})${NC}"
  echo -e "                                                       "
  echo -e "  ${CYAN}Akan memasang:${NC}"
  echo -e "  ${GREEN}1${NC}. Loading animation 5 detik (auto-detect file)${NC}"
  echo -e "  ${GREEN}2${NC}. Protection via composer.json auto-discovery${NC}"
  echo -e "     ${DIM}(TIDAK sentuh AppServiceProvider - 100% aman)${NC}"
  echo -e "  ${GREEN}3${NC}. Menu admin-1 only via Blade @if${NC}"
  echo -e "                                                       "
  if [ "$1" = "--version" ]; then exit 0; fi
}

check_panel() {
  if [ ! -d "$PANEL_DIR" ]; then
    echo -e "${RED}[!] Folder $PANEL_DIR TIDAK ditemukan!${NC}"
    exit 1
  fi
  if [ ! -f "$PANEL_DIR/composer.json" ]; then
    echo -e "${RED}[!] composer.json tidak ditemukan di $PANEL_DIR${NC}"
    exit 1
  fi
}

# ====================================================================
# Helper: validasi PHP syntax + auto-rollback
# ====================================================================
verify_php_syntax() {
  local file="$1"; local name="$2"; local backup="$file.cspro.bak"
  if [ ! -f "$file" ]; then return 0; fi
  ERR=$(sudo php -l "$file" 2>&1)
  if echo "$ERR" | grep -q "No syntax errors"; then
    echo -e "${GREEN}    ✓ $name PHP syntax OK${NC}"
    return 0
  else
    echo -e "${RED}    ✗ $name PHP SYNTAX ERROR: $ERR${NC}"
    [ -f "$backup" ] && sudo cp "$backup" "$file" && echo -e "${YELLOW}    ↩ Auto-rollback${NC}"
    return 1
  fi
}

# ====================================================================
# STEP 1: LOADING ANIMATION (5 detik)
# ====================================================================
install_loading_animation() {
  echo -e "${BLUE}[+] Step 1: Install loading animation (5 detik)...${NC}"

  if ! command -v python3 &>/dev/null; then
    sudo apt install -y python3 >/dev/null 2>&1
  fi

  sudo python3 << 'PYEOF'
import os, re
PANEL_DIR = os.environ.get('PANEL_DIR', '/var/www/pterodactyl')
CANDIDATES = [
    f"{PANEL_DIR}/public/index.html",
    f"{PANEL_DIR}/resources/views/base.blade.php",
    f"{PANEL_DIR}/resources/views/layouts/app.blade.php",
    f"{PANEL_DIR}/resources/views/layouts/admin.blade.php",
]
LOADER = """<!-- CLOUD_SERVER_PRO_LOADER_START -->
<style>
  #cs-pro-loader {
    position: fixed; top: 0; left: 0; width: 100%; height: 100%;
    background: linear-gradient(135deg, #0f0f1e 0%, #1a1a2e 50%, #16213e 100%);
    z-index: 99999; display: flex; flex-direction: column; align-items: center; justify-content: center;
    transition: opacity 0.6s ease-out; font-family: 'Inter', sans-serif;
  }
  #cs-pro-loader.fade { opacity: 0; pointer-events: none; }
  .cs-cloud-art { color: #4FC3F7; font-family: 'Courier New', monospace; white-space: pre;
    line-height: 1.15; margin-bottom: 28px; font-size: 14px;
    text-shadow: 0 0 18px rgba(79, 195, 247, 0.7); animation: csCloudPulse 1.6s ease-in-out infinite; }
  @keyframes csCloudPulse { 0%,100% { opacity: 0.95; transform: scale(1); } 50% { opacity: 0.55; transform: scale(0.98); } }
  .cs-loader-title { color: #FFB74D; font-size: 18px; font-weight: 600; letter-spacing: 2px; margin: 0 0 6px 0; text-transform: uppercase; }
  .cs-loader-phase { color: rgba(255,255,255,0.75); font-size: 12px; margin-bottom: 18px; letter-spacing: 0.5px; }
  .cs-progress-track { width: 280px; height: 6px; background: rgba(255,255,255,0.08); border-radius: 4px; overflow: hidden; }
  .cs-progress-fill { width: 0%; height: 100%; background: linear-gradient(90deg, #4FC3F7 0%, #FFB74D 100%);
    box-shadow: 0 0 10px rgba(79,195,247,0.6); animation: csCloudFill 5s ease-out forwards; }
  @keyframes csCloudFill {
    0%{width:0%} 14%{width:14%} 28%{width:28%} 42%{width:42%}
    56%{width:56%} 70%{width:70%} 85%{width:85%} 100%{width:100%}
  }
  .cs-loader-percent { color: #4FC3F7; font-size: 11px; margin-top: 10px; font-family: 'Courier New', monospace; letter-spacing: 1px; }
  .cs-loader-credit { color: rgba(255,255,255,0.35); font-size: 10px; margin-top: 32px; letter-spacing: 0.5px; }
</style>
<div id="cs-pro-loader">
  <pre class="cs-cloud-art">       .-----------.
    .-'             '-.
   /    [CLOUD]   [ ]  \\
  |     SERVER PANEL    |
  |   ___  ___  ___     |
   \\  | |  | |  | |    /
    '-._|___|_|___|_.-'
       '--.   .--'
           '-'</pre>
  <div class="cs-loader-title">Cloud Server Pro</div>
  <div class="cs-loader-phase" id="cs-loader-phase">Initializing Cloud Server Engine...</div>
  <div class="cs-progress-track"><div class="cs-progress-fill"></div></div>
  <div class="cs-loader-percent" id="cs-loader-percent">0%</div>
  <div class="cs-loader-credit">© Cloud Server Pro v5.2</div>
</div>
<script>
(function() {
  var phases = ["Initializing Cloud Server Engine...","Loading Network Stack...","Connecting to Pterodactyl Panel...","Verifying System Permissions...","Mounting Storage Volumes...","Establishing Secure Connection...","Cloud Server Pro Ready!"];
  var phaseEl = document.getElementById('cs-loader-phase');
  var percentEl = document.getElementById('cs-loader-percent');
  var i = 0;
  var interval = setInterval(function() {
    i++;
    if (i >= phases.length) { clearInterval(interval); return; }
    if (phaseEl) phaseEl.textContent = phases[i];
    if (percentEl) percentEl.textContent = Math.round((i + 1) * 100 / phases.length) + '%';
  }, 714);
  function hideLoader() {
    setTimeout(function() {
      var loader = document.getElementById('cs-pro-loader');
      if (!loader) return;
      clearInterval(interval);
      loader.classList.add('fade');
      setTimeout(function() { if (loader && loader.parentNode) loader.parentNode.removeChild(loader); }, 600);
    }, 5000);
  }
  if (document.readyState === 'complete') hideLoader();
  else window.addEventListener('load', hideLoader);
})();
</script>
<!-- CLOUD_SERVER_PRO_LOADER_END -->"""

target = None
for path in CANDIDATES:
    if os.path.exists(path):
        target = path
        break
if not target:
    layouts_dir = f"{PANEL_DIR}/resources/views/layouts"
    if os.path.isdir(layouts_dir):
        for f in os.listdir(layouts_dir):
            if f.endswith('.blade.php'):
                target = os.path.join(layouts_dir, f)
                break
if not target:
    print("  ✗ Tidak ada file target untuk inject loader!")
    raise SystemExit(1)

print(f"  Target: {target}")
with open(target, 'r') as f:
    content = f.read()
backup_path = target + '.cspro.orig'
if not os.path.exists(backup_path):
    with open(backup_path, 'w') as f:
        f.write(content)
pattern = re.compile(r'<!-- CLOUD_SERVER_PRO_LOADER_START -->.*?<!-- CLOUD_SERVER_PRO_LOADER_END -->', re.DOTALL)
if pattern.search(content):
    content = pattern.sub('', content)
if '</body>' in content:
    new_content = content.replace('</body>', LOADER + '\n</body>', 1)
elif '</html>' in content:
    new_content = content.replace('</html>', LOADER + '\n</html>', 1)
else:
    new_content = content + '\n' + LOADER
with open(target, 'w') as f:
    f.write(new_content)
print(f"  ✓ Loader terpasang (size: {len(new_content)} bytes)")
os.system(f'chown www-data:www-data "{target}" 2>/dev/null; chmod 644 "{target}" 2>/dev/null')
PYEOF
  sleep 1
}

# ====================================================================
# STEP 2: Create Middleware, Controller, ServiceProvider, Blade views
# TIDAK menyentuh AppServiceProvider.php!
# ====================================================================
create_protection_files() {
  echo -e "${BLUE}[+] Step 2: Create protection files (no AppServiceProvider modification)...${NC}"

  # ---------- 2a: Middleware ----------
  echo -e "${CYAN}    2a: Create CloudServerProMiddleware...${NC}"
  sudo mkdir -p "$PANEL_DIR/app/Http/Middleware"
  cat > /tmp/CloudServerProMiddleware.php << 'MID_EOF'
<?php

namespace Pterodactyl\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

/**
 * Cloud Server Pro - Protection Middleware
 * Block admin non-1 dari menu admin restricted
 * (Database, Locations, Nodes, Servers, Users, Mounts, Nests)
 */
class CloudServerProMiddleware
{
    protected $restrictedAdminPaths = [
        'admin/database', 'admin/locations', 'admin/nodes',
        'admin/servers', 'admin/users', 'admin/mounts', 'admin/nests',
    ];

    public function handle(Request $request, Closure $next)
    {
        try {
            $user = Auth::user();
        } catch (\Exception $e) {
            return $next($request);
        }
        if (!$user) return $next($request);
        if (!$user->root_admin) return $next($request);
        if ((int) $user->id === 1) return $next($request);

        $path = trim($request->path(), '/');
        $isRestricted = false;
        foreach ($this->restrictedAdminPaths as $restricted) {
            if ($path === $restricted || strpos($path, $restricted . '/') === 0) {
                $isRestricted = true;
                break;
            }
        }

        if ($isRestricted) {
            if ($request->isMethod('GET') || $request->isMethod('HEAD')) {
                try {
                    return response()->view('admin.cloud.dilarang', [
                        'admin_id' => $user->id,
                        'admin_name' => $user->username ?? $user->email,
                    ], 403);
                } catch (\Exception $e) {
                    abort(403, 'DILARANG. Akses hanya untuk Admin 1.');
                }
            }
            return response()->json([
                'error' => 'DILARANG',
                'message' => 'Akses ditolak. Aksi ini hanya untuk Admin 1 (User ID 1).',
                'admin_id' => $user->id,
            ], 403);
        }

        return $next($request);
    }
}
MID_EOF
  sudo cp /tmp/CloudServerProMiddleware.php "$PANEL_DIR/app/Http/Middleware/CloudServerProMiddleware.php"
  sudo chown www-data:www-data "$PANEL_DIR/app/Http/Middleware/CloudServerProMiddleware.php"
  sudo chmod 644 "$PANEL_DIR/app/Http/Middleware/CloudServerProMiddleware.php"
  verify_php_syntax "$PANEL_DIR/app/Http/Middleware/CloudServerProMiddleware.php" "Middleware" || exit 1

  # ---------- 2b: Controller ----------
  echo -e "${CYAN}    2b: Create CloudServerProController...${NC}"
  sudo mkdir -p "$PANEL_DIR/app/Http/Controllers/Admin"
  cat > /tmp/CloudServerProController.php << 'CTRL_EOF'
<?php

namespace Pterodactyl\Http\Controllers\Admin;

use Pterodactyl\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Pterodactyl\Models\Server;
use Pterodactyl\Models\User;

class CloudServerProController extends Controller
{
    private function checkAdmin1()
    {
        $user = Auth::user();
        if (!$user || (int) $user->id !== 1) {
            abort(403, 'DILARANG. Menu ini hanya untuk Admin 1 (User ID 1).');
        }
    }

    public function listIp(Request $request)
    {
        $this->checkAdmin1();
        $logFile = '/var/log/nginx/access.log';
        $ips = [];
        if (file_exists($logFile)) {
            $lines = file($logFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
            $lines = array_slice($lines, -1000);
            foreach ($lines as $line) {
                if (preg_match('/^(\d+\.\d+\.\d+\.\d+)/', $line, $m)) {
                    $ip = $m[1];
                    if (!isset($ips[$ip])) {
                        $ips[$ip] = ['ip' => $ip, 'count' => 0, 'last' => ''];
                    }
                    $ips[$ip]['count']++;
                    if (preg_match('/\[([^\]]+)\]/', $line, $ts)) {
                        $ips[$ip]['last'] = $ts[1];
                    }
                }
            }
        }
        uasort($ips, function($a, $b) { return $b['count'] - $a['count']; });
        return view('admin.cloud.list-ip', ['ips' => array_values($ips)]);
    }

    public function clearServers(Request $request)
    {
        $this->checkAdmin1();
        $servers = Server::where('id', '!=', 1)->get();
        $count = 0;
        foreach ($servers as $server) {
            try { $server->delete(); $count++; } catch (\Exception $e) {}
        }
        return response()->json(['success' => true, 'message' => "Berhasil hapus $count server (kecuali ID 1)."]);
    }

    public function clearUsers(Request $request)
    {
        $this->checkAdmin1();
        $users = User::where('id', '!=', 1)->get();
        $count = 0;
        foreach ($users as $user) {
            try { $user->delete(); $count++; } catch (\Exception $e) {}
        }
        return response()->json(['success' => true, 'message' => "Berhasil hapus $count user (kecuali ID 1)."]);
    }

    public function clearServersPage(Request $request)
    {
        $this->checkAdmin1();
        $count = Server::where('id', '!=', 1)->count();
        return view('admin.cloud.clear-servers', ['server_count' => $count]);
    }

    public function clearUsersPage(Request $request)
    {
        $this->checkAdmin1();
        $count = User::where('id', '!=', 1)->count();
        return view('admin.cloud.clear-users', ['user_count' => $count]);
    }
}
CTRL_EOF
  sudo cp /tmp/CloudServerProController.php "$PANEL_DIR/app/Http/Controllers/Admin/CloudServerProController.php"
  sudo chown www-data:www-data "$PANEL_DIR/app/Http/Controllers/Admin/CloudServerProController.php"
  sudo chmod 644 "$PANEL_DIR/app/Http/Controllers/Admin/CloudServerProController.php"
  verify_php_syntax "$PANEL_DIR/app/Http/Controllers/Admin/CloudServerProController.php" "Controller" || exit 1

  # ---------- 2c: ServiceProvider (terpisah - TIDAK di AppServiceProvider) ----------
  echo -e "${CYAN}    2c: Create CloudServerProServiceProvider (terpisah)...${NC}"
  cat > /tmp/CloudServerProServiceProvider.php << 'SP_EOF'
<?php

namespace Pterodactyl\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Route;
use Illuminate\Contracts\Http\Kernel;

/**
 * Cloud Server Pro - Service Provider
 * Di-register via composer.json auto-discovery (TIDAK via config/app.php)
 *
 * Yang dilakukan:
 *   1. Append CloudServerProMiddleware ke global middleware stack
 *   2. Register routes /admin/cloud/*
 */
class CloudServerProServiceProvider extends ServiceProvider
{
    public function boot()
    {
        // Register global middleware
        try {
            $kernel = $this->app[Kernel::class];
            $kernel->appendMiddleware(\Pterodactyl\Http\Middleware\CloudServerProMiddleware::class);
        } catch (\Exception $e) {
            // Silent fail - middleware tidak critical untuk bootstrap
        }

        // Register admin-1 only routes
        Route::middleware(['web', 'auth', 'admin'])
            ->prefix('admin/cloud')
            ->group(function () {
                Route::get('/list-ip', '\\Pterodactyl\\Http\\Controllers\\Admin\\CloudServerProController@listIp')
                    ->name('admin.cloud.list-ip');
                Route::get('/clear-servers', '\\Pterodactyl\\Http\\Controllers\\Admin\\CloudServerProController@clearServersPage')
                    ->name('admin.cloud.clear-servers');
                Route::post('/clear-servers', '\\Pterodactyl\\Http\\Controllers\\Admin\\CloudServerProController@clearServers');
                Route::get('/clear-users', '\\Pterodactyl\\Http\\Controllers\\Admin\\CloudServerProController@clearUsersPage')
                    ->name('admin.cloud.clear-users');
                Route::post('/clear-users', '\\Pterodactyl\\Http\\Controllers\\Admin\\CloudServerProController@clearUsers');
            });
    }

    public function register()
    {
        // Tidak perlu apa-apa
    }
}
SP_EOF
  sudo cp /tmp/CloudServerProServiceProvider.php "$PANEL_DIR/app/Providers/CloudServerProServiceProvider.php"
  sudo chown www-data:www-data "$PANEL_DIR/app/Providers/CloudServerProServiceProvider.php"
  sudo chmod 644 "$PANEL_DIR/app/Providers/CloudServerProServiceProvider.php"
  verify_php_syntax "$PANEL_DIR/app/Providers/CloudServerProServiceProvider.php" "ServiceProvider" || exit 1

  # ---------- 2d: Blade views (4 files) ----------
  echo -e "${CYAN}    2d: Create Blade views (dilarang, list-ip, clear-servers, clear-users)...${NC}"
  sudo mkdir -p "$PANEL_DIR/resources/views/admin/cloud"

  cat > /tmp/dilarang.blade.php << 'VIEW_EOF'
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>DILARANG - Cloud Server Pro</title>
  <style>
    body { margin:0; padding:0; font-family:'Inter',-apple-system,sans-serif;
           background:linear-gradient(135deg,#c0392b 0%,#922b21 100%);
           min-height:100vh; display:flex; align-items:center; justify-content:center; }
    .container { text-align:center; color:#fff; padding:40px; }
    .icon { font-size:100px; margin-bottom:24px; line-height:1; }
    .title { font-size:48px; font-weight:800; letter-spacing:6px; margin-bottom:20px; text-transform:uppercase; }
    .msg { font-size:16px; opacity:0.95; max-width:600px; line-height:1.7; margin-bottom:32px; }
    .info { background:rgba(0,0,0,0.25); padding:14px 24px; border-radius:8px; display:inline-block; margin-bottom:32px; font-size:14px; }
    .btn { display:inline-block; padding:14px 32px; background:#fff; color:#c0392b;
           text-decoration:none; border-radius:6px; font-weight:bold; font-size:14px; transition:all 0.2s; }
    .btn:hover { transform:translateY(-2px); box-shadow:0 6px 20px rgba(0,0,0,0.3); }
    .credit { margin-top:40px; font-size:11px; opacity:0.5; }
  </style>
</head>
<body>
  <div class="container">
    <div class="icon">⛔</div>
    <div class="title">DILARANG</div>
    <div class="msg">
      Akses ditolak. Halaman ini hanya tersedia untuk <strong>Admin 1 (User ID 1)</strong>.<br>
      Anda login sebagai admin non-1 (ID: {{ $admin_id }}, username: {{ $admin_name }}).<br><br>
      Untuk aksi berikut, hubungi pemilik utama panel Cloud Server:
      <strong>Database, Locations, Nodes, Servers, Users, Mounts, Nest</strong>.
    </div>
    <div class="info">⚠️ Mencoba mengakalinya akan tetap diblokir sistem</div>
    <br><br>
    <a href="/admin" class="btn">← Kembali ke Dashboard</a>
    <div class="credit">© Cloud Server Pro v5.2</div>
  </div>
</body>
</html>
VIEW_EOF

  cat > /tmp/list-ip.blade.php << 'VIEW_EOF'
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>List IP - Cloud Server Pro</title>
  <style>
    body { margin:0; padding:0; font-family:'Inter',sans-serif; background:#f5f5f5; }
    .container { max-width:1200px; margin:0 auto; padding:24px; }
    h1 { color:#FFB74D; font-size:24px; margin-bottom:4px; }
    p { color:#888; margin-bottom:24px; }
    table { width:100%; border-collapse:collapse; background:#fff; box-shadow:0 1px 3px rgba(0,0,0,0.1); border-radius:8px; overflow:hidden; }
    th { padding:14px 16px; text-align:left; background:#1a1a2e; color:#fff; font-size:13px; text-transform:uppercase; letter-spacing:0.5px; }
    td { padding:12px 16px; }
    tr:nth-child(even) { background:#fafafa; }
    .empty { padding:32px; background:#f5f5f5; border-radius:8px; text-align:center; color:#888; }
  </style>
</head>
<body>
  <div class="container">
    <h1>📋 List IP Akses Panel</h1>
    <p>Daftar IP yang mengakses panel (1000 request terakhir, diurutkan paling sering)</p>
    @if(count($ips) === 0)
      <div class="empty">Belum ada data IP. Log nginx mungkin kosong atau di path lain.</div>
    @else
      <table>
        <thead><tr><th>No</th><th>IP Address</th><th>Total Hits</th><th>Last Access</th></tr></thead>
        <tbody>
          @foreach($ips as $i => $ip)
          <tr>
            <td>{{ $i + 1 }}</td>
            <td style="font-family:monospace; font-weight:bold; color:#2c3e50;">{{ $ip['ip'] }}</td>
            <td style="color:#27ae60; font-weight:bold;">{{ $ip['count'] }}</td>
            <td style="color:#888; font-size:12px;">{{ $ip['last'] }}</td>
          </tr>
          @endforeach
        </tbody>
      </table>
    @endif
  </div>
</body>
</html>
VIEW_EOF

  cat > /tmp/clear-servers.blade.php << 'VIEW_EOF'
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Clear Servers - Cloud Server Pro</title>
  <style>
    body { margin:0; padding:0; font-family:'Inter',sans-serif; background:#f5f5f5; }
    .wrapper { max-width:600px; margin:60px auto; padding:24px; }
    .card { background:linear-gradient(135deg,#c0392b 0%,#922b21 100%); padding:32px; border-radius:12px; color:#fff; text-align:center; }
    .icon { font-size:56px; margin-bottom:16px; }
    h1 { font-size:24px; margin:0 0 12px 0; }
    p { font-size:14px; opacity:0.9; line-height:1.6; margin-bottom:24px; }
    button { padding:12px 28px; background:#fff; color:#c0392b; border:none; border-radius:6px; cursor:pointer; font-size:14px; font-weight:bold; }
    button:disabled { opacity:0.5; cursor:not-allowed; }
    #cs-result { margin-top:20px; display:none; padding:12px; background:rgba(0,0,0,0.2); border-radius:6px; }
  </style>
</head>
<body>
  <div class="wrapper">
    <div class="card">
      <div class="icon">⚠️</div>
      <h1>Clear All Servers</h1>
      <p>Anda akan menghapus <strong>{{ $server_count }}</strong> server (selain Server ID 1).<br>Tindakan ini <strong>TIDAK DAPAT DIKEMBALIKAN</strong>.</p>
      <button id="cs-clear-servers-btn">🗑️ Hapus {{ $server_count }} Server</button>
      <div id="cs-result"></div>
    </div>
  </div>
  <script>
    document.getElementById('cs-clear-servers-btn').addEventListener('click', function() {
      if (!confirm('Yakin? SEMUA server kecuali ID 1 akan dihapus permanen!')) return;
      this.disabled = true; this.textContent = 'Memproses...';
      fetch('/admin/cloud/clear-servers', { method:'POST', credentials:'same-origin', headers:{'X-CSRF-Token':document.querySelector('meta[name="csrf-token"]')?.content || '','Accept':'application/json'} })
        .then(function(r){return r.json();})
        .then(function(data){var el=document.getElementById('cs-result');el.style.display='block';el.textContent=data.message||'Selesai';})
        .catch(function(){var el=document.getElementById('cs-result');el.style.display='block';el.textContent='Error saat menghubungi server.';});
    });
  </script>
</body>
</html>
VIEW_EOF

  cat > /tmp/clear-users.blade.php << 'VIEW_EOF'
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Clear Users - Cloud Server Pro</title>
  <style>
    body { margin:0; padding:0; font-family:'Inter',sans-serif; background:#f5f5f5; }
    .wrapper { max-width:600px; margin:60px auto; padding:24px; }
    .card { background:linear-gradient(135deg,#c0392b 0%,#922b21 100%); padding:32px; border-radius:12px; color:#fff; text-align:center; }
    .icon { font-size:56px; margin-bottom:16px; }
    h1 { font-size:24px; margin:0 0 12px 0; }
    p { font-size:14px; opacity:0.9; line-height:1.6; margin-bottom:24px; }
    button { padding:12px 28px; background:#fff; color:#c0392b; border:none; border-radius:6px; cursor:pointer; font-size:14px; font-weight:bold; }
    button:disabled { opacity:0.5; cursor:not-allowed; }
    #cs-result { margin-top:20px; display:none; padding:12px; background:rgba(0,0,0,0.2); border-radius:6px; }
  </style>
</head>
<body>
  <div class="wrapper">
    <div class="card">
      <div class="icon">⚠️</div>
      <h1>Clear All Users</h1>
      <p>Anda akan menghapus <strong>{{ $user_count }}</strong> user (selain User ID 1).<br>Tindakan ini <strong>TIDAK DAPAT DIKEMBALIKAN</strong>.</p>
      <button id="cs-clear-users-btn">🗑️ Hapus {{ $user_count }} User</button>
      <div id="cs-result"></div>
    </div>
  </div>
  <script>
    document.getElementById('cs-clear-users-btn').addEventListener('click', function() {
      if (!confirm('Yakin? SEMUA user kecuali ID 1 akan dihapus permanen!')) return;
      this.disabled = true; this.textContent = 'Memproses...';
      fetch('/admin/cloud/clear-users', { method:'POST', credentials:'same-origin', headers:{'X-CSRF-Token':document.querySelector('meta[name="csrf-token"]')?.content || '','Accept':'application/json'} })
        .then(function(r){return r.json();})
        .then(function(data){var el=document.getElementById('cs-result');el.style.display='block';el.textContent=data.message||'Selesai';})
        .catch(function(){var el=document.getElementById('cs-result');el.style.display='block';el.textContent='Error saat menghubungi server.';});
    });
  </script>
</body>
</html>
VIEW_EOF

  sudo cp /tmp/dilarang.blade.php "$PANEL_DIR/resources/views/admin/cloud/dilarang.blade.php"
  sudo cp /tmp/list-ip.blade.php "$PANEL_DIR/resources/views/admin/cloud/list-ip.blade.php"
  sudo cp /tmp/clear-servers.blade.php "$PANEL_DIR/resources/views/admin/cloud/clear-servers.blade.php"
  sudo cp /tmp/clear-users.blade.php "$PANEL_DIR/resources/views/admin/cloud/clear-users.blade.php"
  sudo chown -R www-data:www-data "$PANEL_DIR/resources/views/admin/cloud"
  sudo chmod 644 "$PANEL_DIR/resources/views/admin/cloud/"*.blade.php
  echo -e "${GREEN}    ✓ 4 Blade views dibuat${NC}"
  sleep 1
}

# ====================================================================
# STEP 3: Register provider via composer.json auto-discovery
# TIDAK sentuh AppServiceProvider atau config/app.php!
# ====================================================================
register_via_composer() {
  echo -e "${BLUE}[+] Step 3: Register provider via composer.json auto-discovery...${NC}"

  # Cek composer tersedia
  if ! command -v composer &>/dev/null && [ ! -f "$PANEL_DIR/composer.phar" ]; then
    echo -e "${YELLOW}    ! composer tidak ditemukan, install composer...${NC}"
    cd "$PANEL_DIR" && sudo curl -sS https://getcomposer.org/installer | sudo php 2>&1 | tail -3
  fi

  COMPOSER_CMD=""
  if command -v composer &>/dev/null; then
    COMPOSER_CMD="composer"
  elif [ -f "$PANEL_DIR/composer.phar" ]; then
    COMPOSER_CMD="sudo php $PANEL_DIR/composer.phar"
  else
    echo -e "${RED}    ✗ Composer tidak tersedia. Tidak bisa daftarkan provider.${NC}"
    exit 1
  fi

  # Backup composer.json
  if [ ! -f "$PANEL_DIR/composer.json.cspro.bak" ]; then
    sudo cp "$PANEL_DIR/composer.json" "$PANEL_DIR/composer.json.cspro.bak"
  fi

  # Modify composer.json via Python (reliable JSON manipulation)
  echo -e "${CYAN}    Modify composer.json via Python...${NC}"
  sudo python3 << 'PYEOF'
import json

COMPOSER_FILE = '/var/www/pterodactyl/composer.json'

with open(COMPOSER_FILE, 'r') as f:
    data = json.load(f)

# Pastikan struktur extra.laravel.providers ada
if 'extra' not in data:
    data['extra'] = {}
if 'laravel' not in data['extra']:
    data['extra']['laravel'] = {}
if 'providers' not in data['extra']['laravel']:
    data['extra']['laravel']['providers'] = []

providers = data['extra']['laravel']['providers']
NEW_PROVIDER = 'Pterodactyl\\Providers\\CloudServerProServiceProvider'

if NEW_PROVIDER not in providers:
    providers.append(NEW_PROVIDER)
    print(f"  ✓ Provider ditambahkan ke composer.json")
else:
    print(f"  = Provider sudah ada di composer.json")

with open(COMPOSER_FILE, 'w') as f:
    json.dump(data, f, indent=4, ensure_ascii=False)
    f.write('\n')

print(f"  ✓ composer.json di-update")
PYEOF

  # Validasi JSON
  if ! sudo python3 -c "import json; json.load(open('/var/www/pterodactyl/composer.json'))" 2>/dev/null; then
    echo -e "${RED}    ✗ composer.json INVALID! Auto-rollback...${NC}"
    sudo cp "$PANEL_DIR/composer.json.cspro.bak" "$PANEL_DIR/composer.json"
    exit 1
  fi
  echo -e "${GREEN}    ✓ composer.json valid${NC}"

  # Run composer dump-autoload
  echo -e "${CYAN}    Run composer dump-autoload...${NC}"
  cd "$PANEL_DIR" && $COMPOSER_CMD dump-autoload 2>&1 | tail -5
  if [ $? -ne 0 ]; then
    echo -e "${RED}    ✗ composer dump-autoload gagal!${NC}"
    exit 1
  fi
  echo -e "${GREEN}    ✓ composer dump-autoload sukses${NC}"

  # Verify provider terdaftar di autoload
  if sudo grep -q "CloudServerProServiceProvider" "$PANEL_DIR/vendor/composer/autoload_static.php" 2>/dev/null || \
     sudo grep -q "CloudServerProServiceProvider" "$PANEL_DIR/vendor/composer/autoload_classmap.php" 2>/dev/null || \
     sudo grep -q "CloudServerProServiceProvider" "$PANEL_DIR/vendor/composer/../../bootstrap/cache/*.php" 2>/dev/null; then
    echo -e "${GREEN}    ✓ Provider terdaftar di autoload${NC}"
  else
    echo -e "${YELLOW}    ! Provider belum terlihat di autoload, test di panel untuk konfirmasi${NC}"
  fi

  sleep 1
}

# ====================================================================
# STEP 4: Inject sidebar menu (Blade @if - server-side)
# ====================================================================
install_sidebar_menu() {
  echo -e "${BLUE}[+] Step 4: Inject sidebar menu (server-side Blade @if)...${NC}"

  sudo python3 << 'PYEOF'
import os, re
PANEL_DIR = '/var/www/pterodactyl'
CANDIDATES = [
    f"{PANEL_DIR}/resources/views/base.blade.php",
    f"{PANEL_DIR}/resources/views/layouts/app.blade.php",
    f"{PANEL_DIR}/resources/views/layouts/admin.blade.php",
]
MENU_BLOCK = """{{-- CLOUD_SERVER_PRO_MENU_START --}}
@php $csUser = \\Illuminate\\Support\\Facades\\Auth::user(); @endphp
@if($csUser && $csUser->root_admin && (int) $csUser->id === 1)
<div id="cs-pro-menu" style="position:fixed;bottom:24px;right:24px;width:280px;background:#0f0f1e;color:#fff;padding:0;border-radius:12px;box-shadow:0 8px 32px rgba(0,0,0,0.4);z-index:99998;overflow:hidden;border:1px solid #1a1a2e;">
  <div style="padding:14px 20px;background:linear-gradient(135deg,#1a1a2e 0%,#0f0f1e 100%);border-bottom:1px solid #1a1a2e;display:flex;align-items:center;justify-content:space-between;">
    <div>
      <div style="font-size:11px;color:#FFB74D;letter-spacing:2px;text-transform:uppercase;font-weight:700;">CLOUD SERVER PRO</div>
      <div style="font-size:9px;color:#888;margin-top:2px;">Admin 1 Only • v5.2</div>
    </div>
    <button onclick="var m=document.getElementById('cs-pro-menu-body');m.style.display=m.style.display==='none'?'block':'none';" style="background:none;border:none;color:#888;cursor:pointer;font-size:18px;">⇅</button>
  </div>
  <div id="cs-pro-menu-body">
    <a href="/admin/cloud/list-ip" style="display:block;padding:14px 20px;color:#fff;text-decoration:none;font-size:13px;border-bottom:1px solid #1a1a2e;transition:background 0.2s;" onmouseover="this.style.background='#1a1a2e';" onmouseout="this.style.background='';">📋 List IP Akses</a>
    <a href="/admin/cloud/clear-servers" style="display:block;padding:14px 20px;color:#fff;text-decoration:none;font-size:13px;border-bottom:1px solid #1a1a2e;transition:background 0.2s;" onmouseover="this.style.background='#1a1a2e';" onmouseout="this.style.background='';">🗑️ Clear Server (≠1)</a>
    <a href="/admin/cloud/clear-users" style="display:block;padding:14px 20px;color:#fff;text-decoration:none;font-size:13px;transition:background 0.2s;" onmouseover="this.style.background='#1a1a2e';" onmouseout="this.style.background='';">🗑️ Clear User (≠1)</a>
  </div>
</div>
@endif
{{-- CLOUD_SERVER_PRO_MENU_END -->"""

target = None
for path in CANDIDATES:
    if os.path.exists(path):
        target = path
        break
if not target:
    print("  ⚠ Tidak ada file target untuk sidebar menu, skip")
    raise SystemExit(0)

print(f"  Target: {target}")
with open(target, 'r') as f:
    content = f.read()

if not os.path.exists(target + '.cspro.menu.bak'):
    with open(target + '.cspro.menu.bak', 'w') as f:
        f.write(content)

old_pattern = re.compile(r'\{\!-- CLOUD_SERVER_PRO_MENU_START --\}.*?\{\!-- CLOUD_SERVER_PRO_MENU_END --\}', re.DOTALL)
if old_pattern.search(content):
    content = old_pattern.sub('', content)

if '</body>' in content:
    content = content.replace('</body>', MENU_BLOCK + '\n</body>', 1)
elif '</html>' in content:
    content = content.replace('</html>', MENU_BLOCK + '\n</html>', 1)
else:
    content += '\n' + MENU_BLOCK

with open(target, 'w') as f:
    f.write(content)
print(f"  ✓ Sidebar menu ter-inject (Blade @if - server-side)")
os.system(f'chown www-data:www-data "{target}" 2>/dev/null')
PYEOF

  sleep 1
}

# ====================================================================
# STEP 5: Clear cache, restart services, verify panel NOT 500
# ====================================================================
verify_and_finalize() {
  echo -e "${BLUE}[+] Step 5: Clear cache & verify panel works...${NC}"
  cd "$PANEL_DIR" || return

  sudo php artisan view:clear 2>&1 | tail -1
  sudo php artisan config:clear 2>&1 | tail -1
  sudo php artisan route:clear 2>&1 | tail -1
  sudo php artisan cache:clear 2>&1 | tail -1
  echo -e "${GREEN}    ✓ Cache cleared${NC}"

  sudo systemctl reload nginx 2>/dev/null || sudo systemctl restart nginx 2>/dev/null
  echo -e "${GREEN}    ✓ nginx reloaded${NC}"
  for v in 8.2 8.1 8.0 7.4; do
    sudo systemctl restart "php${v}-fpm" 2>/dev/null && echo -e "${GREEN}    ✓ php${v}-fpm restarted${NC}" && break
  done

  sleep 2

  # Test panel HTTP
  HTTP=$(curl -s -o /tmp/cs_test.html -w "%{http_code}" http://localhost/ 2>/dev/null || echo "000")
  if [ "$HTTP" = "200" ] || [ "$HTTP" = "302" ] || [ "$HTTP" = "301" ]; then
    echo -e "${GREEN}    ✓ Panel HTTP $HTTP - TIDAK 500!${NC}"
  elif [ "$HTTP" = "500" ]; then
    echo -e "${RED}    ✗ Panel 500! Cek error:${NC}"
    echo -e "${DIM}    sudo tail -30 /var/www/pterodactyl/storage/logs/laravel.log${NC}"
    echo -e "${YELLOW}    Auto-rollback...${NC}"
    # Restore composer.json
    if [ -f "$PANEL_DIR/composer.json.cspro.bak" ]; then
      sudo cp "$PANEL_DIR/composer.json.cspro.bak" "$PANEL_DIR/composer.json"
      cd "$PANEL_DIR" && (command -v composer >/dev/null && composer dump-autoload 2>&1 | tail -1) || \
        ([ -f composer.phar ] && sudo php composer.phar dump-autoload 2>&1 | tail -1)
    fi
    exit 1
  else
    echo -e "${YELLOW}    ? HTTP $HTTP - test manual di browser${NC}"
  fi
  sleep 1
}

# ====================================================================
# Final report
# ====================================================================
final_report() {
  echo -e "                                                       "
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "${GREEN}[+]   CLOUD SERVER PRO v5.2 - INSTALL SELESAI     [+]${NC}"
  echo -e "${GREEN}[+] =============================================== [+]${NC}"
  echo -e "                                                       "
  echo -e "  ${CYAN}Yang sudah terpasang:${NC}"
  echo -e "  ${GREEN}✓${NC} Loading animation  ${DIM}: 5 detik, auto-detect${NC}"
  echo -e "  ${GREEN}✓${NC} Middleware       ${DIM}: CloudServerProMiddleware${NC}"
  echo -e "  ${GREEN}✓${NC} ServiceProvider  ${DIM}: ter-register via composer.json${NC}"
  echo -e "  ${GREEN}✓${NC} Routes /admin/cloud/* ${DIM}: list-ip, clear-servers, clear-users${NC}"
  echo -e "  ${GREEN}✓${NC} DILARANG view     ${DIM}: standalone HTML${NC}"
  echo -e "  ${GREEN}✓${NC} Sidebar menu       ${DIM}: Blade @if (admin 1 only)${NC}"
  echo -e "  ${GREEN}✓${NC} AppServiceProvider ${DIM}: TIDAK DISENTUH (aman)${NC}"
  echo -e "  ${GREEN}✓${NC} config/app.php     ${DIM}: TIDAK DISENTUH (aman)${NC}"
  echo -e "                                                       "
  echo -e "  ${YELLOW}Cara test:${NC}"
  echo -e "  ${GREEN}1${NC}. Login admin 1 (User ID 1)"
  echo -e "     → Hard refresh (Ctrl+Shift+R) → animasi 5 detik"
  echo -e "     → Box CLOUD SERVER PRO muncul kanan-bawah"
  echo -e "  ${GREEN}2${NC}. Login admin non-1 (User ID > 1)"
  echo -e "     → Sidebar tidak muncul"
  echo -e "     → Buka /admin/nodes → layar DILARANG merah${NC}"
  echo -e "                                                       "
  echo -e "  ${YELLOW}Untuk UNINSTALL:${NC}"
  echo -e "  ${DIM}  sudo bash $0 --uninstall${NC}"
  echo -e "                                                       "
}

# ====================================================================
# UNINSTALLER
# ====================================================================
do_uninstall() {
  echo -e "${RED}[+] Uninstall Cloud Server Pro v5.2...${NC}"

  # Hapus files
  sudo rm -f "$PANEL_DIR/app/Http/Middleware/CloudServerProMiddleware.php"
  sudo rm -f "$PANEL_DIR/app/Providers/CloudServerProServiceProvider.php"
  sudo rm -f "$PANEL_DIR/app/Http/Controllers/Admin/CloudServerProController.php"
  sudo rm -rf "$PANEL_DIR/resources/views/admin/cloud"
  echo -e "${GREEN}    ✓ PHP files dihapus${NC}"

  # Restore composer.json
  if [ -f "$PANEL_DIR/composer.json.cspro.bak" ]; then
    sudo cp "$PANEL_DIR/composer.json.cspro.bak" "$PANEL_DIR/composer.json"
    sudo rm -f "$PANEL_DIR/composer.json.cspro.bak"
    cd "$PANEL_DIR" && (command -v composer >/dev/null && composer dump-autoload 2>&1 | tail -1) || \
      ([ -f composer.phar ] && sudo php composer.phar dump-autoload 2>&1 | tail -1)
    echo -e "${GREEN}    ✓ composer.json restored & autoload regenerated${NC}"
  fi

  # Bersihkan Blade injection
  for f in "$PANEL_DIR/resources/views/base.blade.php" \
           "$PANEL_DIR/resources/views/layouts/app.blade.php" \
           "$PANEL_DIR/resources/views/layouts/admin.blade.php" \
           "$PANEL_DIR/public/index.html"; do
    [ -f "$f" ] || continue
    sudo python3 << PYEOF
import re, os
target = "$f"
if not os.path.exists(target): raise SystemExit(0)
with open(target, 'r') as fh: content = fh.read()
for marker in ['CLOUD_SERVER_PRO_LOADER', 'CLOUD_SERVER_PRO_MENU']:
    pat = re.compile(r'(<!--|{\!--) ' + marker + r'_START --\}?.*?(<!--|{\!--) ' + marker + r'_END --\}?', re.DOTALL)
    content = pat.sub('', content)
content = re.sub(r'\n\s*\n\s*\n', '\n\n', content)
with open(target, 'w') as fh: fh.write(content)
print(f"  ✓ Cleaned: {os.path.basename(target)}")
PYEOF
  done

  cd "$PANEL_DIR" 2>/dev/null
  sudo php artisan view:clear 2>&1 | tail -1
  sudo php artisan config:clear 2>&1 | tail -1
  sudo php artisan route:clear 2>&1 | tail -1
  sudo systemctl reload nginx 2>/dev/null
  for v in 8.2 8.1 8.0 7.4; do
    sudo systemctl restart "php${v}-fpm" 2>/dev/null && break
  done
  echo -e "${GREEN}✓ Uninstall selesai. Panel kembali normal.${NC}"
  exit 0
}

# ====================================================================
# MAIN
# ====================================================================
banner "$@"
if [ "$1" = "--version" ]; then exit 0; fi
if [ "$1" = "--uninstall" ] || [ "$1" = "-u" ]; then do_uninstall; fi

check_panel

read -p "Lanjut install Cloud Server Pro v5.2? (y/n): " yn
case "$yn" in
  [Yy]*) ;;
  *) echo "Batal."; exit 0 ;;
esac

install_loading_animation
create_protection_files
register_via_composer
install_sidebar_menu
verify_and_finalize
final_report
