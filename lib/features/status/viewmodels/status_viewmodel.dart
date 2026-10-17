import 'package:flutter/material.dart';
import '../models/invitation_model.dart';
import '../services/status_service.dart';

/// ViewModel untuk Modul Status (MVVM)
/// Mengelola state undangan masuk dan undangan terkirim.
class StatusViewModel extends ChangeNotifier {
  // ── Alur D: Undangan Masuk State ──────────────────────────────────────────
  List<InvitationModel> _invitations = [];
  bool _isLoadingInvitations = true;
  String? _errorInvitations;
  final Set<String> _processingIds = {};

  List<InvitationModel> get invitations => _invitations;
  bool get isLoadingInvitations => _isLoadingInvitations;
  String? get errorInvitations => _errorInvitations;
  bool isProcessing(String id) => _processingIds.contains(id);

  int get pendingInvitationsCount =>
      _invitations.where((i) => i.isMenunggu).length;

  // ── Undangan terkirim oleh pemilik tim ───────────────────────────────────
  List<Map<String, dynamic>> _sentInvitations = [];
  bool _isLoadingSentInvitations = true;
  String? _errorSentInvitations;
  String _activeSentInvitationFilter = 'semua';

  List<Map<String, dynamic>> get sentInvitations => _sentInvitations;
  bool get isLoadingSentInvitations => _isLoadingSentInvitations;
  String? get errorSentInvitations => _errorSentInvitations;
  String get activeSentInvitationFilter => _activeSentInvitationFilter;
  List<Map<String, dynamic>> get filteredSentInvitations {
    if (_activeSentInvitationFilter == 'semua') return _sentInvitations;
    return _sentInvitations
        .where(
          (invitation) =>
              invitation['status_pengajuan']?.toString().toLowerCase() ==
              _activeSentInvitationFilter,
        )
        .toList();
  }

  int get pendingSentInvitationsCount => _countSentInvitations('menunggu');
  int get acceptedSentInvitationsCount => _countSentInvitations('diterima');
  int get rejectedSentInvitationsCount => _countSentInvitations('ditolak');

  int _countSentInvitations(String status) => _sentInvitations
      .where(
        (invitation) =>
            invitation['status_pengajuan']?.toString().toLowerCase() == status,
      )
      .length;

  // ── Inisialisasi & Muat Data ──────────────────────────────────────────────
  Future<void> loadAll() async {
    await Future.wait([loadInvitations(), loadSentInvitations()]);
  }

  // ── 1. Load Undangan Masuk (Alur D — Fuadi) ───────────────────────────────
  Future<void> loadInvitations() async {
    _isLoadingInvitations = true;
    _errorInvitations = null;
    notifyListeners();

    try {
      _invitations = await StatusService.getReceivedInvitations();
      _isLoadingInvitations = false;
      notifyListeners();
    } catch (e) {
      _errorInvitations = e.toString().replaceFirst('Exception: ', '');
      _isLoadingInvitations = false;
      notifyListeners();
    }
  }

  // ── 2. Respon Undangan (Alur D — Fuadi) ───────────────────────────────────
  Future<String> respondInvitation({
    required String idUndangan,
    required String status,
  }) async {
    if (_processingIds.contains(idUndangan)) return '';
    _processingIds.add(idUndangan);
    notifyListeners();

    try {
      final res = await StatusService.respondInvitation(
        idPengajuanAnggota: idUndangan,
        status: status,
      );
      _processingIds.remove(idUndangan);
      await loadInvitations();
      return res['message']?.toString() ?? 'Berhasil merespons undangan.';
    } catch (e) {
      _processingIds.remove(idUndangan);
      notifyListeners();
      rethrow;
    }
  }

  // ── 3. Load undangan yang dikirim pemilik tim ─────────────────────────────
  Future<void> loadSentInvitations() async {
    _isLoadingSentInvitations = true;
    _errorSentInvitations = null;
    notifyListeners();

    try {
      _sentInvitations = await StatusService.getSentInvitations();
      _isLoadingSentInvitations = false;
      notifyListeners();
    } catch (e) {
      _errorSentInvitations = e.toString().replaceFirst('Exception: ', '');
      _isLoadingSentInvitations = false;
      notifyListeners();
    }
  }

  // ── 4. Set filter undangan terkirim ──────────────────────────────────────
  void setSentInvitationFilter(String filterKey) {
    if (_activeSentInvitationFilter == filterKey) return;
    _activeSentInvitationFilter = filterKey;
    notifyListeners();
  }
}
