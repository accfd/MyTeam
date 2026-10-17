import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../profile/models/keahlian_model.dart';
import '../../../profile/models/media_sosial_model.dart';
import '../../../profile/models/minat_model.dart';
import '../../../profile/models/pengalaman_model.dart';
import '../../models/team_application_model.dart';
import '../../services/team_feed_service.dart';

/// Layar Detail Pengajuan Bergabung beserta Profil Akademik Pelamar (FR-18)
/// Aktor: Pembuat Tim (Ketua Tim)
/// PIC Modul 3: Rafa Gian Atthari (2411522014)
class ApplicationDetailScreen extends StatefulWidget {
  final String idPengajuan;
  final TeamApplicationModel? initialApplication;

  const ApplicationDetailScreen({
    super.key,
    required this.idPengajuan,
    this.initialApplication,
  });

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen>
    with SingleTickerProviderStateMixin {
  TeamApplicationModel? _application;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isSubmittingDecision = false;
  int _selectedTabIndex = 0; // 0: Keahlian, 1: Minat, 2: Pengalaman, 3: Medsos

  @override
  void initState() {
    super.initState();
    _application = widget.initialApplication;
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = _application == null;
      _errorMessage = null;
    });

    try {
      final detail = await TeamFeedService.fetchApplicationDetail(widget.idPengajuan);
      if (mounted) {
        setState(() {
          _application = detail;
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

  // ── FR-19: Terima / Tolak Lamaran ─────────────────────────────────────────
  Future<void> _handleDecision(String status) async {
    if (_application == null || _isSubmittingDecision) return;

    final isAccept = status == 'diterima';
    final applicantName = _application!.namaPengguna;
    final position = _application!.posisi;
    final teamName = _application!.namaTim ?? '';

    final confirmed = isAccept
        ? await _showAcceptConfirmationDialog(applicantName, position, teamName)
        : await _showRejectConfirmationDialog(applicantName, position);

    if (confirmed != true || !mounted) return;

    setState(() => _isSubmittingDecision = true);

    try {
      await TeamFeedService.respondToApplication(
        idPengajuan: widget.idPengajuan,
        status: status,
      );

      if (!mounted) return;

      setState(() {
        _application = _application!.copyWith(statusPengajuan: status);
        _isSubmittingDecision = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isAccept ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isAccept
                      ? 'Pengajuan berhasil diterima! $applicantName telah resmi menjadi anggota tim.'
                      : 'Pengajuan telah ditolak.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: isAccept ? AppColors.primaryDark : const Color(0xFFB91C1C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmittingDecision = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── Dialog Konfirmasi Destruktif / Penerimaan (DESIGN.md Subbab 3.8) ─────
  Future<bool?> _showRejectConfirmationDialog(
    String applicantName,
    String position,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.statusDangerBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFDC2626),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tolak Pengajuan?',
                style: AppTextStyles.headlineMd.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.bodyMd.copyWith(
                    color: const Color(0xFF991B1B),
                    height: 1.45,
                    fontSize: 13,
                  ),
                  children: [
                    const TextSpan(text: 'Anda akan menolak pengajuan dari '),
                    TextSpan(
                      text: applicantName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(text: ' untuk posisi '),
                    TextSpan(
                      text: '"$position"',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Pelamar tidak akan ditambahkan ke dalam tim. Sistem akan membuat dan mengirimkan notifikasi penolakan secara otomatis kepada pelamar.',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Tolak Pengajuan',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool?> _showAcceptConfirmationDialog(
    String applicantName,
    String position,
    String teamName,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                color: AppColors.primaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Terima Calon Anggota?',
                style: AppTextStyles.headlineMd.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          applicantName,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.badge_outlined, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Posisi: $position',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                  if (teamName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.groups_outlined, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            teamName,
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 11.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Pelamar akan otomatis dimasukkan ke dalam daftar Anggota Tim dan mendapatkan notifikasi penerimaan resmi.',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Terima Menjadi Anggota',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helper Kontak WhatsApp ───────────────────────────────────────────────
  Future<void> _launchWhatsApp(String phone) async {
    var cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = '62${cleanPhone.substring(1)}';
    }
    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka WhatsApp. Pastikan aplikasi terpasang.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _launchExternalUrl(String url) async {
    var formattedUrl = url.trim();
    if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }
    final uri = Uri.tryParse(formattedUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka tautan: $url'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin ke clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  ImageProvider? _resolveAvatarImage(String? foto) {
    if (foto == null || foto.trim().isEmpty) return null;
    final trimmed = foto.trim();
    if (trimmed.startsWith('assets/')) {
      return AssetImage(trimmed);
    }
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return NetworkImage(trimmed);
    }
    if (trimmed.startsWith('profiles/') || trimmed.startsWith('storage/')) {
      final cleanPath = trimmed.startsWith('storage/') ? trimmed : 'storage/$trimmed';
      final rootUrl = AppConfig.baseUrl.replaceAll('/api/v1', '');
      return NetworkImage('$rootUrl/$cleanPath');
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final app = _application;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _application?.statusPengajuan);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryContainer,
                  strokeWidth: 2.5,
                ),
              )
            : _errorMessage != null && app == null
                ? _buildErrorState()
                : RefreshIndicator(
                    color: AppColors.primaryContainer,
                    onRefresh: _fetchDetail,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Pilar 1: Surat / Formulir Lamaran
                          _buildApplicationLetterCard(app!),
                          const SizedBox(height: 16),

                          // Pilar 2: Biodata Akademik & Profil Pelamar
                          _buildApplicantProfileCard(app),
                          const SizedBox(height: 16),

                          // Pilar 2 (Lanjutan): Portofolio & Rekam Jejak Pelamar
                          _buildPortfolioSection(app),
                        ],
                      ),
                    ),
                  ),
        bottomNavigationBar: _buildStickyBottomBar(app),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text),
        onPressed: () => Navigator.pop(context, _application?.statusPengajuan),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Pengajuan',
            style: AppTextStyles.headlineMd.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Tinjau lamaran & portofolio pelamar',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: InkWell(
            onTap: _fetchDetail,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: const Icon(
                Icons.refresh_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.border, height: 1),
      ),
    );
  }

  // ── Pilar 1: Kartu Surat Lamaran (Aksen Hijau Unand) ─────────────────────
  Widget _buildApplicationLetterCard(TeamApplicationModel app) {
    Color statusBg;
    Color statusText;
    Color statusBorder;
    IconData statusIcon;
    String statusLabel;

    if (app.isDiterima) {
      statusBg = AppColors.statusSuccessBg;
      statusText = AppColors.statusSuccessText;
      statusBorder = const Color(0xFF86EFAC);
      statusIcon = Icons.check_circle_rounded;
      statusLabel = 'Diterima';
    } else if (app.isDitolak) {
      statusBg = AppColors.statusDangerBg;
      statusText = AppColors.statusDangerText;
      statusBorder = const Color(0xFFFCA5A5);
      statusIcon = Icons.cancel_rounded;
      statusLabel = 'Ditolak';
    } else {
      statusBg = AppColors.statusPendingBg;
      statusText = AppColors.statusPendingText;
      statusBorder = const Color(0xFFFDE68A);
      statusIcon = Icons.access_time_rounded;
      statusLabel = 'Menunggu';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Garis Aksen Hijau Unand tebal 4.5px di sisi kiri
              Container(
                width: 4.5,
                color: AppColors.primaryContainer,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris 1: Header Surat & Status Pill
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.work_outline_rounded,
                                      size: 15,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'POSISI YANG DILAMAR',
                                      style: AppTextStyles.bodySm.copyWith(
                                        color: AppColors.primaryDark,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  app.posisi,
                                  style: AppTextStyles.headlineMd.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(color: statusBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, size: 13, color: statusText),
                                const SizedBox(width: 5),
                                Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: statusText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Tim Tujuan & Waktu Kirim
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            if (app.namaTim != null && app.namaTim!.isNotEmpty) ...[
                              Row(
                                children: [
                                  const Icon(
                                    Icons.groups_rounded,
                                    size: 14,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${app.namaTim}${app.namaKegiatan != null ? ' • ${app.namaKegiatan}' : ''}',
                                      style: AppTextStyles.bodySm.copyWith(
                                        color: AppColors.text,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                            ],
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 13,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Dikirim: ${app.formattedDate}',
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 11.5,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  app.relativeTime,
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Kutipan Surat / Pesan Motivasi Pelamar
                      Row(
                        children: [
                          const Icon(
                            Icons.format_quote_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Pesan Motivasi Pelamar',
                            style: AppTextStyles.titleMd.copyWith(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: SelectableText(
                          app.pesanPengajuan.isNotEmpty
                              ? app.pesanPengajuan
                              : '(Pelamar tidak menyertakan pesan motivasi)',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: app.pesanPengajuan.isNotEmpty
                                ? const Color(0xFF374151)
                                : AppColors.textMuted,
                            height: 1.5,
                            fontStyle: app.pesanPengajuan.isNotEmpty
                                ? FontStyle.normal
                                : FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Pilar 2: Kartu Profil Pelamar (Candidate Card DESIGN.md 3.2) ──────────
  Widget _buildApplicantProfileCard(TeamApplicationModel app) {
    final avatarProvider = _resolveAvatarImage(app.fotoProfil);
    final hasKontak = app.kontak != null && app.kontak!.trim().isNotEmpty;
    final ipkVal = double.tryParse(app.ipk ?? '');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Header Seksi
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_pin_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Profil Akademik Pelamar',
                style: AppTextStyles.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Baris Atas: Avatar + Identitas Inti
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar dengan ring hijau Unand
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryContainer, width: 2.5),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primarySoft,
                  backgroundImage: avatarProvider,
                  child: avatarProvider == null
                      ? Text(
                          app.namaPengguna.isNotEmpty
                              ? app.namaPengguna[0].toUpperCase()
                              : 'M',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 14),

              // Identitas
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.namaPengguna,
                      style: AppTextStyles.headlineMd.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.badge_outlined,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'NIM: ${app.nim}',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.school_outlined,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${app.programStudi ?? 'Program Studi'} • ${app.fakultas ?? 'Universitas Andalas'}',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Badge IPK
                    if (ipkVal != null && ipkVal > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.categoryCompetitionBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: AppColors.categoryCompetitionText,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'IPK ${ipkVal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.categoryCompetitionText,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Deskripsi Diri Singkat (Bio)
          if (app.deskripsiSingkat != null && app.deskripsiSingkat!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                app.deskripsiSingkat!,
                style: AppTextStyles.bodyMd.copyWith(
                  color: const Color(0xFF4B5563),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // Verifikasi Kontak: WhatsApp & Nomor HP
          Row(
            children: [
              Expanded(
                child: hasKontak
                    ? ElevatedButton.icon(
                        onPressed: () => _launchWhatsApp(app.kontak!),
                        icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                        label: const Text('Hubungi via WhatsApp'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                      )
                    : OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.phone_disabled_rounded, size: 16),
                        label: const Text('Kontak Belum Tersedia'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
              ),
              if (hasKontak) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _copyToClipboard(app.kontak!, 'Nomor kontak'),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  tooltip: 'Salin nomor WhatsApp',
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor: AppColors.primarySoft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Pilar 2 (Lanjutan): Portofolio & Rekam Jejak Pelamar ──────────────────
  Widget _buildPortfolioSection(TeamApplicationModel app) {
    final keahlianCount = app.keahlian.length;
    final minatCount = app.minat.length;
    final pengalamanCount = app.pengalaman.length;
    final medsosCount = app.mediaSosial.length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Seksi Portofolio
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.folder_shared_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Portofolio & Rekam Jejak',
                        style: AppTextStyles.titleMd.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Data terintegrasi dari profil mahasiswa',
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

          // Sub-Tab Segmented Pill Control (DESIGN.md 3.7)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              height: 42,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _buildSegmentItem(0, 'Keahlian', Icons.auto_awesome_rounded, keahlianCount),
                  _buildSegmentItem(1, 'Minat', Icons.interests_rounded, minatCount),
                  _buildSegmentItem(2, 'Pengalaman', Icons.workspace_premium_rounded, pengalamanCount),
                  _buildSegmentItem(3, 'Tautan', Icons.share_rounded, medsosCount),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Konten Sub-Tab Terpilih
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _buildSelectedTabContent(app),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentItem(int index, String title, IconData icon, int count) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      flex: isSelected ? 4 : 2,
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 4,
                      offset: Offset(0, 1.5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
              if (isSelected) ...[
                const SizedBox(width: 5),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTabContent(TeamApplicationModel app) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildKeahlianTab(app.keahlian);
      case 1:
        return _buildMinatTab(app.minat);
      case 2:
        return _buildPengalamanTab(app.pengalaman);
      case 3:
        return _buildMedsosTab(app.mediaSosial);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Tab 1: Keahlian Teknis (FR-03) ────────────────────────────────────────
  Widget _buildKeahlianTab(List<KeahlianModel> keahlianList) {
    if (keahlianList.isEmpty) {
      return _buildEmptyPortfolioItem(
        Icons.auto_awesome_outlined,
        'Belum Ada Data Keahlian',
        'Pelamar belum menambahkan daftar keahlian teknis pada profilnya.',
      );
    }

    return Column(
      children: keahlianList.map((k) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primaryOutline),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          k.keahlian,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (k.deskripsiKeahlian.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  k.deskripsiKeahlian,
                  style: AppTextStyles.bodySm.copyWith(
                    color: const Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Tab 2: Minat Bidang (FR-04) ───────────────────────────────────────────
  Widget _buildMinatTab(List<MinatModel> minatList) {
    if (minatList.isEmpty) {
      return _buildEmptyPortfolioItem(
        Icons.interests_outlined,
        'Belum Ada Data Minat',
        'Pelamar belum mencantumkan minat bidang pada profilnya.',
      );
    }

    return Column(
      children: minatList.map((m) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.categoryResearchBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.interests_rounded,
                      size: 13,
                      color: AppColors.categoryResearchText,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      m.minat,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.categoryResearchText,
                      ),
                    ),
                  ],
                ),
              ),
              if (m.deskripsiMinat.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  m.deskripsiMinat,
                  style: AppTextStyles.bodySm.copyWith(
                    color: const Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Tab 3: Riwayat Pengalaman (FR-05) ─────────────────────────────────────
  Widget _buildPengalamanTab(List<PengalamanModel> pengalamanList) {
    if (pengalamanList.isEmpty) {
      return _buildEmptyPortfolioItem(
        Icons.workspace_premium_outlined,
        'Belum Ada Data Pengalaman',
        'Pelamar belum menyertakan riwayat kegiatan, lomba, atau kepanitiaan.',
      );
    }

    return Column(
      children: pengalamanList.map((p) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      p.namaKegiatan,
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.categoryCompetitionBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${p.tahun}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.categoryCompetitionText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.badge_outlined,
                    size: 13,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Peran: ${p.peran}',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                p.deskripsiPengalaman,
                style: AppTextStyles.bodyMd.copyWith(
                  color: const Color(0xFF374151),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Tab 4: Media Sosial & Tautan (FR-02) ──────────────────────────────────
  Widget _buildMedsosTab(List<MediaSosialModel> medsosList) {
    if (medsosList.isEmpty) {
      return _buildEmptyPortfolioItem(
        Icons.share_outlined,
        'Belum Ada Media Sosial',
        'Pelamar belum menautkan profil media sosial atau portofolio eksternal.',
      );
    }

    return Column(
      children: medsosList.map((m) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _buildSocialIcon(m.namaMediaSosial),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.namaMediaSosial,
                      style: AppTextStyles.titleMd.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      m.linkMediaSosial,
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
              OutlinedButton.icon(
                onPressed: () => _launchExternalUrl(m.linkMediaSosial),
                icon: const Icon(Icons.open_in_new_rounded, size: 14),
                label: const Text('Buka'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primaryOutline),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSocialIcon(String platform) {
    final lower = platform.toLowerCase();
    IconData iconData = Icons.link_rounded;
    Color iconColor = AppColors.primary;

    if (lower.contains('github')) {
      iconData = Icons.code_rounded;
      iconColor = const Color(0xFF181717);
    } else if (lower.contains('linkedin')) {
      iconData = Icons.business_center_rounded;
      iconColor = const Color(0xFF0A66C2);
    } else if (lower.contains('instagram')) {
      iconData = Icons.camera_alt_rounded;
      iconColor = const Color(0xFFE4405F);
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, size: 18, color: iconColor),
    );
  }

  Widget _buildEmptyPortfolioItem(IconData icon, String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.bodyMd.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Sticky Bottom Bar: Aksi Keputusan (FR-19) ─────────────────────────────
  Widget? _buildStickyBottomBar(TeamApplicationModel? app) {
    if (app == null) return null;

    // Jika masih menunggu: Sediakan tombol Tolak (50%) & Terima (50%)
    if (app.isMenunggu) {
      return Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Tombol "Tolak" (Outlined Merah #DC2626)
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isSubmittingDecision
                      ? null
                      : () => _handleDecision('ditolak'),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Tolak'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Tombol "Terima" (Solid Hijau Unand #008000)
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isSubmittingDecision
                      ? null
                      : () => _handleDecision('diterima'),
                  icon: _isSubmittingDecision
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 18),
                  label: Text(_isSubmittingDecision ? 'Memproses...' : 'Terima'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Jika sudah diterima / ditolak: Tampilkan banner status keputusan
    final isAccepted = app.isDiterima;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        14,
        16,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isAccepted ? AppColors.statusSuccessBg : AppColors.statusDangerBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isAccepted ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isAccepted ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 20,
              color: isAccepted ? AppColors.statusSuccessText : AppColors.statusDangerText,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isAccepted
                    ? 'Pengajuan telah diterima. Mahasiswa ini telah resmi menjadi anggota tim.'
                    : 'Pengajuan telah ditolak.',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: isAccepted ? AppColors.statusSuccessText : AppColors.statusDangerText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error State ───────────────────────────────────────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: AppColors.statusDangerText,
            ),
            const SizedBox(height: 14),
            Text(
              'Gagal Memuat Detail Pengajuan',
              style: AppTextStyles.headlineMd.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? 'Terjadi kesalahan sistem saat memproses rincian pengajuan.',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchDetail,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
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
}
