import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../models/invitation_model.dart';

/// Service untuk undangan masuk, undangan terkirim, dan lamaran tim.
class StatusService {
  // FR-24: Undangan masuk untuk pengguna saat ini (Alur D — Fuadi)
  static Future<List<InvitationModel>> getReceivedInvitations() async {
    final resp = await ApiClient.get('/applications/received-invitations');
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

  // FR-25: Undangan yang dikirim oleh pemilik tim saat ini.
  static Future<List<Map<String, dynamic>>> getSentInvitations() async {
    final resp = await ApiClient.get('/applications/sent-invitations');
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode == 200 && json['success'] == true) {
      return (json['data'] as List<dynamic>? ?? [])
          .map((item) => item as Map<String, dynamic>)
          .toList();
    }
    throw Exception(json['message'] ?? 'Gagal memuat undangan terkirim.');
  }
}
