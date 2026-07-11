dasterm_t() {
  local key="$1"
  local lang="${DASTERM_LANG:-id}"
  case "$lang:$key" in
    id:footer_tip) echo "Tip: ketik /help untuk melihat semua menu Dasterm." ;;
    en:footer_tip) echo "Tip: type /help to view all Dasterm menus." ;;
    id:unknown_cmd) echo "Command tidak dikenal" ;;
    en:unknown_cmd) echo "Unknown command" ;;
    id:help_title) echo "Menu Dasterm" ;;
    en:help_title) echo "Dasterm Menu" ;;
    id:help_help) echo "Tampilkan semua command dan bantuan." ;;
    en:help_help) echo "Show all commands and help." ;;
    id:help_status) echo "Tampilkan dashboard sesuai mode aktif." ;;
    en:help_status) echo "Show dashboard using active mode." ;;
    id:help_lite) echo "Tampilkan dashboard ringan dan cepat." ;;
    en:help_lite) echo "Show lightweight fast dashboard." ;;
    id:help_full) echo "Tampilkan dashboard lengkap dengan data detail." ;;
    en:help_full) echo "Show complete dashboard with detailed data." ;;
    id:help_speedtest) echo "Lihat hasil speedtest yang tersimpan." ;;
    en:help_speedtest) echo "Show saved speedtest result." ;;
    id:help_respeedtest) echo "Jalankan ulang speedtest (pilihan: fast, ookla, python, atau --server ID)." ;;
    en:help_respeedtest) echo "Run speedtest again (options: fast, ookla, python, or --server ID)." ;;
    id:help_network) echo "Lihat detail jaringan, DNS, gateway, IP, dan speed cache." ;;
    en:help_network) echo "Show network, DNS, gateway, IP, and speed cache details." ;;
    id:help_storage) echo "Lihat root disk, /datas, mount, dan folder besar." ;;
    en:help_storage) echo "Show root disk, /datas, mounts, and largest folders." ;;
    id:help_services) echo "Lihat status service penting seperti Docker, Nginx, PM2, SSH." ;;
    en:help_services) echo "Show important services like Docker, Nginx, PM2, SSH." ;;
    id:help_security) echo "Cek firewall, SSH, login root, dan sinyal keamanan." ;;
    en:help_security) echo "Check firewall, SSH, root login, and security signals." ;;
    id:help_doctor) echo "Cek kesehatan instalasi Dasterm dan dependency." ;;
    en:help_doctor) echo "Check Dasterm installation health and dependencies." ;;

    id:help_config) echo "Buka konfigurasi interaktif." ;;
    en:help_config) echo "Open interactive configuration." ;;
    id:help_update) echo "Cek dan update Dasterm ke versi terbaru." ;;
    en:help_update) echo "Check and update Dasterm to latest version." ;;
    id:help_uninstall) echo "Hapus Dasterm dengan bersih." ;;
    en:help_uninstall) echo "Remove Dasterm cleanly." ;;
    id:help_version) echo "Lihat versi Dasterm." ;;
    en:help_version) echo "Show Dasterm version." ;;
    id:help_about) echo "Lihat informasi tentang Dasterm v2." ;;
    en:help_about) echo "Show about information for Dasterm v2." ;;
    id:help_watch) echo "Tampilkan dashboard interaktif secara real-time (Watch mode)." ;;
    en:help_watch) echo "Show interactive dashboard in real-time (Watch mode)." ;;
    id:config_title) echo "Konfigurasi Dasterm" ;;
    en:config_title) echo "Dasterm Configuration" ;;
    id:config_saved) echo "Konfigurasi berhasil disimpan. Buka terminal baru atau jalankan source ~/.bashrc." ;;
    en:config_saved) echo "Configuration saved. Open a new terminal or run source ~/.bashrc." ;;
    id:uninstall_hint) echo "Untuk uninstall bersih, installer utama akan dibuka." ;;
    en:uninstall_hint) echo "For clean uninstall, the main installer will be opened." ;;
    id:dashboard_title) echo "Dasterm Dashboard" ;;
    en:dashboard_title) echo "Dasterm Dashboard" ;;
    id:system) echo "Sistem" ;;
    en:system) echo "System" ;;
    id:network) echo "Jaringan" ;;
    en:network) echo "Network" ;;
    id:storage) echo "Penyimpanan" ;;
    en:storage) echo "Storage" ;;
    id:services) echo "Layanan" ;;
    en:services) echo "Services" ;;
    id:security) echo "Keamanan" ;;
    en:security) echo "Security" ;;
    id:speedtest) echo "Speedtest" ;;
    en:speedtest) echo "Speedtest" ;;

    id:speed_saved_empty) echo "Belum ada hasil speedtest tersimpan. Jalankan /respeedtest." ;;
    en:speed_saved_empty) echo "No saved speedtest result. Run /respeedtest." ;;
    id:speed_running) echo "Menjalankan speedtest. Hasil akan disimpan." ;;
    en:speed_running) echo "Running speedtest. Result will be saved." ;;
    id:speed_saved) echo "Hasil speedtest berhasil disimpan." ;;
    en:speed_saved) echo "Speedtest result saved." ;;
    id:update_title) echo "Update Dasterm" ;;
    en:update_title) echo "Dasterm Update" ;;
    id:update_current) echo "Versi saat ini" ;;
    en:update_current) echo "Current version" ;;
    id:update_latest) echo "Versi terbaru" ;;
    en:update_latest) echo "Latest version" ;;
    id:update_confirm) echo "Update sekarang?" ;;
    en:update_confirm) echo "Update now?" ;;
    id:update_done) echo "Update selesai." ;;
    en:update_done) echo "Update completed." ;;
    id:doctor_title) echo "Dasterm Doctor" ;;
    en:doctor_title) echo "Dasterm Doctor" ;;
    *) echo "$key" ;;
  esac
}