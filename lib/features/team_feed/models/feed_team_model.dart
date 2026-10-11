/// Model kebutuhan posisi dalam satu tim
class KebutuhanModel {
  final String idKebutuhan;
  final String idTim;
  final String posisi;
  final String keahlian;
  final int jumlah;

  const KebutuhanModel({
    required this.idKebutuhan,
    required this.idTim,
    required this.posisi,
    required this.keahlian,
    required this.jumlah,
  });

  factory KebutuhanModel.fromJson(Map<String, dynamic> j) => KebutuhanModel(
        idKebutuhan: j['id_kebutuhan'] as String? ?? '',
        idTim: j['id_tim'] as String? ?? '',
        posisi: j['posisi_dibutuhkan'] as String? ?? '',
        keahlian: j['keahlian_dibutuhkan'] as String? ?? '',
        jumlah: (j['jumlah_anggota_dibutuhkan'] as num?)?.toInt() ?? 1,
      );

  /// Keahlian dipecah menjadi list chip (dipisah koma)
  List<String> get keahlianList =>
      keahlian.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
}

/// Model tim dari endpoint GET /api/v1/teams/feed (FR-13 & FR-14)
class FeedTeamModel {
  final String idTim;
  final String idPengguna;
  final String namaTim;
  final String namaKegiatan;
  final String kategori; // Lomba | Penelitian | Proyek | Lainnya
  final String deskripsi;
  final String statusTim;
  final String namaPengguna; // nama ketua
  final String? fotoProfil;
  final List<KebutuhanModel> kebutuhanTim;
  final String createdAt;

  const FeedTeamModel({
    required this.idTim,
    required this.idPengguna,
    required this.namaTim,
    required this.namaKegiatan,
    required this.kategori,
    required this.deskripsi,
    required this.statusTim,
    required this.namaPengguna,
    this.fotoProfil,
    required this.kebutuhanTim,
    required this.createdAt,
  });

  factory FeedTeamModel.fromJson(Map<String, dynamic> j) {
    final kebutuhanRaw = j['kebutuhan_tim'] as List<dynamic>? ?? [];
    return FeedTeamModel(
      idTim: j['id_tim'] as String? ?? '',
      idPengguna: j['id_pengguna'] as String? ?? '',
      namaTim: j['nama_tim'] as String? ?? '',
      namaKegiatan: j['nama_kegiatan'] as String? ?? '',
      kategori: j['kategori_kegiatan'] as String? ?? 'Lainnya',
      deskripsi: j['deskripsi'] as String? ?? '',
      statusTim: j['status_tim'] as String? ?? 'terbuka',
      namaPengguna: j['nama_pengguna'] as String? ?? '',
      fotoProfil: j['foto_profil'] as String?,
      kebutuhanTim: kebutuhanRaw
          .map((e) => KebutuhanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: j['created_at']?.toString() ?? '',
    );
  }

  int get totalPosisiTerbuka =>
      kebutuhanTim.fold(0, (sum, k) => sum + k.jumlah);
}

// Alias untuk kompatibilitas
typedef TeamModel = FeedTeamModel;
