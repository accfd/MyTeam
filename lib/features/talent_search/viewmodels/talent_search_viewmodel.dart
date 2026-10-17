import 'package:flutter/foundation.dart';
import '../../../../core/storage/storage_service.dart';
import '../models/talent_member_model.dart';
import '../services/talent_search_service.dart';

/// ViewModel untuk Modul Pencarian Talenta & Calon Anggota (FR-21 & FR-22)
/// Menangani logika bisnis pencarian, filter keahlian & minat, serta ekstraksi opsi dinamis
class TalentSearchViewModel extends ChangeNotifier {
  List<TalentMemberModel> _members = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;

  String? _activeFilterKeahlian;
  String? _activeFilterMinat;

  List<String> _dynamicKeahlian = [];
  List<String> _dynamicMinat = [];

  String _myUserId = '';

  // ── Getters ────────────────────────────────────────────────────────────────
  List<TalentMemberModel> get members => _members;
  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;
  String? get errorMessage => _errorMessage;

  String? get activeFilterKeahlian => _activeFilterKeahlian;
  String? get activeFilterMinat => _activeFilterMinat;

  List<String> get dynamicKeahlian => _dynamicKeahlian;
  List<String> get dynamicMinat => _dynamicMinat;

  String get myUserId => _myUserId;
  bool get hasActiveFilter =>
      _activeFilterKeahlian != null || _activeFilterMinat != null;

  // ── Inisialisasi ───────────────────────────────────────────────────────────
  Future<void> init() async {
    _myUserId = await StorageService.getUserId() ?? '';
    await loadMembers();
  }

  // ── Muat / Cari Anggota ────────────────────────────────────────────────────
  Future<void> loadMembers({
    String? q,
    String? keahlian,
    String? minat,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await TalentSearchService.searchMembers(
        q: q,
        keahlian: keahlian ?? _activeFilterKeahlian,
        minat: minat ?? _activeFilterMinat,
      );

      // Saring agar pengguna tidak melihat profil dirinya sendiri
      _members = _myUserId.isNotEmpty
          ? results.where((m) => m.idPengguna != _myUserId).toList()
          : results;

      // Rebuild opsi filter dinamis jika tidak ada filter aktif
      if (_activeFilterKeahlian == null && _activeFilterMinat == null) {
        _rebuildFilterOptions(_members);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Cari berdasarkan teks query ───────────────────────────────────────────
  void onSearch(String queryText) {
    final q = queryText.trim();
    _hasSearched = q.isNotEmpty || hasActiveFilter;
    loadMembers(
      q: q.isNotEmpty ? q : null,
      keahlian: _activeFilterKeahlian,
      minat: _activeFilterMinat,
    );
  }

  // ── Toggle Filter Keahlian ────────────────────────────────────────────────
  void toggleFilterKeahlian(String keahlian, String queryText) {
    if (_activeFilterKeahlian == keahlian) {
      _activeFilterKeahlian = null;
    } else {
      _activeFilterKeahlian = keahlian;
    }
    onSearch(queryText);
  }

  // ── Toggle Filter Minat ───────────────────────────────────────────────────
  void toggleFilterMinat(String minat, String queryText) {
    if (_activeFilterMinat == minat) {
      _activeFilterMinat = null;
    } else {
      _activeFilterMinat = minat;
    }
    onSearch(queryText);
  }

  // ── Reset Seluruh Filter ──────────────────────────────────────────────────
  void clearFilters() {
    _activeFilterKeahlian = null;
    _activeFilterMinat = null;
    _hasSearched = false;
    loadMembers();
  }

  // ── Ekstrak Opsi Filter Dinamis dari Data yang Ada ────────────────────────
  void _rebuildFilterOptions(List<TalentMemberModel> results) {
    final keahlianSet = <String>{};
    final minatSet = <String>{};

    for (final m in results) {
      keahlianSet.addAll(m.keahlian);
      minatSet.addAll(m.minat);
    }

    _dynamicKeahlian = keahlianSet.toList()..sort();
    _dynamicMinat = minatSet.toList()..sort();
  }
}
