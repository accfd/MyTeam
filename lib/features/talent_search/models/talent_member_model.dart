/// Model anggota/talenta mahasiswa dari GET /api/v1/members/search (FR-21)
class TalentMemberModel {
  final String idPengguna;
  final String nim;
  final String namaPengguna;
  final String? fotoProfil;
  final String programStudi;
  final String fakultas;
  final double? ipk;
  final String deskripsiSingkat;
  final List<String> keahlian;
  final List<String> minat;

  const TalentMemberModel({
    required this.idPengguna,
    required this.nim,
    required this.namaPengguna,
    this.fotoProfil,
    required this.programStudi,
    required this.fakultas,
    this.ipk,
    required this.deskripsiSingkat,
    required this.keahlian,
    required this.minat,
  });

  factory TalentMemberModel.fromJson(Map<String, dynamic> j) {
    final keahlianRaw = j['keahlian'];
    final minatRaw = j['minat'];
    return TalentMemberModel(
      idPengguna: j['id_pengguna'] as String? ?? '',
      nim: j['nim'] as String? ?? '',
      namaPengguna: j['nama_pengguna'] as String? ?? '',
      fotoProfil: j['foto_profil'] as String?,
      programStudi: j['program_studi'] as String? ?? '',
      fakultas: j['fakultas'] as String? ?? '',
      ipk: (j['ipk'] as num?)?.toDouble(),
      deskripsiSingkat: j['deskripsi_singkat'] as String? ?? '',
      keahlian: keahlianRaw is List
          ? keahlianRaw.map((e) => e.toString()).toList()
          : [],
      minat: minatRaw is List
          ? minatRaw.map((e) => e.toString()).toList()
          : [],
    );
  }

  String get inisial {
    final parts = namaPengguna.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return 'M';
  }

  String get angkatan {
    if (nim.length >= 4) return "'${nim.substring(2, 4)}";
    return '';
  }
}

// Alias untuk kompatibilitas
typedef MemberModel = TalentMemberModel;
