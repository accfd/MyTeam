/// Model data pengguna MyTeam
/// Sinkron dengan response backend POST /auth/login & /auth/register
class UserModel {
  final String idPengguna;
  final String nim;
  final String namaPengguna;
  final String? fotoProfil;
  final String token;

  const UserModel({
    required this.idPengguna,
    required this.nim,
    required this.namaPengguna,
    this.fotoProfil,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Login response: data.token + data.pengguna (nested) or flat
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return UserModel(
      idPengguna: data['id_pengguna'] as String,
      nim: data['nim'] as String,
      namaPengguna: data['nama_pengguna'] as String,
      fotoProfil: data['foto_profil'] as String?,
      token: data['token'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_pengguna': idPengguna,
        'nim': nim,
        'nama_pengguna': namaPengguna,
        'foto_profil': fotoProfil,
        'token': token,
      };

  @override
  String toString() =>
      'UserModel(nim: $nim, nama: $namaPengguna, id: $idPengguna)';
}
