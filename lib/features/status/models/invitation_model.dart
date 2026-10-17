/// Model Undangan Masuk ke Tim (Modul 4 & 5 — Alur D: Fuadi, FR-24 & FR-25)
class InvitationModel {
  final String idUndangan;
  final String idTim;
  final String namaTim;
  final String namaKegiatan;
  final String kategoriKegiatan;
  final String namaPembuat;
  final String? fotoPembuat;
  final String posisiTawaran;
  final String pesanAjakan;
  final String status; // 'menunggu' | 'diterima' | 'ditolak'
  final String createdAt;

  const InvitationModel({
    required this.idUndangan,
    required this.idTim,
    required this.namaTim,
    required this.namaKegiatan,
    required this.kategoriKegiatan,
    required this.namaPembuat,
    this.fotoPembuat,
    required this.posisiTawaran,
    required this.pesanAjakan,
    required this.status,
    required this.createdAt,
  });

  bool get isMenunggu => status.toLowerCase() == 'menunggu';
  bool get isDiterima => status.toLowerCase() == 'diterima';
  bool get isDitolak => status.toLowerCase() == 'ditolak';

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      idUndangan: json['id_undangan']?.toString() ??
          json['id_pengajuan_anggota']?.toString() ??
          '',
      idTim: json['id_tim']?.toString() ?? '',
      namaTim: json['nama_tim']?.toString() ?? 'Tim',
      namaKegiatan: json['nama_kegiatan']?.toString() ??
          json['judul_kegiatan']?.toString() ??
          '-',
      kategoriKegiatan: json['kategori_kegiatan']?.toString() ?? 'Kompetisi',
      namaPembuat: json['nama_pembuat']?.toString() ??
          json['nama_pemilik']?.toString() ??
          'Ketua Tim',
      fotoPembuat: json['foto_profil_pembuat']?.toString() ??
          json['foto_pemilik']?.toString(),
      posisiTawaran: json['posisi_tawaran']?.toString() ??
          json['posisi']?.toString() ??
          'Anggota',
      pesanAjakan: json['pesan_ajakan']?.toString() ??
          json['pesan']?.toString() ??
          '',
      status: (json['status']?.toString() ??
              json['status_pengajuan']?.toString() ??
              'menunggu')
          .toLowerCase(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id_undangan': idUndangan,
        'id_tim': idTim,
        'nama_tim': namaTim,
        'nama_kegiatan': namaKegiatan,
        'kategori_kegiatan': kategoriKegiatan,
        'nama_pembuat': namaPembuat,
        'foto_pembuat': fotoPembuat,
        'posisi_tawaran': posisiTawaran,
        'pesan_ajakan': pesanAjakan,
        'status': status,
        'created_at': createdAt,
      };
}
