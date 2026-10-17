import 'package:flutter/material.dart';
import '../../../core/storage/storage_service.dart';
import '../../team_feed/models/my_application_model.dart';
import '../models/invitation_model.dart';
import '../services/status_service.dart';

/// ViewModel untuk Modul Status (MVVM)
/// Mengelola state Alur D (Undangan Masuk - Fuadi) & Alur A (Lamaran Saya - Rafa)
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

  // ── Alur A: Lamaran Saya State ────────────────────────────────────────────
  List<MyApplicationModel> _applications = [];
  MyApplicationsSummary _applicationsSummary = const MyApplicationsSummary();
  bool _isLoadingApplications = true;
  String? _errorApplications;
  String _activeAppFilter = 'semua'; // 'semua', 'menunggu', 'diterima', 'ditolak'

  List<MyApplicationModel> get applications => _applications;
  MyApplicationsSummary get applicationsSummary => _applicationsSummary;
  bool get isLoadingApplications => _isLoadingApplications;
  String? get errorApplications => _errorApplications;
  String get activeAppFilter => _activeAppFilter;

  List<MyApplicationModel> get filteredApplications {
    if (_activeAppFilter == 'semua') return _applications;
    return _applications
        .where((a) => a.statusPengajuan.toLowerCase() == _activeAppFilter)
        .toList();
  }

  int get pendingApplicationsCount =>
      _applications.where((a) => a.isMenunggu).length;
  int get acceptedApplicationsCount =>
      _applications.where((a) => a.isDiterima).length;
  int get rejectedApplicationsCount =>
      _applications.where((a) => a.isDitolak).length;

  // ── Inisialisasi & Muat Data ──────────────────────────────────────────────
  Future<void> loadAll() async {
    await Future.wait([
      loadInvitations(),
      loadApplications(),
    ]);
  }

  // ── 1. Load Undangan Masuk (Alur D — Fuadi) ───────────────────────────────
  Future<void> loadInvitations() async {
    _isLoadingInvitations = true;
    _errorInvitations = null;
    notifyListeners();

    try {
      final myUserId = await StorageService.getUserId() ?? '';
      _invitations = await StatusService.getReceivedInvitations(myUserId);
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

  // ── 3. Load Lamaran Saya (Alur A — Rafa) ───────────────────────────────────
  Future<void> loadApplications() async {
    _isLoadingApplications = true;
    _errorApplications = null;
    notifyListeners();

    try {
      final result = await StatusService.getMyApplications();
      _applications = result.applications;
      _applicationsSummary = result.summary;
      _isLoadingApplications = false;
      notifyListeners();
    } catch (e) {
      _errorApplications = e.toString().replaceFirst('Exception: ', '');
      _isLoadingApplications = false;
      notifyListeners();
    }
  }

  // ── 4. Set Filter Lamaran ─────────────────────────────────────────────────
  void setAppFilter(String filterKey) {
    if (_activeAppFilter == filterKey) return;
    _activeAppFilter = filterKey;
    notifyListeners();
  }
}
