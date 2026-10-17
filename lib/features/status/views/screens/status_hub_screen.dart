import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../talent_search/services/talent_search_service.dart';
import '../../../team_feed/models/my_application_model.dart';
import '../../../team_feed/services/team_feed_service.dart';
import '../../../team_feed/views/screens/application_detail_screen.dart';

/// Layar Hub Status Terpadu (Tab ke-4: Status)
/// Menggabungkan:
/// - Sub-Tab 1: Undangan Masuk (Alur D - Fuadi, FR-24 & FR-25)
/// - Sub-Tab 2: Lamaran Saya (Alur A - Rafa, FR-19 & FR-20)
class StatusHubScreen extends StatefulWidget {
  final int initialSubTab;

  const StatusHubScreen({super.key, this.initialSubTab = 0});

  @override
  State<StatusHubScreen> createState() => _StatusHubScreenState();
}

class _StatusHubScreenState extends State<StatusHubScreen> with SingleTickerProviderStateMixin {
  late final TabController _subTabCtrl;

  // ── Alur D: Undangan Masuk State ──────────────────────────────────────────
  List<Map<String, dynamic>> _receivedInvitations = [];
  bool _loadingInvitations = true;
  String? _errorInvitations;
  final Set<String> _processingIds = {};

  // ── Alur A: Lamaran Saya State ────────────────────────────────────────────
  List<MyApplicationModel> _myApplications = [];
  bool _loadingApplications = true;
  String? _errorApplications;
  String _activeAppFilter = 'semua'; // 'semua', 'menunggu', 'diterima', 'ditolak'

  @override
  void initState() {
    super.initState();
    _subTabCtrl = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialSubTab.clamp(0, 1),
    );
    _subTabCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    _loadAll();
  }

  @override
  void dispose() {
    _subTabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadInvitations(),
      _loadApplications(),
    ]);
  }

  // ── 1. Load Undangan Masuk (Alur D) ───────────────────────────────────────
  Future<void> _loadInvitations() async {
    if (!mounted) return;
    setState(() {
      _loadingInvitations = true;
      _errorInvitations = null;
    });

    try {
      final myUserId = await StorageService.getUserId() ?? '';
      final list = await TalentSearchService.getReceivedInvitations(myUserId);
      if (mounted) {
        setState(() {
          _receivedInvitations = list;
          _loadingInvitations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorInvitations = e.toString().replaceFirst('Exception: ', '');
          _loadingInvitations = false;
        });
      }
    }
  }

  // ── 2. Load Lamaran Saya (Alur A) ─────────────────────────────────────────
  Future<void> _loadApplications() async {
    if (!mounted) return;
    setState(() {
      _loadingApplications = true;
      _errorApplications = null;
    });

    try {
      final result = await TeamFeedService.getMyApplications();
      if (mounted) {
        setState(() {
          _myApplications = result.applications;
          _loadingApplications = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorApplications = e.toString().replaceFirst('Exception: ', '');
          _loadingApplications = false;
        });
      }
    }
  }

  // ── Respon Undangan (Alur D - Fuadi) ───────────────────────────────────────
  Future<void> _respondInvitation(String idUndangan, String status, String teamName) async {
    if (_processingIds.contains(idUndangan)) return;

    final actionLabel = status == 'diterima' ? 'menerima' : 'menolak';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          status == 'diterima' ? 'Terima Undangan?' : 'Tolak Undangan?',
          style: AppTextStyles.titleMd.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin $actionLabel undangan bergabung ke tim "$teamName"?',
          style: AppTextStyles.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'diterima' ? AppColors.primary : AppColors.statusDangerText,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              status == 'diterima' ? 'Ya, Terima' : 'Ya, Tolak',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _processingIds.add(idUndangan));

    try {
      final res = await TalentSearchService.respondInvitation(
        idPengajuanAnggota: idUndangan,
        status: status,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Respons undangan berhasil disimpan.'),
          backgroundColor: status == 'diterima' ? AppColors.statusSuccessText : AppColors.statusDangerText,
          behavior: SnackBarBehavior.floating,
        ),
      );

      _loadInvitations();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.statusDangerText,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _processingIds.remove(idUndangan));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Segmented Switcher Pill ─────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Container(
            height: 46,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                _buildSegmentButton(
                  index: 0,
                  icon: Icons.mail_outline_rounded,
                  label: 'Undangan Masuk',
                  badgeCount: _receivedInvitations.where((i) => (i['status'] ?? 'menunggu') == 'menunggu').length,
                ),
                const SizedBox(width: 6),
                _buildSegmentButton(
                  index: 1,
                  icon: Icons.send_rounded,
                  label: 'Lamaran Saya',
                  badgeCount: _myApplications.where((a) => a.isMenunggu).length,
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.border),

        // ── Sub-Tab Views ───────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _subTabCtrl,
            children: [
              _buildInvitationsTab(),
              _buildApplicationsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentButton({
    required int index,
    required IconData icon,
    required String label,
    int badgeCount = 0,
  }) {
    final isSelected = _subTabCtrl.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _subTabCtrl.animateTo(index)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelMd.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  fontSize: 12.5,
                ),
              ),
              if (badgeCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUB-TAB 1: UNDANGAN MASUK (ALUR D - FUADI: FR-24 & FR-25)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildInvitationsTab() {
    if (_loadingInvitations) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorInvitations != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.statusDangerText, size: 48),
              const SizedBox(height: 12),
              Text('Gagal memuat undangan', style: AppTextStyles.titleMd),
              const SizedBox(height: 6),
              Text(_errorInvitations!, style: AppTextStyles.bodySm, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadInvitations,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    if (_receivedInvitations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mail_outline_rounded,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Belum Ada Undangan Masuk',
                style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Saat ketua tim mengundang Anda untuk bergabung ke tim mereka (Alur D), undangannya akan tampil di sini.',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInvitations,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: _receivedInvitations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _receivedInvitations[index];
          final idUndangan = item['id_undangan']?.toString() ?? '';
          final teamName = item['nama_tim']?.toString() ?? 'Tim';
          final activityName = item['nama_kegiatan']?.toString() ?? item['judul_kegiatan']?.toString() ?? '-';
          final inviterName = item['nama_pembuat']?.toString() ?? 'Ketua Tim';
          final position = item['posisi_tawaran']?.toString() ?? item['posisi']?.toString() ?? 'Anggota';
          final message = item['pesan_ajakan']?.toString() ?? '';
          final status = (item['status']?.toString() ?? 'menunggu').toLowerCase();
          final isPending = status == 'menunggu';
          final isProcessing = _processingIds.contains(idUndangan);
          final createdAt = item['created_at']?.toString() ?? '';

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPending ? AppColors.primaryOutline : AppColors.border,
                width: isPending ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isPending
                      ? AppColors.primary.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card Undangan
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.groups_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teamName,
                              style: AppTextStyles.titleMd.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activityName,
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 11.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),

                  // Detail Posisi & Pengundang
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Posisi Ditawarkan',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                position,
                                style: AppTextStyles.labelLg.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 26, color: AppColors.border),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pengundang',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                inviterName,
                                style: AppTextStyles.bodySm.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pesan Ajakan
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        '"$message"',
                        style: AppTextStyles.bodySm.copyWith(
                          fontStyle: FontStyle.italic,
                          fontSize: 11.5,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],

                  // Aksi Terima / Tolak (Hanya jika Menunggu)
                  if (isPending) ...[
                    const SizedBox(height: 14),
                    if (isProcessing)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.statusDangerText),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 11),
                              ),
                              onPressed: () => _respondInvitation(idUndangan, 'ditolak', teamName),
                              child: const Text(
                                'Tolak',
                                style: TextStyle(
                                  color: AppColors.statusDangerText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                elevation: 0,
                              ),
                              onPressed: () => _respondInvitation(idUndangan, 'diterima', teamName),
                              child: const Text(
                                'Terima Undangan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],

                  if (createdAt.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        createdAt.length >= 16 ? createdAt.substring(0, 16) : createdAt,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SUB-TAB 2: LAMARAN SAYA (ALUR A - RAFA: FR-19 & FR-20)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildApplicationsTab() {
    if (_loadingApplications) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorApplications != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.statusDangerText, size: 48),
              const SizedBox(height: 12),
              Text('Gagal memuat lamaran', style: AppTextStyles.titleMd),
              const SizedBox(height: 6),
              Text(_errorApplications!, style: AppTextStyles.bodySm, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadApplications,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    // Filter list
    final filtered = _activeAppFilter == 'semua'
        ? _myApplications
        : _myApplications.where((a) => a.statusPengajuan.toLowerCase() == _activeAppFilter).toList();

    final total = _myApplications.length;
    final pending = _myApplications.where((a) => a.isMenunggu).length;
    final accepted = _myApplications.where((a) => a.isDiterima).length;
    final rejected = _myApplications.where((a) => a.isDitolak).length;

    return RefreshIndicator(
      onRefresh: _loadApplications,
      color: AppColors.primary,
      child: Column(
        children: [
          // Ringkasan Metrik / Statistik
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                _buildStatPill('Total', '$total', AppColors.surfaceContainer, AppColors.text),
                const SizedBox(width: 8),
                _buildStatPill('Menunggu', '$pending', AppColors.statusPendingBg, AppColors.statusPendingText),
                const SizedBox(width: 8),
                _buildStatPill('Diterima', '$accepted', AppColors.statusSuccessBg, AppColors.statusSuccessText),
                const SizedBox(width: 8),
                _buildStatPill('Ditolak', '$rejected', AppColors.statusDangerBg, AppColors.statusDangerText),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildFilterChip('semua', 'Semua ($total)'),
                const SizedBox(width: 8),
                _buildFilterChip('menunggu', 'Menunggu ($pending)'),
                const SizedBox(width: 8),
                _buildFilterChip('diterima', 'Diterima ($accepted)'),
                const SizedBox(width: 8),
                _buildFilterChip('ditolak', 'Ditolak ($rejected)'),
              ],
            ),
          ),

          // List Lamaran
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: AppColors.primarySoft,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.send_rounded,
                              color: AppColors.primary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum Ada Pengajuan Terkirim',
                            style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Lamaran yang Anda kirimkan ke tim-tim di Beranda (Alur A) akan terpantau statusnya di sini.',
                            style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final app = filtered[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ApplicationDetailScreen(idPengajuan: app.idPengajuanBergabungTim),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          app.namaTim,
                                          style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          app.namaKegiatan,
                                          style: AppTextStyles.bodySm.copyWith(
                                            color: AppColors.textMuted,
                                            fontSize: 11.5,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildStatusBadge(app.statusPengajuan),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Posisi Dilamar: ${app.posisi}',
                                  style: AppTextStyles.labelMd.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                              if (app.pesanPengajuan.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '"${app.pesanPengajuan}"',
                                  style: AppTextStyles.bodySm.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.textMuted,
                                    fontSize: 11.5,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    app.formattedDate,
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: AppColors.textMuted,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Lihat Detail',
                                        style: AppTextStyles.labelMd.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String title, String count, Color bg, Color text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: AppTextStyles.titleMd.copyWith(
                fontWeight: FontWeight.bold,
                color: text,
                fontSize: 15,
              ),
            ),
            Text(
              title,
              style: AppTextStyles.labelSm.copyWith(
                color: text,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _activeAppFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _activeAppFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            color: isSelected ? Colors.white : AppColors.textMuted,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 11.5,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final s = status.toLowerCase();
    final Color bg;
    final Color text;
    final String label;

    switch (s) {
      case 'diterima':
        bg = AppColors.statusSuccessBg;
        text = AppColors.statusSuccessText;
        label = 'Diterima';
        break;
      case 'ditolak':
        bg = AppColors.statusDangerBg;
        text = AppColors.statusDangerText;
        label = 'Ditolak';
        break;
      default:
        bg = AppColors.statusPendingBg;
        text = AppColors.statusPendingText;
        label = 'Menunggu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSm.copyWith(
          color: text,
          fontWeight: FontWeight.bold,
          fontSize: 10.5,
        ),
      ),
    );
  }
}
