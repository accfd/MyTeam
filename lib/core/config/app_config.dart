import 'package:flutter/foundation.dart' show kIsWeb;

/// ============================================================
/// KONFIGURASI ENVIRONMENT — MyTeam Backend API
/// ============================================================
class AppConfig {
  /// URL Cloud Backend Vercel Resmi
  static const String _cloudUrl = 'https://my-team-chi-jade.vercel.app/api/v1';

  /// True: Menggunakan server Vercel Cloud (tanpa perlu laptop/npm run dev/XAMPP)
  /// False: Menggunakan server lokal laptop
  static const bool _useCloud = true;

  /// Port backend MyTeam (lokal)
  static const int _port = 8000;

  /// IP LAN laptop (opsional jika HP tanpa kabel USB & dalam satu jaringan Wi-Fi)
  static const String _lanIp = '192.168.100.11';

  /// Mode USB ADB Reverse (saat HP dicolok kabel USB ke laptop untuk server lokal)
  static const bool _useAdbReverse = true;

  /// Base URL API otomatis sesuai platform & konfigurasi cloud
  static String get baseUrl {
    if (_useCloud) {
      return _cloudUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:$_port/api/v1';
    }
    if (_useAdbReverse) {
      return 'http://127.0.0.1:$_port/api/v1';
    }
    return 'http://$_lanIp:$_port/api/v1';
  }
}
