import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../team_feed/views/screens/application_detail_screen.dart';
import '../../models/invitation_model.dart';
import '../../viewmodels/status_viewmodel.dart';

/// Layar Hub Status Terpadu (Tab ke-4: Status) — Arsitektur MVVM
/// Menggabungkan:
/// - Sub-Tab 1: Undangan Masuk (Alur D - Fuadi, FR-24 & FR-25)
/// - Sub-Tab 2: Lamaran Saya (Alur A - Rafa, FR-19 & FR-20)
class StatusHubScreen extends StatefulWidget {
  final int initialSubTab;

  const StatusHubScreen({super.key, this.initialSubTab = 0});

  @override
  State<StatusHubScreen> createState() => _StatusHubScreenState();
}

class _StatusHubScreenState extends State<StatusHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _subTabCtrl;
  final StatusViewModel _viewModel = StatusViewModel();

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
    _viewModel.loadAll();
  }

  @override
  void dispose() {
    _subTabCtrl.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  // ── Dialog Respon Undangan (Alur D - Fuadi) ────────────────────────────────
  Future<void> _handleRespondInvitation(
    InvitationModel invitation,
    String status,
  ) async {
    final actionLabel = status == 'diterima' ? 'menerima' : 'menolak';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          status == 'diterima' ? 'Terima Undangan?' : 'Tolak Undangan?',
          style: AppTextStyles.titleMd.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin $actionLabel undangan bergabung ke tim "${invitation.namaTim}"?',
          style: AppTextStyles.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'diterima'
                  ? AppColors.primary
                  : AppColors.statusDangerText,
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

    try {
      final msg = await _viewModel.respondInvitation(
        idUndangan: invitation.idUndangan,
        status: status,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: status == 'diterima'
              ? AppColors.statusSuccessText
              : AppColors.statusDangerText,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.statusDangerText,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return Column(
          children: [
            // ── Segmented Switcher Pill ─────────────────────────────────────
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
                      badgeCount: _viewModel.pendingInvitationsCount,
                    ),
                    const SizedBox(width: 6),
                    _buildSegmentButton(
                      index: 1,
                      icon: Icons.send_rounded,
                      label: 'Lamaran Saya',
                      badgeCount: _viewModel.pendingApplicationsCount,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),

            // ── Sub-Tab Views ───────────────────────────────────────────────
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
      },
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
      flex: isSelected ? 4 : 2,
      child: GestureDetector(
        onTap: () => setState(() => _subTabCtrl.animateTo(index)),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOutCubic,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
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
              if (isSelected) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 12.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (badgeCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.textMuted.withValues(alpha: 0.5),
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
    if (_viewModel.isLoadingInvitations) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_viewModel.errorInvitations != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.statusDangerText, size: 48),
              const SizedBox(height: 12),
              Text('Gagal memuat undangan', style: AppTextStyles.titleMd),
              const SizedBox(height: 6),
              Text(_viewModel.errorInvitations!,
                  style: AppTextStyles.bodySm, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _viewModel.loadInvitations,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    final invitations = _viewModel.invitations;
    if (invitations.isEmpty) {
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
      onRefresh: _viewModel.loadInvitations,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: invitations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = invitations[index];
          final isPending = item.isMenunggu;
          final isProcessing = _viewModel.isProcessing(item.idUndangan);

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
                        child: const Icon(Icons.groups_rounded,
                            color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.namaTim,
                              style: AppTextStyles.titleMd.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.namaKegiatan,
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
                      _buildStatusBadge(item.status),
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
                                item.posisiTawaran,
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
                                item.namaPembuat,
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
                  if (item.pesanAjakan.isNotEmpty) ...[
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
                        '"${item.pesanAjakan}"',
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
                          child: CircularProgressIndicator(
                              color: AppColors.primary, strokeWidth: 2),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.statusDangerText),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 11),
                              ),
                              onPressed: () => _handleRespondInvitation(item, 'ditolak'),
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 11),
                              ),
                              onPressed: () => _handleRespondInvitation(item, 'diterima'),
                              child: const Text(
                                'Terima',
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
    if (_viewModel.isLoadingApplications) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_viewModel.errorApplications != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.statusDangerText, size: 48),
              const SizedBox(height: 12),
              Text('Gagal memuat status pengajuan', style: AppTextStyles.titleMd),
              const SizedBox(height: 6),
              Text(_viewModel.errorApplications!,
                  style: AppTextStyles.bodySm, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _viewModel.loadApplications,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _viewModel.filteredApplications;
    final total = _viewModel.applications.length;
    final pending = _viewModel.pendingApplicationsCount;
    final accepted = _viewModel.acceptedApplicationsCount;
    final rejected = _viewModel.rejectedApplicationsCount;

    return RefreshIndicator(
      onRefresh: _viewModel.loadApplications,
      color: AppColors.primary,
      child: Column(
        children: [
          // Ringkasan Metrik / Statistik
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                _buildStatPill('Total', '$total', AppColors.surfaceContainer,
                    AppColors.text),
                const SizedBox(width: 8),
                _buildStatPill('Menunggu', '$pending', AppColors.statusPendingBg,
                    AppColors.statusPendingText),
                const SizedBox(width: 8),
                _buildStatPill('Diterima', '$accepted', AppColors.statusSuccessBg,
                    AppColors.statusSuccessText),
                const SizedBox(width: 8),
                _buildStatPill('Ditolak', '$rejected', AppColors.statusDangerBg,
                    AppColors.statusDangerText),
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
                            style: AppTextStyles.titleMd
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Lamaran yang Anda kirimkan ke tim-tim di Beranda (Alur A) akan terpantau statusnya di sini.',
                            style: AppTextStyles.bodySm
                                .copyWith(color: AppColors.textMuted),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final app = filtered[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ApplicationDetailScreen(
                                  idPengajuan: app.idPengajuanBergabungTim),
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
                                          style: AppTextStyles.titleMd.copyWith(
                                              fontWeight: FontWeight.bold),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      const Icon(Icons.chevron_right_rounded,
                                          size: 16, color: AppColors.primary),
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
    final isSelected = _viewModel.activeAppFilter == key;
    return GestureDetector(
      onTap: () => _viewModel.setAppFilter(key),
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
