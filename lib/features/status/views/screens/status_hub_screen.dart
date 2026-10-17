import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/invitation_model.dart';
import '../../viewmodels/status_viewmodel.dart';

/// Layar Hub Status Terpadu (Tab ke-4: Status) — Arsitektur MVVM
/// Menggabungkan:
/// - Sub-Tab 1: Undangan Masuk (Alur D - Fuadi, FR-24 & FR-25)
/// - Sub-Tab 2: Undangan Terkirim oleh pemilik tim (FR-25)
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
    final isAccepting = status == 'diterima';
    final actionLabel = isAccepting ? 'menerima' : 'menolak';
    final accentColor = isAccepting
        ? AppColors.primary
        : AppColors.statusDangerText;
    final confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup konfirmasi undangan',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: curved, child: child),
        );
      },
      pageBuilder: (ctx, animation, secondaryAnimation) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAccepting
                        ? Icons.mark_email_read_rounded
                        : Icons.mark_email_unread_rounded,
                    color: accentColor,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isAccepting ? 'Terima Undangan?' : 'Tolak Undangan?',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMd.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda akan $actionLabel undangan untuk bergabung ke tim:',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.groups_rounded,
                        color: accentColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invitation.namaTim,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelMd.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            invitation.posisiTawaran,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  icon: Icon(
                    isAccepting
                        ? Icons.check_circle_outline_rounded
                        : Icons.cancel_outlined,
                  ),
                  label: Text(
                    isAccepting ? 'Ya, Terima Undangan' : 'Ya, Tolak Undangan',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textMuted,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
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
            // ── Segmented Switcher Pill (Proporsi Presisi ProfileScreen) ────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 40,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Row(
                  children: [
                    _buildSegmentButton(
                      index: 0,
                      icon: Icons.mail_outline_rounded,
                      label: 'Undangan Masuk',
                      badgeCount: _viewModel.pendingInvitationsCount,
                    ),
                    _buildSegmentButton(
                      index: 1,
                      icon: Icons.send_rounded,
                      label: 'Undangan Terkirim',
                      badgeCount: _viewModel.pendingSentInvitationsCount,
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
                children: [_buildInvitationsTab(), _buildSentInvitationsTab()],
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
      child: GestureDetector(
        onTap: () => setState(() => _subTabCtrl.animateTo(index)),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
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
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textMuted,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (badgeCount > 0) ...[
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textMuted.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
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
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.statusDangerText,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text('Gagal memuat undangan', style: AppTextStyles.titleMd),
              const SizedBox(height: 6),
              Text(
                _viewModel.errorInvitations!,
                style: AppTextStyles.bodySm,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _viewModel.loadInvitations,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
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
                style: AppTextStyles.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Saat ketua tim mengundang Anda untuk bergabung ke tim mereka (Alur D), undangannya akan tampil di sini.',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textMuted,
                ),
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
                        child: const Icon(
                          Icons.groups_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
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
                        Container(
                          width: 1,
                          height: 26,
                          color: AppColors.border,
                        ),
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
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.statusDangerText,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 11,
                                ),
                              ),
                              onPressed: () =>
                                  _handleRespondInvitation(item, 'ditolak'),
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
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 11,
                                ),
                              ),
                              onPressed: () =>
                                  _handleRespondInvitation(item, 'diterima'),
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
  // SUB-TAB 2: UNDANGAN TERKIRIM OLEH PEMILIK TIM (FR-25)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSentInvitationsTab() {
    if (_viewModel.isLoadingSentInvitations) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_viewModel.errorSentInvitations != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.statusDangerText,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Gagal memuat undangan terkirim',
                style: AppTextStyles.titleMd,
              ),
              const SizedBox(height: 6),
              Text(
                _viewModel.errorSentInvitations!,
                style: AppTextStyles.bodySm,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _viewModel.loadSentInvitations,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _viewModel.filteredSentInvitations;
    final total = _viewModel.sentInvitations.length;
    final pending = _viewModel.pendingSentInvitationsCount;
    final accepted = _viewModel.acceptedSentInvitationsCount;
    final rejected = _viewModel.rejectedSentInvitationsCount;

    return RefreshIndicator(
      onRefresh: _viewModel.loadSentInvitations,
      color: AppColors.primary,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                _buildStatPill(
                  'Total',
                  '$total',
                  AppColors.surfaceContainer,
                  AppColors.text,
                ),
                const SizedBox(width: 8),
                _buildStatPill(
                  'Menunggu',
                  '$pending',
                  AppColors.statusPendingBg,
                  AppColors.statusPendingText,
                ),
                const SizedBox(width: 8),
                _buildStatPill(
                  'Diterima',
                  '$accepted',
                  AppColors.statusSuccessBg,
                  AppColors.statusSuccessText,
                ),
                const SizedBox(width: 8),
                _buildStatPill(
                  'Ditolak',
                  '$rejected',
                  AppColors.statusDangerBg,
                  AppColors.statusDangerText,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _buildSentInvitationFilterChip('semua', 'Semua ($total)'),
                const SizedBox(width: 8),
                _buildSentInvitationFilterChip(
                  'menunggu',
                  'Menunggu ($pending)',
                ),
                const SizedBox(width: 8),
                _buildSentInvitationFilterChip(
                  'diterima',
                  'Diterima ($accepted)',
                ),
                const SizedBox(width: 8),
                _buildSentInvitationFilterChip(
                  'ditolak',
                  'Ditolak ($rejected)',
                ),
              ],
            ),
          ),
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
                            'Belum Ada Undangan Terkirim',
                            style: AppTextStyles.titleMd.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Undangan yang Anda kirim sebagai pemilik tim akan muncul dan dapat dipantau statusnya di sini.',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textMuted,
                            ),
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
                      final invitation = filtered[index];
                      final status =
                          invitation['status_pengajuan']?.toString() ??
                          'menunggu';
                      final candidate =
                          invitation['nama_calon']?.toString() ??
                          'Calon anggota';
                      final team = invitation['nama_tim']?.toString() ?? 'Tim';
                      final event =
                          invitation['nama_kegiatan']?.toString() ?? '';
                      final position = invitation['posisi']?.toString() ?? '';
                      final sentAt = _formatSentInvitationDate(
                        invitation['waktu_pengajuan'],
                      );

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        candidate,
                                        style: AppTextStyles.titleMd.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Undangan dari tim $team',
                                        style: AppTextStyles.bodySm.copyWith(
                                          color: AppColors.textMuted,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildStatusBadge(status),
                              ],
                            ),
                            if (event.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                event,
                                style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Posisi ditawarkan: $position',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                            if ((invitation['pesan_pengajuan']?.toString() ??
                                    '')
                                .isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                '"${invitation['pesan_pengajuan']}"',
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
                            Text(
                              sentAt,
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatSentInvitationDate(dynamic value) {
    final raw = value?.toString() ?? '';
    if (raw.isEmpty) return '-';
    try {
      final date = DateTime.parse(raw).toLocal();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day/$month/${date.year}, $hour:$minute';
    } catch (_) {
      return raw;
    }
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
              style: AppTextStyles.labelSm.copyWith(color: text, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentInvitationFilterChip(String key, String label) {
    final isSelected = _viewModel.activeSentInvitationFilter == key;
    return GestureDetector(
      onTap: () => _viewModel.setSentInvitationFilter(key),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 0.8,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            color: isSelected ? Colors.white : AppColors.textMuted,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
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
