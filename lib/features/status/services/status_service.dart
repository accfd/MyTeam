import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../team_feed/models/my_application_model.dart';
import '../../team_feed/services/team_feed_service.dart';
import '../models/invitation_model.dart';

/// Service untuk Modul Status (Alur D: Undangan Masuk & Alur A: Lamaran Saya)
class StatusService {
  // FR-24: Undangan masuk untuk pengguna saat ini (Alur D — Fuadi)
  static Future<List<InvitationModel>> getReceivedInvitations(
    String idPengguna,
  ) async {
    final resp = await ApiClient.get(
      '/applications/received-invitations',
      queryParams: {'id_pengguna': idPengguna},
    );
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode == 200 && json['success'] == true) {
      final list = json['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => InvitationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(json['message'] ?? 'Gagal memuat daftar undangan.');
  }

  // FR-24 & FR-25: Aksi Terima / Tolak Undangan (Alur D — Fuadi)
  static Future<Map<String, dynamic>> respondInvitation({
    required String idPengajuanAnggota,
    required String status,
  }) async {
    final resp = await ApiClient.patch(
      '/applications/received-invitations/$idPengajuanAnggota/status',
      body: {'status_pengajuan': status},
    );
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode != 200 || json['success'] != true) {
      throw Exception(json['message'] ?? 'Gagal memperbarui status undangan.');
    }
    return {
      'status_pengajuan': json['data']?['status_pengajuan'],
      'message': json['message'] ?? 'Berhasil menanggapi undangan.',
    };
  }

  // FR-19 & FR-20: Status Lamaran Saya (Alur A — Rafa)
  static Future<MyApplicationsResult> getMyApplications() async {
    return await TeamFeedService.getMyApplications();
  }
}
