import 'package:flutter/material.dart';

/// Ringkasan kuantitatif status pengajuan bergabung milik pengguna (FR-20)
class MyApplicationsSummary {
  final int total;
  final int menunggu;
  final int diterima;
  final int ditolak;

  const MyApplicationsSummary({
    this.total = 0,
    this.menunggu = 0,
    this.diterima = 0,
    this.ditolak = 0,
  });

  factory MyApplicationsSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MyApplicationsSummary();
    return MyApplicationsSummary(
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

/// Model untuk Status Pengajuan Bergabung Saya (FR-20 — Rafa Gian Atthari)
class MyApplicationModel {
  final String idPengajuanBergabungTim;
  final String idTim;
  final String idPengguna;
  final String posisi;
  final String pesanPengajuan;
  final String waktuPengajuan;
  final String statusPengajuan; // 'menunggu' | 'diterima' | 'ditolak'
  final String namaTim;
  final String namaKegiatan;
  final String kategoriKegiatan;
  final String? deskripsiTim;
  final String? statusTim;
  final String? idPemilikTim;
  final String? namaPemilikTim;
  final String? fotoPemilikTim;
  final String? posterTim;

  const MyApplicationModel({
    required this.idPengajuanBergabungTim,
    required this.idTim,
    required this.idPengguna,
    required this.posisi,
    required this.pesanPengajuan,
    required this.waktuPengajuan,
    required this.statusPengajuan,
    required this.namaTim,
    required this.namaKegiatan,
    required this.kategoriKegiatan,
    this.deskripsiTim,
    this.statusTim,
    this.idPemilikTim,
    this.namaPemilikTim,
    this.fotoPemilikTim,
    this.posterTim,
  });

  bool get isMenunggu => statusPengajuan.toLowerCase() == 'menunggu';
  bool get isDiterima => statusPengajuan.toLowerCase() == 'diterima';
  bool get isDitolak => statusPengajuan.toLowerCase() == 'ditolak';

  /// Format tanggal & jam rapi berbahasa Indonesia
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

  /// Waktu relatif ramah pengguna (DESIGN.md)
  String get relativeTime {
    if (waktuPengajuan.isEmpty) return '';
    try {
      final dt = DateTime.parse(waktuPengajuan).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inSeconds < 60) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      if (diff.inDays == 1) return 'Kemarin';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      return formattedDate;
    } catch (_) {
      return waktuPengajuan;
    }
  }

  /// Teks label status
  String get statusLabel {
    if (isMenunggu) return 'Menunggu Keputusan';
    if (isDiterima) return 'Diterima Bergabung';
    if (isDitolak) return 'Pengajuan Ditolak';
    return statusPengajuan;
  }

  /// Warna latar belakang badge semantik status (DESIGN.md Subbab 2.1 C)
  Color get statusBgColor {
    if (isMenunggu) return const Color(0xFFFEF9C3); // Kuning muda lembut
    if (isDiterima) return const Color(0xFFDCFCE7); // Hijau muda cerah
    if (isDitolak) return const Color(0xFFFEE2E2);  // Merah muda cerah
    return const Color(0xFFF3F4F6);
  }

  /// Warna teks badge semantik status (DESIGN.md Subbab 2.1 C)
  Color get statusTextColor {
    if (isMenunggu) return const Color(0xFFA16207); // Amber gelap
    if (isDiterima) return const Color(0xFF15803D); // Emerald tegas
    if (isDitolak) return const Color(0xFFDC2626);  // Merah tegas
    return const Color(0xFF4B5563);
  }

  /// Aksen garis samping / border kartu semantik
  Color get statusBorderColor {
    if (isMenunggu) return const Color(0xFFEAB308);
    if (isDiterima) return const Color(0xFF16A34A);
    if (isDitolak) return const Color(0xFFEF4444);
    return const Color(0xFFE5E7EB);
  }

  /// Ikon representatif status
  IconData get statusIcon {
    if (isMenunggu) return Icons.hourglass_top_rounded;
    if (isDiterima) return Icons.check_circle_rounded;
    if (isDitolak) return Icons.cancel_rounded;
    return Icons.help_outline_rounded;
  }

  factory MyApplicationModel.fromJson(Map<String, dynamic> json) {
    return MyApplicationModel(
      idPengajuanBergabungTim: (json['id_pengajuan_bergabung_tim'] ?? '').toString(),
      idTim: (json['id_tim'] ?? '').toString(),
      idPengguna: (json['id_pengguna'] ?? '').toString(),
      posisi: (json['posisi'] ?? '').toString(),
      pesanPengajuan: (json['pesan_pengajuan'] ?? '').toString(),
      waktuPengajuan: (json['waktu_pengajuan'] ?? '').toString(),
      statusPengajuan: (json['status_pengajuan'] ?? 'menunggu').toString(),
      namaTim: (json['nama_tim'] ?? '').toString(),
      namaKegiatan: (json['nama_kegiatan'] ?? '').toString(),
      kategoriKegiatan: (json['kategori_kegiatan'] ?? 'Lomba').toString(),
      deskripsiTim: json['deskripsi_tim']?.toString(),
      statusTim: json['status_tim']?.toString(),
      idPemilikTim: json['id_pemilik_tim']?.toString(),
      namaPemilikTim: json['nama_pemilik_tim']?.toString(),
      fotoPemilikTim: json['foto_pemilik_tim']?.toString(),
      posterTim: json['poster_tim']?.toString(),
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
        'nama_tim': namaTim,
        'nama_kegiatan': namaKegiatan,
        'kategori_kegiatan': kategoriKegiatan,
        'deskripsi_tim': deskripsiTim,
        'status_tim': statusTim,
        'id_pemilik_tim': idPemilikTim,
        'nama_pemilik_tim': namaPemilikTim,
        'foto_pemilik_tim': fotoPemilikTim,
        'poster_tim': posterTim,
      };

  MyApplicationModel copyWith({
    String? idPengajuanBergabungTim,
    String? idTim,
    String? idPengguna,
    String? posisi,
    String? pesanPengajuan,
    String? waktuPengajuan,
    String? statusPengajuan,
    String? namaTim,
    String? namaKegiatan,
    String? kategoriKegiatan,
    String? deskripsiTim,
    String? statusTim,
    String? idPemilikTim,
    String? namaPemilikTim,
    String? fotoPemilikTim,
    String? posterTim,
  }) {
    return MyApplicationModel(
      idPengajuanBergabungTim: idPengajuanBergabungTim ?? this.idPengajuanBergabungTim,
      idTim: idTim ?? this.idTim,
      idPengguna: idPengguna ?? this.idPengguna,
      posisi: posisi ?? this.posisi,
      pesanPengajuan: pesanPengajuan ?? this.pesanPengajuan,
      waktuPengajuan: waktuPengajuan ?? this.waktuPengajuan,
      statusPengajuan: statusPengajuan ?? this.statusPengajuan,
      namaTim: namaTim ?? this.namaTim,
      namaKegiatan: namaKegiatan ?? this.namaKegiatan,
      kategoriKegiatan: kategoriKegiatan ?? this.kategoriKegiatan,
      deskripsiTim: deskripsiTim ?? this.deskripsiTim,
      statusTim: statusTim ?? this.statusTim,
      idPemilikTim: idPemilikTim ?? this.idPemilikTim,
      namaPemilikTim: namaPemilikTim ?? this.namaPemilikTim,
      fotoPemilikTim: fotoPemilikTim ?? this.fotoPemilikTim,
      posterTim: posterTim ?? this.posterTim,
    );
  }
}

/// Struktur kembalian lengkap dari endpoint GET /api/v1/applications/my-applications
class MyApplicationsResult {
  final bool success;
  final String message;
  final MyApplicationsSummary summary;
  final List<MyApplicationModel> applications;

  const MyApplicationsResult({
    required this.success,
    required this.message,
    required this.summary,
    required this.applications,
  });

  factory MyApplicationsResult.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? [];
    return MyApplicationsResult(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      summary: MyApplicationsSummary.fromJson(json['summary'] as Map<String, dynamic>?),
      applications: list
          .map((e) => MyApplicationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
