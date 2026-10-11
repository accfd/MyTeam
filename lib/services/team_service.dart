import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/team_model.dart';
import '../models/member_model.dart';

/// Service untuk endpoint Tim dan Anggota MyTeam
class TeamService {
  static Map<String, String> _authHeader(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ─── Teams ────────────────────────────────────────────────────────────────

  /// GET /api/v1/teams/feed
  /// Feed semua tim terbuka, bisa difilter kategori & keyword
  static Future<List<TeamModel>> fetchFeed({
    String token = '',
    String? search,
    String? kategori,
  }) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (kategori != null && kategori != 'Semua') params['kategori'] = kategori;

    final uri = Uri.parse('${AppConfig.baseUrl}/teams/feed')
        .replace(queryParameters: params.isEmpty ? null : params);

    late final http.Response resp;
    try {
      resp = await http
          .get(uri, headers: _authHeader(token))
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw Exception('Tidak dapat terhubung ke server.');
    }

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode == 200 && json['success'] == true) {
      final data = json['data'] as List<dynamic>;
      return data
          .map((e) => TeamModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(json['message'] ?? 'Gagal memuat data tim.');
  }

  // ─── Members ─────────────────────────────────────────────────────────────

  /// GET /api/v1/members/search
  /// Talenta mahasiswa yang bisa dicari berdasarkan nama/keahlian/minat
  static Future<List<MemberModel>> searchMembers({
    String token = '',
    String? q,
    String? keahlian,
  }) async {
    final params = <String, String>{};
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (keahlian != null && keahlian.isNotEmpty) params['keahlian'] = keahlian;

    final uri = Uri.parse('${AppConfig.baseUrl}/members/search')
        .replace(queryParameters: params.isEmpty ? null : params);

    late final http.Response resp;
    try {
      resp = await http
          .get(uri, headers: _authHeader(token))
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw Exception('Tidak dapat terhubung ke server.');
    }

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode == 200 && json['success'] == true) {
      final data = json['data'] as List<dynamic>;
      return data
          .map((e) => MemberModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(json['message'] ?? 'Gagal memuat data anggota.');
  }
}
