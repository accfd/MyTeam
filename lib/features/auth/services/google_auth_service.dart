import 'package:google_sign_in/google_sign_in.dart';

/// Service untuk menangani interaksi native Google Sign-In SDK
class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'profile',
    ],
    hostedDomain: 'student.unand.ac.id',
  );

  /// Melakukan login Google dan mengembalikan Google ID Token
  static Future<String?> signIn() async {
    try {
      // Sign out sesi sebelumnya agar pengguna selalu dapat memilih akun Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        // Pengguna membatalkan proses sign-in
        return null;
      }

      // Validasi awal di sisi client untuk domain kampus UNAND
      final email = account.email.toLowerCase().trim();
      if (!email.endsWith('@student.unand.ac.id')) {
        await _googleSignIn.signOut();
        throw Exception(
          'Akun tidak valid! Anda harus memilih akun email resmi mahasiswa UNAND (@student.unand.ac.id).',
        );
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Gagal mendapatkan ID Token dari Google.');
      }

      return idToken;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out dari Google SDK
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
