import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/config/app_config.dart';
import '../../models/my_application_model.dart';
import '../../services/team_feed_service.dart';
import 'team_feed_detail_screen.dart';

/// Layar Status Pengajuan Saya (FR-20)
/// Fokus: Melihat Status Pengajuan Bergabung Saya & Notifikasi Pembaruan Status
/// Aktor: Pencari Tim (Mahasiswa Pelamar)
/// PIC Modul 3: Rafa Gian Atthari
class MyApplicationsScreen extends StatefulWidget {
  final String? initialFilter;

  const MyApplicationsScreen({
    super.key,
    this.initialFilter,
  });

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  MyApplicationsResult? _result;

  // Filter aktif: 'Semua' | 'Menunggu' | 'Diterima' | 'Ditolak'
  late String _selectedFilter;

  final List<String> _filters = ['Semua', 'Menunggu', 'Diterima', 'Ditolak'];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter ?? 'Semua';
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await TeamFeedService.getMyApplications(
        status: _selectedFilter == 'Semua' ? null : _selectedFilter,
      );
      if (mounted) {
        setState(() {
          _result = res;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _onFilterChanged(String filter) {
    if (_selectedFilter == filter) return;
    setState(() => _selectedFilter = filter);
    _loadApplications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.border,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.text,
                  size: 22,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        titleSpacing: Navigator.canPop(context) ? 0 : 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Status Pengajuan Saya',
              style: AppTextStyles.titleMd.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            Text(
              'Pantau respon & hasil lamaran bergabung tim',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              onPressed: _loadApplications,
              tooltip: 'Segarkan Data',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Summary Statistik Strip ──────────────────────────────────────
          if (_result != null) _buildSummaryStrip(_result!.summary),

          // ── Filter Chips Bar ─────────────────────────────────────────────
          _buildFilterBar(),

          // ── Content List / States ────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: Colors.white,
              onRefresh: _loadApplications,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary Statistik Strip ────────────────────────────────────────────────
  Widget _buildSummaryStrip(MyApplicationsSummary summary) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          _buildSummaryItem(
            label: 'Total',
            count: summary.total,
            color: AppColors.primary,
            bgColor: AppColors.primarySoft,
            icon: Icons.assignment_rounded,
          ),
          const SizedBox(width: 8),
          _buildSummaryItem(
            label: 'Menunggu',
            count: summary.menunggu,
            color: const Color(0xFFA16207),
            bgColor: const Color(0xFFFEF9C3),
            icon: Icons.hourglass_top_rounded,
          ),
          const SizedBox(width: 8),
          _buildSummaryItem(
            label: 'Diterima',
            count: summary.diterima,
            color: const Color(0xFF15803D),
            bgColor: const Color(0xFFDCFCE7),
            icon: Icons.check_circle_rounded,
          ),
          const SizedBox(width: 8),
          _buildSummaryItem(
            label: 'Ditolak',
            count: summary.ditolak,
            color: const Color(0xFFDC2626),
            bgColor: const Color(0xFFFEE2E2),
            icon: Icons.cancel_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.85),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── Filter Chips Bar ───────────────────────────────────────────────────────
  Widget _buildFilterBar() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => _onFilterChanged(filter),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (filter == 'Menunggu')
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : const Color(0xFFEAB308),
                            shape: BoxShape.circle,
                          ),
                        )
                      else if (filter == 'Diterima')
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : const Color(0xFF16A34A),
                            shape: BoxShape.circle,
                          ),
                        )
                      else if (filter == 'Ditolak')
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : const Color(0xFFDC2626),
                            shape: BoxShape.circle,
                          ),
                        ),
                      Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.text,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Main Body ─────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.statusDangerBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFDC2626),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Gagal Memuat Data',
                style: AppTextStyles.headlineMd.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadApplications,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final apps = _result?.applications ?? [];

    if (apps.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: apps.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (ctx, index) {
        return _buildApplicationCard(apps[index]);
      },
    );
  }

  // ── Card Pengajuan (DESIGN.md Subbab 2.1 C & Card Pattern) ─────────────────
  Widget _buildApplicationCard(MyApplicationModel app) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showApplicationDetailModal(app),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Aksen semantik di sisi kiri (DESIGN.md 2.1 C)
                  Container(
                    width: 5.5,
                    color: app.statusBorderColor,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Header Card: Kategori & Status Badge
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  app.kategoriKegiatan.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryDark,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              _buildStatusBadge(app),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // 2. Nama Tim & Nama Kegiatan
                          Text(
                            app.namaTim,
                            style: AppTextStyles.titleMd.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppColors.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            app.namaKegiatan,
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 12),

                          // 3. Posisi yang Dilamar Chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.badge_outlined,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Posisi: ${app.posisi}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 4. Kutipan Pesan Lamaran
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFF3F4F6)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '“ ',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    height: 1.2,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    app.pesanPengajuan,
                                    style: AppTextStyles.bodySm.copyWith(
                                      color: AppColors.textMuted,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 11.5,
                                      height: 1.35,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 5. Callout Informasi Status Spesifik
                          if (app.isDiterima)
                            _buildAcceptedCallout(app)
                          else if (app.isMenunggu)
                            _buildPendingCallout()
                          else if (app.isDitolak)
                            _buildRejectedCallout(),

                          const SizedBox(height: 12),
                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: 10),

                          // 6. Footer Card: Info Pemilik Tim & Waktu Relatif
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 11,
                                backgroundColor: AppColors.primarySoft,
                                backgroundImage: _resolveAvatar(app.fotoPemilikTim),
                                child: app.fotoPemilikTim == null
                                    ? const Icon(
                                        Icons.person_rounded,
                                        size: 13,
                                        color: AppColors.primary,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Ketua: ${app.namaPemilikTim ?? "Pembuat Tim"}',
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 12,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    app.relativeTime,
                                    style: AppTextStyles.bodySm.copyWith(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Status Badge ───────────────────────────────────────────────────────────
  Widget _buildStatusBadge(MyApplicationModel app) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: app.statusBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: app.statusBorderColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            app.statusIcon,
            size: 13,
            color: app.statusTextColor,
          ),
          const SizedBox(width: 5),
          Text(
            app.statusLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: app.statusTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Callout Banner Status ──────────────────────────────────────────────────
  Widget _buildAcceptedCallout(MyApplicationModel app) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.celebration_rounded,
            size: 16,
            color: Color(0xFF15803D),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Selamat! Anda resmi menjadi anggota tim ini.',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF15803D),
              ),
            ),
          ),
          InkWell(
            onTap: () => _navigateToTeamDetail(app.idTim, app.namaTim),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: [
                  Text(
                    'Lihat Tim',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF15803D),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 12,
                    color: Color(0xFF15803D),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCallout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEFCE8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFEF08A)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 15,
            color: Color(0xFFA16207),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pengajuan sedang ditinjau oleh ketua tim.',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFA16207),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedCallout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 15,
            color: Color(0xFFDC2626),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pengajuan belum dapat diterima. Jangan berkecil hati!',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFDC2626),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Modal Detail Surat Lamaran & Tim ───────────────────────────────────────
  void _showApplicationDetailModal(MyApplicationModel app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Modal
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  app.namaTim,
                                  style: AppTextStyles.headlineMd.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  app.namaKegiatan,
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildStatusBadge(app),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 16),

                      // Posisi & Waktu Pengajuan
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryOutline),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.workspace_premium_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    app.posisi,
                                    style: AppTextStyles.titleMd.copyWith(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Dikirim pada ${app.formattedDate}',
                                    style: AppTextStyles.bodySm.copyWith(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Pesan Pengajuan / Surat Motivasi Lengkap
                      Text(
                        'Isi Surat Lamaran / Pesan Motivasi',
                        style: AppTextStyles.titleMd.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          app.pesanPengajuan,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.text,
                            height: 1.5,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      if (app.deskripsiTim != null && app.deskripsiTim!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Tentang Tim',
                          style: AppTextStyles.titleMd.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          app.deskripsiTim!,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textMuted,
                            height: 1.45,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Tombol Aksi: Buka Halaman Tim Lengkap
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _navigateToTeamDetail(app.idTim, app.namaTim);
                          },
                          icon: const Icon(Icons.arrow_outward_rounded, size: 18),
                          label: const Text(
                            'Buka Detail & Informasi Tim Lengkap',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToTeamDetail(String idTim, String? namaTim) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeamFeedDetailScreen(
          idTim: idTim,
          namaTim: namaTim,
        ),
      ),
    );
  }

  // ── Helper Resolusi Avatar ────────────────────────────────────────────────
  ImageProvider? _resolveAvatar(String? foto) {
    if (foto == null || foto.trim().isEmpty) return null;
    final trimmed = foto.trim();
    if (trimmed.startsWith('assets/')) return AssetImage(trimmed);
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return NetworkImage(trimmed);
    }
    if (trimmed.startsWith('profiles/') || trimmed.startsWith('storage/')) {
      final cleanPath =
          trimmed.startsWith('storage/') ? trimmed : 'storage/$trimmed';
      final rootUrl = AppConfig.baseUrl.replaceAll('/api/v1', '');
      return NetworkImage('$rootUrl/$cleanPath');
    }
    return null;
  }

  // ── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    String title;
    String subtitle;
    IconData icon;

    switch (_selectedFilter) {
      case 'Menunggu':
        title = 'Tidak Ada Lamaran Menunggu';
        subtitle = 'Seluruh lamaran yang Anda ajukan telah selesai diproses.';
        icon = Icons.hourglass_empty_rounded;
        break;
      case 'Diterima':
        title = 'Belum Ada Pengajuan Diterima';
        subtitle =
            'Ketika ketua tim menerima lamaran Anda, status kelulusan akan muncul di sini.';
        icon = Icons.sentiment_satisfied_rounded;
        break;
      case 'Ditolak':
        title = 'Tidak Ada Lamaran Ditolak';
        subtitle = 'Tidak ada riwayat pengajuan yang ditolak.';
        icon = Icons.thumb_up_alt_outlined;
        break;
      default:
        title = 'Belum Ada Pengajuan Terkirim';
        subtitle =
            'Anda belum pernah mengirimkan lamaran ke tim manapun.\nCari tim yang sesuai minat Anda di Feed Tim!';
        icon = Icons.send_rounded;
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.headlineMd.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textMuted,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.explore_rounded, size: 16),
              label: const Text('Jelajahi Feed Tim'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
