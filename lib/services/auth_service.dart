import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/user_model.dart';

/// Service untuk komunikasi dengan Backend API MyTeam — Modul Auth
/// Base URL: http://10.0.2.2:8000/api/v1 (Android Emulator)
class AuthService {
  // URL diambil dari AppConfig — ubah di lib/config/app_config.dart
  static String get _baseUrl => AppConfig.baseUrl;

  // Helper: HTTP headers standar JSON
  static Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// POST /auth/login
  /// Login menggunakan NIM dan kata sandi
  /// Returns [UserModel] jika berhasil, throws [Exception] jika gagal
  static Future<UserModel> login({
    required String nim,
    required String kataSandi,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/login');
    final body = jsonEncode({'nim': nim, 'kata_sandi': kataSandi});

    late final http.Response response;
    try {
      response = await http
          .post(uri, headers: _jsonHeaders, body: body)
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw Exception(
          'Tidak dapat terhubung ke server. Pastikan backend sudah berjalan.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && json['success'] == true) {
      // Flatten nested: data.token ada di level data langsung (backend MyTeam)
      final data = json['data'] as Map<String, dynamic>;
      return UserModel(
        idPengguna: data['id_pengguna'] as String,
        nim: data['nim'] as String,
        namaPengguna: data['nama_pengguna'] as String,
        fotoProfil: data['foto_profil'] as String?,
        token: data['token'] as String,
      );
    }

    // Error dari server
    final message = json['message'] as String? ?? 'Login gagal.';
    throw Exception(message);
  }

  /// POST /auth/register
  /// Daftar akun baru menggunakan NIM, nama pengguna, dan kata sandi
  /// Returns [UserModel] jika berhasil, throws [Exception] jika gagal
  static Future<UserModel> register({
    required String nim,
    required String namaPengguna,
    required String kataSandi,
    required String kataSandiKonfirmasi,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/register');
    final body = jsonEncode({
      'nim': nim,
      'nama_pengguna': namaPengguna,
      'kata_sandi': kataSandi,
      'kata_sandi_konfirmasi': kataSandiKonfirmasi,
    });

    late final http.Response response;
    try {
      response = await http
          .post(uri, headers: _jsonHeaders, body: body)
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw Exception(
          'Tidak dapat terhubung ke server. Pastikan backend sudah berjalan.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201 && json['success'] == true) {
      final data = json['data'] as Map<String, dynamic>;
      return UserModel(
        idPengguna: data['id_pengguna'] as String,
        nim: data['nim'] as String,
        namaPengguna: data['nama_pengguna'] as String,
        fotoProfil: data['foto_profil'] as String?,
        token: data['token'] as String,
      );
    }

    final message = json['message'] as String? ?? 'Registrasi gagal.';
    throw Exception(message);
  }
}
