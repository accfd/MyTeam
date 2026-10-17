import '../../profile/models/keahlian_model.dart';
import '../../profile/models/media_sosial_model.dart';
import '../../profile/models/minat_model.dart';
import '../../profile/models/pengalaman_model.dart';

/// Ringkasan status lamaran pada tim (FR-17)
class TeamApplicationsSummary {
  final int total;
  final int menunggu;
  final int diterima;
  final int ditolak;

  const TeamApplicationsSummary({
    this.total = 0,
    this.menunggu = 0,
    this.diterima = 0,
    this.ditolak = 0,
  });

  factory TeamApplicationsSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const TeamApplicationsSummary();
    return TeamApplicationsSummary(
      total: _asInt(json['total']),
      menunggu: _asInt(json['menunggu']),
      diterima: _asInt(json['diterima']),
      ditolak: _asInt(json['ditolak']),
    );
  }

  static int _asInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'menunggu': menunggu,
        'diterima': diterima,
        'ditolak': ditolak,
      };
}

/// Model untuk Pengajuan Bergabung Tim Masuk (FR-17 & FR-18 - Rafa Gian Atthari)
class TeamApplicationModel {
  final String idPengajuanBergabungTim;
  final String idTim;
  final String idPengguna;
  final String posisi;
  final String pesanPengajuan;
  final String waktuPengajuan;
  final String statusPengajuan; // 'menunggu' | 'diterima' | 'ditolak'
  final String namaPengguna;
  final String nim;
  final String? fotoProfil;
  final String? programStudi;
  final String? fakultas;
  final String? ipk;
  final String? kontak;
  final String? namaTim;
  final String? namaKegiatan;
  final String? deskripsiSingkat;
  final String? kategoriKegiatan;
  final String? deskripsiTim;
  final String? statusTim;
  final String? idPemilikTim;
  final List<MediaSosialModel> mediaSosial;
  final List<KeahlianModel> keahlian;
  final List<MinatModel> minat;
  final List<PengalamanModel> pengalaman;

  const TeamApplicationModel({
    required this.idPengajuanBergabungTim,
    required this.idTim,
    required this.idPengguna,
    required this.posisi,
    required this.pesanPengajuan,
    required this.waktuPengajuan,
    required this.statusPengajuan,
    required this.namaPengguna,
    required this.nim,
    this.fotoProfil,
    this.programStudi,
    this.fakultas,
    this.ipk,
    this.kontak,
    this.namaTim,
    this.namaKegiatan,
    this.deskripsiSingkat,
    this.kategoriKegiatan,
    this.deskripsiTim,
    this.statusTim,
    this.idPemilikTim,
    this.mediaSosial = const [],
    this.keahlian = const [],
    this.minat = const [],
    this.pengalaman = const [],
  });

  bool get isMenunggu => statusPengajuan.toLowerCase() == 'menunggu';
  bool get isDiterima => statusPengajuan.toLowerCase() == 'diterima';
  bool get isDitolak => statusPengajuan.toLowerCase() == 'ditolak';

  /// Format tanggal & waktu pengajuan ramah pengguna
  String get formattedDate {
    if (waktuPengajuan.isEmpty) return '-';
    try {
      final dt = DateTime.parse(waktuPengajuan).toLocal();
      const monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      final month = monthNames[dt.month - 1];
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} $month ${dt.year}, $hour:$minute WIB';
    } catch (_) {
      return waktuPengajuan;
    }
  }

  /// Format relatif (e.g. "2 jam lalu", "Hari ini", "Kemarin")
  String get relativeTime {
    if (waktuPengajuan.isEmpty) return '';
    try {
      final dt = DateTime.parse(waktuPengajuan).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inSeconds < 60) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      if (diff.inDays == 1) return 'Kemarin';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      return formattedDate;
    } catch (_) {
      return waktuPengajuan;
    }
  }

  TeamApplicationModel copyWith({
    String? idPengajuanBergabungTim,
    String? idTim,
    String? idPengguna,
    String? posisi,
    String? pesanPengajuan,
    String? waktuPengajuan,
    String? statusPengajuan,
    String? namaPengguna,
    String? nim,
    String? fotoProfil,
    String? programStudi,
    String? fakultas,
    String? ipk,
    String? kontak,
    String? namaTim,
    String? namaKegiatan,
    String? deskripsiSingkat,
    String? kategoriKegiatan,
    String? deskripsiTim,
    String? statusTim,
    String? idPemilikTim,
    List<MediaSosialModel>? mediaSosial,
    List<KeahlianModel>? keahlian,
    List<MinatModel>? minat,
    List<PengalamanModel>? pengalaman,
  }) {
    return TeamApplicationModel(
      idPengajuanBergabungTim:
          idPengajuanBergabungTim ?? this.idPengajuanBergabungTim,
      idTim: idTim ?? this.idTim,
      idPengguna: idPengguna ?? this.idPengguna,
      posisi: posisi ?? this.posisi,
      pesanPengajuan: pesanPengajuan ?? this.pesanPengajuan,
      waktuPengajuan: waktuPengajuan ?? this.waktuPengajuan,
      statusPengajuan: statusPengajuan ?? this.statusPengajuan,
      namaPengguna: namaPengguna ?? this.namaPengguna,
      nim: nim ?? this.nim,
      fotoProfil: fotoProfil ?? this.fotoProfil,
      programStudi: programStudi ?? this.programStudi,
      fakultas: fakultas ?? this.fakultas,
      ipk: ipk ?? this.ipk,
      kontak: kontak ?? this.kontak,
      namaTim: namaTim ?? this.namaTim,
      namaKegiatan: namaKegiatan ?? this.namaKegiatan,
      deskripsiSingkat: deskripsiSingkat ?? this.deskripsiSingkat,
      kategoriKegiatan: kategoriKegiatan ?? this.kategoriKegiatan,
      deskripsiTim: deskripsiTim ?? this.deskripsiTim,
      statusTim: statusTim ?? this.statusTim,
      idPemilikTim: idPemilikTim ?? this.idPemilikTim,
      mediaSosial: mediaSosial ?? this.mediaSosial,
      keahlian: keahlian ?? this.keahlian,
      minat: minat ?? this.minat,
      pengalaman: pengalaman ?? this.pengalaman,
    );
  }

  factory TeamApplicationModel.fromJson(Map<String, dynamic> json) {
    final medsosRaw = (json['media_sosial'] as List<dynamic>?) ??
        (json['pelamar']?['media_sosial'] as List<dynamic>?) ??
        [];
    final keahlianRaw = (json['keahlian'] as List<dynamic>?) ??
        (json['pelamar']?['keahlian'] as List<dynamic>?) ??
        [];
    final minatRaw = (json['minat'] as List<dynamic>?) ??
        (json['pelamar']?['minat'] as List<dynamic>?) ??
        [];
    final pengalamanRaw = (json['pengalaman'] as List<dynamic>?) ??
        (json['pelamar']?['pengalaman'] as List<dynamic>?) ??
        [];

    final pelamarDataDiri =
        json['pelamar']?['data_diri'] as Map<String, dynamic>?;

    return TeamApplicationModel(
      idPengajuanBergabungTim:
          (json['id_pengajuan_bergabung_tim'] ?? '').toString(),
      idTim: (json['id_tim'] ?? '').toString(),
      idPengguna: (json['id_pengguna'] ?? '').toString(),
      posisi: (json['posisi'] ?? '').toString(),
      pesanPengajuan: (json['pesan_pengajuan'] ?? '').toString(),
      waktuPengajuan: (json['waktu_pengajuan'] ?? '').toString(),
      statusPengajuan: (json['status_pengajuan'] ?? 'menunggu').toString(),
      namaPengguna: (json['nama_pengguna'] ??
              json['pelamar']?['pengguna']?['nama_pengguna'] ??
              'Mahasiswa')
          .toString(),
      nim: (json['nim'] ?? json['pelamar']?['pengguna']?['nim'] ?? '-').toString(),
      fotoProfil: (json['foto_profil'] ??
              json['pelamar']?['pengguna']?['foto_profil'])
          ?.toString(),
      programStudi:
          (json['program_studi'] ?? pelamarDataDiri?['program_studi'])?.toString(),
      fakultas: (json['fakultas'] ?? pelamarDataDiri?['fakultas'])?.toString(),
      ipk: (json['ipk'] ?? pelamarDataDiri?['ipk'])?.toString(),
      kontak: (json['kontak'] ?? pelamarDataDiri?['kontak'])?.toString(),
      namaTim: json['nama_tim']?.toString(),
      namaKegiatan: json['nama_kegiatan']?.toString(),
      deskripsiSingkat: (json['deskripsi_singkat'] ??
              pelamarDataDiri?['deskripsi_singkat'])
          ?.toString(),
      kategoriKegiatan: json['kategori_kegiatan']?.toString(),
      deskripsiTim: json['deskripsi_tim']?.toString(),
      statusTim: json['status_tim']?.toString(),
      idPemilikTim: json['id_pemilik_tim']?.toString(),
      mediaSosial: medsosRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => MediaSosialModel.fromJson(e))
          .toList(),
      keahlian: keahlianRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => KeahlianModel.fromJson(e))
          .toList(),
      minat: minatRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => MinatModel.fromJson(e))
          .toList(),
      pengalaman: pengalamanRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => PengalamanModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_pengajuan_bergabung_tim': idPengajuanBergabungTim,
        'id_tim': idTim,
        'id_pengguna': idPengguna,
        'posisi': posisi,
        'pesan_pengajuan': pesanPengajuan,
        'waktu_pengajuan': waktuPengajuan,
        'status_pengajuan': statusPengajuan,
        'nama_pengguna': namaPengguna,
        'nim': nim,
        'foto_profil': fotoProfil,
        'program_studi': programStudi,
        'fakultas': fakultas,
        'ipk': ipk,
        'kontak': kontak,
        'nama_tim': namaTim,
        'nama_kegiatan': namaKegiatan,
        'deskripsi_singkat': deskripsiSingkat,
        'kategori_kegiatan': kategoriKegiatan,
        'deskripsi_tim': deskripsiTim,
        'status_tim': statusTim,
        'id_pemilik_tim': idPemilikTim,
        'media_sosial': mediaSosial.map((e) => e.toJson()).toList(),
        'keahlian': keahlian.map((e) => e.toJson()).toList(),
        'minat': minat.map((e) => e.toJson()).toList(),
        'pengalaman': pengalaman.map((e) => e.toJson()).toList(),
      };
}

/// Struktur kembalian lengkap dari endpoint GET /api/v1/teams/:id_tim/applications
class TeamApplicationsResult {
  final bool success;
  final String message;
  final String idTim;
  final String namaTim;
  final String namaKegiatan;
  final TeamApplicationsSummary summary;
  final List<TeamApplicationModel> applications;

  const TeamApplicationsResult({
    required this.success,
    required this.message,
    required this.idTim,
    required this.namaTim,
    required this.namaKegiatan,
    required this.summary,
    required this.applications,
  });

  factory TeamApplicationsResult.fromJson(Map<String, dynamic> json) {
    final team = json['team'] as Map<String, dynamic>? ?? {};
    final summaryJson = json['summary'] as Map<String, dynamic>?;
    final list = json['data'] as List<dynamic>? ?? [];

    return TeamApplicationsResult(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      idTim: (team['id_tim'] ?? '').toString(),
      namaTim: (team['nama_tim'] ?? '').toString(),
      namaKegiatan: (team['nama_kegiatan'] ?? '').toString(),
      summary: TeamApplicationsSummary.fromJson(summaryJson),
      applications: list
          .map((e) => TeamApplicationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  TeamApplicationsResult copyWith({
    bool? success,
    String? message,
    String? idTim,
    String? namaTim,
    String? namaKegiatan,
    TeamApplicationsSummary? summary,
    List<TeamApplicationModel>? applications,
  }) {
    return TeamApplicationsResult(
      success: success ?? this.success,
      message: message ?? this.message,
      idTim: idTim ?? this.idTim,
      namaTim: namaTim ?? this.namaTim,
      namaKegiatan: namaKegiatan ?? this.namaKegiatan,
      summary: summary ?? this.summary,
      applications: applications ?? this.applications,
    );
  }
}

