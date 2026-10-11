import 'package:flutter/foundation.dart' show kIsWeb;

/// ============================================================
/// KONFIGURASI ENVIRONMENT — MyTeam Backend API
/// ============================================================
/// Cukup ubah file ini saja untuk menyesuaikan device masing-masing.
/// File lain (auth_service, dll) TIDAK perlu disentuh.
/// ============================================================
class AppConfig {
  // ─── ⚙️ UBAH DI SINI JIKA PERLU ──────────────────────────────────────────

  /// IP laptop yang menjalankan backend.
  /// Cara cari IP: buka CMD → ketik `ipconfig` → lihat "IPv4 Address"
  /// Contoh: '192.168.1.5' atau '192.168.43.100'
  static const String _lanIp = '192.168.1.100'; // ← GANTI dengan IP laptopmu

  /// Set true jika menjalankan Flutter di HP fisik (bukan emulator / bukan browser)
  static const bool _usePhysicalDevice = false; // ← GANTI ke true jika pakai HP

  // ─────────────────────────────────────────────────────────────────────────

  static const int _port = 8000;

  /// Base URL API otomatis sesuai platform:
  ///
  /// | Platform          | URL yang digunakan            | Cara aktifkan         |
  /// |-------------------|-------------------------------|-----------------------|
  /// | 🌐 Web browser    | http://localhost:8000/api/v1  | Otomatis              |
  /// | 📱 Android emulator| http://10.0.2.2:8000/api/v1  | Otomatis (default)    |
  /// | 📱 HP fisik       | http://<IP_laptop>:8000/api/v1| _usePhysicalDevice=true|
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$_port/api/v1';
    }
    if (_usePhysicalDevice) {
      return 'http://$_lanIp:$_port/api/v1';
    }
    // Default: Android Emulator
    return 'http://10.0.2.2:$_port/api/v1';
  }
}
