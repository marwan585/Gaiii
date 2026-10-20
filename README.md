# :bird: Cloud Server - Pterodactyl Theme Autoinstaller v2.1

## Auto Install Thema Pterodactyl

## Command Install :

```bash
bash <(curl -s https://raw.githubusercontent.com/marwan585/Gaiii/master/install.sh)
```

## :tada: FITUR BARU v2.1

### 1. Animasi Loading 2D Cloud Server (v2.0)
Animasi 4-frame awan + progress bar 7-fase loading saat masuk panel.

### 2. Menu `Uninstall Cloud` (v2.0) - Opsi 9
Hapus **SEMUA** hal tentang Pterodactyl otomatis dalam 15 langkah.

### 3. Menu `Cara Penggunaan` (v2.0) - Opsi 10
Tutorial lengkap dari nol + penjelasan semua opsi.

### 4. :shield: Menu `Install Keamanan` (v2.1 - BARU) - Opsi 11
Auto-install paket keamanan Cloud Server:

#### :floppy_disk: A. Auto-Delete Disk Over-Limit
- Daemon cron tiap 5 menit cek ukuran `/var/lib/pterodactyl/volumes/*`
- Jika server exceed batas (default 10 GB, dapat diatur), **auto-suspend**
- Suspend via Pterodactyl API (Application Token) atau fallback `docker stop`

#### :detective: B. Auto-Delete Suspicious Server
- Cek proses di setiap container pterodactyl (`docker top`)
- Pattern detection: `xmrig`, `cpuminer`, `ccminer`, `ethminer`, `claymore`,
  `PhoenixMiner`, `teamredminer`, `TrexMiner`, `lolMiner`, `minerd`,
  `cryptonight`, `stratum+tcp`, `nanopool`, `f2pool`, `antpool`, dll.
- Jika match → **auto-suspend** + log ke `/var/log/cloud-server/security.log`
- Bonus: CPU abuse detector (>95% sustained, log only - belum suspend)

#### :lock: C. Admin-1 Only Restriction (Panel Frontend)
Hanya **User ID 1** (admin utama) yang boleh:
- Tambah / edit / hapus **Node**
- Tambah / edit / hapus **Location**
- Tambah / edit / hapus **Egg**
- **Hapus server milik user lain**
- **View as user / masuk ke server orang**

Jika admin lain (user ID > 1) mencoba akses → tampil:
```
⛔ DILARANG
Akses ditolak. Halaman ini hanya dapat diakses oleh Admin 1 (User ID 1).
Hubungi pemilik utama panel Cloud Server untuk bantuan.
```

Implementasi via:
- **Laravel middleware** `AdminOneOnly.php` (HTTP 403 untuk non-user-1)
- **React component** `ForbiddenBanner.tsx` (UI warning di admin pages)
- Patch di `NodesContainer`, `LocationsContainer`, `EggContainer`

### 5. Menu `Uninstall Keamanan` (v2.1) - Opsi 12
Hapus semua paket keamanan (cron, monitor.sh, middleware, React patch),
restore komponen admin dari backup, rebuild panel.

## :wrench: FITUR UTAMA

| No | Menu | Deskripsi |
|----|------|-----------|
| 1 | Install Theme | Install tema (Stellar / Billing / Enigma) |
| 2 | Uninstall Theme | Kembalikan tema ke default |
| 3 | Configure Wings | Setup wings daemon dari auto-deploy token |
| 4 | Create Node | Buat lokasi + node baru |
| 5 | Uninstall Panel | Uninstall pterodactyl panel |
| 6 | Stellar Theme | Install tema Stellar (shortcut) |
| 7 | Hack Back Panel | Tambah admin darurat |
| 8 | Ubah Pw VPS | Ganti password root VPS |
| 9 | Uninstall Cloud | [v2.0] Hapus SEMUA pterodactyl otomatis |
| 10 | Cara Penggunaan | [v2.0] Tutorial dari nol + opsi |
| **11** | **Install Keamanan** | **[v2.1] Disk-limit + Suspicious + Admin-1 only** |
| **12** | **Uninstall Keamanan** | **[v2.1] Hapus paket keamanan** |
| x | Exit | Keluar |

**(Kode Token : `cloud`)**

## :books: File di Package

```
CloudServer-Autoinstall/
├── install.sh         # Main installer dengan 12 menu
├── security.sh        # Security autoinstaller (dipanggil dari menu 11)
├── repair.sh           # Repair tema (default pterodactyl)
├── createnode.sh       # Helper create node
├── bangkai.sh          # Backup installer (legacy)
├── stellar.zip         # Tema Stellar
├── billing.zip         # Tema Billing
├── enigma.zip          # Tema Enigma
└── README.md
```

## :computer: System Support

| Operating System | Version | Supported          |
| ---------------- | ------- | ------------------ |
| Ubuntu           | 20.04   | :white_check_mark: |
|                  | 22.04   | :white_check_mark: |
| Debian           | 10      | :white_check_mark: |
|                  | 11      | :white_check_mark: |
|                  | 12      | :white_check_mark: |

## :warning: Peringatan

- Opsi **9 (Uninstall Cloud)** hapus **SEMUA** data pterodactyl. Backup dulu!
- Opsi **11 (Install Keamanan)** butuh **Docker**, **Pterodactyl panel**, dan (opsional) **Application API Token** untuk suspend via API. Jika token tidak diisi, akan fallback ke `docker stop` manual.
- Pastikan server fresh install sebelum menggunakan script ini.
- Script ini recode by **Cloud Server**, original by FOXSTORE.
- Dilarang keras share bebas tanpa izin.

## :ledger: Log Monitoring

Cek activity monitor daemon kapan saja:

```bash
# Live tail log security
tail -f /var/log/cloud-server/security.log

# Test run monitor manual
sudo bash /opt/cloud-server/monitor.sh

# Edit batas disk / pattern suspicious
sudo nano /opt/cloud-server/monitor.sh
```

## Credits 
- Recode By [ Cloud Server ]
- Created by [ FOXSTORE ](https://github.com/Foxstoree)
