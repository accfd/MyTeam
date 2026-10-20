import 'dart:convert';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';
import '../models/auth_user_model.dart';
import 'google_auth_service.dart';

/// Service untuk menangani proses login dan registrasi akun mahasiswa
class AuthService {
  /// POST /api/v1/auth/login
  static Future<AuthUserModel> login({
    required String nim,
    required String kataSandi,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.login,
      body: {
        'nim': nim.trim(),
        'kata_sandi': kataSandi,
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final user = AuthUserModel.fromJson(data);
      await StorageService.saveUserSession(
        idPengguna: user.idPengguna,
        nim: user.nim,
        namaPengguna: user.namaPengguna,
        token: user.token,
        fotoProfil: user.fotoProfil,
      );
      return user;
    } else {
      throw Exception(data['message'] ?? 'Login gagal. Periksa NIM/Email dan kata sandi.');
    }
  }

  /// POST /api/v1/auth/register
  static Future<AuthUserModel> register({
    required String nim,
    required String namaPengguna,
    required String email,
    required String kataSandi,
    required String kataSandiKonfirmasi,
  }) async {
    final response = await ApiClient.post(
      ApiEndpoints.register,
      body: {
        'nim': nim.trim(),
        'nama_pengguna': namaPengguna.trim(),
        'email': email.trim().toLowerCase(),
        'kata_sandi': kataSandi,
        'kata_sandi_konfirmasi': kataSandiKonfirmasi,
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      final user = AuthUserModel.fromJson(data);
      await StorageService.saveUserSession(
        idPengguna: user.idPengguna,
        nim: user.nim,
        namaPengguna: user.namaPengguna,
        token: user.token,
        fotoProfil: user.fotoProfil,
      );
      return user;
    } else {
      throw Exception(data['message'] ?? 'Registrasi gagal.');
    }
  }

  /// POST /api/v1/auth/google
  static Future<AuthUserModel> loginWithGoogle(String idToken) async {
    final response = await ApiClient.post(
      ApiEndpoints.googleAuth,
      body: {
        'id_token': idToken,
      },
    );

    final data = jsonDecode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) && data['success'] == true) {
      final user = AuthUserModel.fromJson(data);
      await StorageService.saveUserSession(
        idPengguna: user.idPengguna,
        nim: user.nim,
        namaPengguna: user.namaPengguna,
        token: user.token,
        fotoProfil: user.fotoProfil,
      );
      return user;
    } else {
      throw Exception(data['message'] ?? 'Autentikasi Google gagal.');
    }
  }

  /// Logout
  static Future<void> logout() async {
    await GoogleAuthService.signOut();
    await StorageService.clearSession();
  }
}
