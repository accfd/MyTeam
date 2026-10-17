import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../profile/models/data_diri_model.dart';
import '../../../profile/models/media_sosial_model.dart';
import '../../../profile/models/profile_detail_model.dart';
import '../../../profile/models/tim_diikuti_model.dart';
import '../../../profile/services/profile_service.dart';
import '../../../profile/views/widgets/profile_header_card.dart';
import '../../../team_management/services/team_management_service.dart';
import '../../models/talent_member_model.dart';
import '../../services/talent_search_service.dart';

/// Halaman Detail Profil Calon Anggota (FR-22)
/// Desain 100% identik dengan ProfileScreen (Header Card + 4 Tab: Tentang, Minat, Keahlian, Pengalaman)
/// Mode Read-Only (tanpa aksi edit/hapus) + Sticky Bottom Bar "Ajak Bergabung ke Tim"
class MemberDetailScreen extends StatefulWidget {
  final TalentMemberModel member;
  final String myUserId;

  const MemberDetailScreen({
    super.key,
    required this.member,
    required this.myUserId,
  });

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  ProfileDetailModel? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _tabCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    _loadProfileDetail();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfileDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final p = await ProfileService.getProfileDetail(widget.member.idPengguna);
      if (!mounted) return;
      setState(() {
        _profile = p;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _showInviteSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _InviteBottomSheet(
        member: widget.member,
        myUserId: widget.myUserId,
      ),
    );
  }

  Future<void> _openUrl(String urlString) async {
    try {
      String formattedUrl = urlString.trim();
      if (!formattedUrl.startsWith('http://') &&
          !formattedUrl.startsWith('https://')) {
        formattedUrl = 'https://$formattedUrl';
      }
      final uri = Uri.parse(formattedUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka tautan ini.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _openWhatsApp(String nomor) async {
    String cleanNumber = nomor.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNumber.startsWith('0')) {
      cleanNumber = '62${cleanNumber.substring(1)}';
    }
    final waUrl = 'https://wa.me/$cleanNumber';
    await _openUrl(waUrl);
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
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: Container(
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
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: AppColors.text,
                ),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Kembali',
              ),
            ),
          ),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Profil Calon Anggota',
              style: AppTextStyles.titleMd.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              widget.member.namaPengguna,
              style: AppTextStyles.labelSm.copyWith(
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
              icon: const Icon(Icons.refresh_rounded,
                  color: AppColors.primary, size: 20),
              onPressed: _loadProfileDetail,
              tooltip: 'Segarkan Profil',
            ),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null || _profile == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.statusDangerText, size: 48),
              const SizedBox(height: 12),
              Text('Gagal Memuat Profil', style: AppTextStyles.titleMd),
              const SizedBox(height: 6),
              Text(
                _errorMessage ?? 'Data profil tidak tersedia.',
                style: AppTextStyles.bodySm,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadProfileDetail,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    final p = _profile!;

    return RefreshIndicator(
      onRefresh: _loadProfileDetail,
      color: AppColors.primary,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ── Header Card Profil Seragam 100% ───────────────────────────────
          SliverToBoxAdapter(
            child: ProfileHeaderCard(
              user: p.pengguna,
              onGantiFoto: null, // Read-only
              onSettings: null,  // Read-only
            ),
          ),

          // ── Pinned TabBar Modern Kapsul (Identik dengan ProfileScreen) ────
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(_tabCtrl),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _buildTentangTab(p),
            _buildMinatTab(p),
            _buildKeahlianTab(p),
            _buildPengalamanTab(p),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. TAB TENTANG (Biodata, Kontak, Akademik, Medsos, Riwayat Tim)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTentangTab(ProfileDetailModel p) {
    final dd = p.dataDiri;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        // Tentang Saya
        _buildSectionCard(
          title: 'Tentang Saya',
          icon: Icons.person_outline_rounded,
          child: Text(
            (dd != null && dd.deskripsiSingkat.trim().isNotEmpty)
                ? dd.deskripsiSingkat
                : 'Mahasiswa ini belum menulis deskripsi diri.',
            style: AppTextStyles.bodyMd.copyWith(
              color: (dd != null && dd.deskripsiSingkat.trim().isNotEmpty)
                  ? AppColors.text
                  : AppColors.textMuted,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Akademik
        _buildAkademikCard(dd),
        const SizedBox(height: 16),

        // Kontak
        _buildKontakCard(dd),
        const SizedBox(height: 16),

        // Media Sosial
        _buildMedsosCard(p.mediaSosial),
        const SizedBox(height: 16),

        // Tim yang Diikuti
        _buildTimDiikutiCard(p.timDiikuti),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAkademikCard(DataDiriModel? dataDiri) {
    final prodi = (dataDiri != null && dataDiri.programStudi.isNotEmpty)
        ? dataDiri.programStudi
        : 'Sistem Informasi';
    final fakultas = (dataDiri != null && dataDiri.fakultas.isNotEmpty)
        ? dataDiri.fakultas
        : 'Teknologi Informasi';
    final ipk = (dataDiri?.ipk ?? 0.00).toStringAsFixed(2);

    return _buildSectionCard(
      title: 'Akademik',
      icon: Icons.school_outlined,
      child: Column(
        children: [
          _buildAkademikRow(Icons.school_outlined, 'Program Studi', prodi),
          const Divider(height: 16, color: AppColors.border),
          _buildAkademikRow(
              Icons.account_balance_outlined, 'Fakultas', fakultas),
          const Divider(height: 16, color: AppColors.border),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.categoryCompetitionBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.stars_rounded,
                    color: AppColors.categoryCompetitionText, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Indeks Prestasi Kumulatif',
                        style: AppTextStyles.labelSm
                            .copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 1),
                    Text('IPK: $ipk',
                        style: AppTextStyles.titleMd.copyWith(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAkademikRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.labelSm
                      .copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 1),
              Text(value,
                  style: AppTextStyles.titleMd
                      .copyWith(fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKontakCard(DataDiriModel? dataDiri) {
    final kontak = dataDiri?.kontak ?? '';
    final hasKontak = kontak.trim().isNotEmpty;

    return _buildSectionCard(
      title: 'Kontak',
      icon: Icons.phone_outlined,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: hasKontak ? () => _openWhatsApp(kontak) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.statusSuccessBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.chat_bubble_outline_rounded,
                      color: AppColors.statusSuccessText, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nomor Kontak / WhatsApp',
                          style: AppTextStyles.labelSm
                              .copyWith(color: AppColors.textMuted)),
                      const SizedBox(height: 2),
                      Text(
                        hasKontak ? kontak : 'Belum dicantumkan',
                        style: AppTextStyles.titleMd.copyWith(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                if (hasKontak) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.statusSuccessBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.open_in_new_rounded,
                            size: 12, color: AppColors.statusSuccessText),
                        const SizedBox(width: 4),
                        Text(
                          'Buka WA',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.statusSuccessText,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
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

  Widget _buildMedsosCard(List<MediaSosialModel> medsosList) {
    return _buildSectionCard(
      title: 'Media Sosial',
      icon: Icons.link_rounded,
      child: medsosList.isEmpty
          ? _buildEmptyState('Belum ada media sosial ditambahkan.')
          : Column(
              children: medsosList.map((m) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 2),
                    leading: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.language_rounded,
                          color: AppColors.primary, size: 18),
                    ),
                    title: Text(m.namaMediaSosial,
                        style: AppTextStyles.titleMd.copyWith(fontSize: 13.5)),
                    subtitle: Text(
                      m.linkMediaSosial,
                      style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textMuted, fontSize: 11.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.open_in_new_rounded,
                        size: 14, color: AppColors.primary),
                    onTap: () => _openUrl(m.linkMediaSosial),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildTimDiikutiCard(List<TimDiikutiModel> timList) {
    return _buildSectionCard(
      title: 'Tim yang Diikuti',
      icon: Icons.groups_rounded,
      child: timList.isEmpty
          ? _buildEmptyState('Mahasiswa belum tergabung dalam tim manapun.')
          : Column(
              children: timList.map((t) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.group_work_rounded,
                            color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(t.namaTim,
                                      style: AppTextStyles.titleMd.copyWith(
                                          fontWeight: FontWeight.w700)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.categoryCompetitionBg,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    t.kategoriKegiatan,
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: AppColors.categoryCompetitionText,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Kegiatan: ${t.namaKegiatan}',
                                style: AppTextStyles.bodySm
                                    .copyWith(color: AppColors.textMuted)),
                            const SizedBox(height: 2),
                            Text('Posisi: ${t.posisi}',
                                style: AppTextStyles.labelMd.copyWith(
                                    color: AppColors.primary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. TAB MINAT
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMinatTab(ProfileDetailModel p) {
    if (p.minat.isEmpty) {
      return _buildEmptyTab('Belum ada data minat yang ditambahkan.');
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        _buildSectionCard(
          title: 'Minat',
          icon: Icons.interests_rounded,
          child: Column(
            children: p.minat.map((m) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.categoryResearchBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.interests_rounded,
                          color: AppColors.categoryResearchText, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.minat,
                              style: AppTextStyles.titleMd.copyWith(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          if (m.deskripsiMinat.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(m.deskripsiMinat,
                                style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 12)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. TAB KEAHLIAN
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildKeahlianTab(ProfileDetailModel p) {
    if (p.keahlian.isEmpty) {
      return _buildEmptyTab('Belum ada data keahlian yang ditambahkan.');
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        _buildSectionCard(
          title: 'Keahlian',
          icon: Icons.auto_awesome_rounded,
          child: Column(
            children: p.keahlian.map((k) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded,
                          color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(k.keahlian,
                              style: AppTextStyles.titleMd.copyWith(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                          if (k.deskripsiKeahlian.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(k.deskripsiKeahlian,
                                style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 12)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. TAB PENGALAMAN
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPengalamanTab(ProfileDetailModel p) {
    if (p.pengalaman.isEmpty) {
      return _buildEmptyTab('Belum ada riwayat pengalaman yang ditambahkan.');
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        _buildSectionCard(
          title: 'Pengalaman',
          icon: Icons.workspace_premium_rounded,
          child: Column(
            children: p.pengalaman.map((exp) {
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
                            exp.namaKegiatan,
                            style: AppTextStyles.titleMd.copyWith(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.categoryCompetitionBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${exp.tahun}',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.categoryCompetitionText,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exp.peran,
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    if (exp.deskripsiPengalaman.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        exp.deskripsiPengalaman,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    Widget? action,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.headlineMd
                      .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ?action,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildEmptyTab(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_outlined,
                  color: AppColors.textMuted, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
      ),
    );
  }

  // ── Bottom Bar: Ajak Bergabung ke Tim ─────────────────────────────────────
  Widget _buildBottomBar() {
    if (widget.myUserId == widget.member.idPengguna) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _showInviteSheet,
            icon: const Icon(Icons.send_rounded, size: 18),
            label: Text(
              'Ajak Bergabung ke Tim',
              style: AppTextStyles.labelLg.copyWith(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Persistent TabBar Delegate (Identik 100% dengan ProfileScreen) ──────────
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController controller;

  _SliverTabBarDelegate(this.controller);

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
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
            _buildTabItem(0, Icons.person_rounded, 'Tentang'),
            _buildTabItem(1, Icons.interests_rounded, 'Minat'),
            _buildTabItem(2, Icons.auto_awesome_rounded, 'Keahlian'),
            _buildTabItem(3, Icons.workspace_premium_rounded, 'Pengalaman'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isSelected = controller.index == index;
    return Expanded(
      flex: isSelected ? 4 : 2,
      child: GestureDetector(
        onTap: () => controller.animateTo(index),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
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
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => true;
}

// ── Bottom Sheet Ajak Bergabung ke Tim ──────────────────────────────────────
class _InviteBottomSheet extends StatefulWidget {
  final TalentMemberModel member;
  final String myUserId;

  const _InviteBottomSheet({
    required this.member,
    required this.myUserId,
  });

  @override
  State<_InviteBottomSheet> createState() => _InviteBottomSheetState();
}

class _InviteBottomSheetState extends State<_InviteBottomSheet> {
  final _msgCtrl = TextEditingController();
  List<Map<String, dynamic>> _myTeams = [];
  bool _loadingTeams = true;
  String? _teamsErrorMsg;
  String? _selectedTeamId;
  String? _selectedPosition;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadMyTeams();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMyTeams() async {
    setState(() {
      _loadingTeams = true;
      _teamsErrorMsg = null;
    });

    try {
      final teams = await TeamManagementService.getMyTeams();
      if (!mounted) return;

      final eligible =
          teams.where((t) => t.statusTim.toLowerCase() != 'selesai').toList();

      setState(() {
        _myTeams = eligible.map((t) => {
          'id_tim': t.idTim,
          'nama_tim': t.namaTim,
          'nama_kegiatan': t.namaKegiatan,
          'kebutuhan_tim': t.kebutuhanTim.map((k) {
            final terisiCount = t.anggotaTim
                .where((a) =>
                    a.posisi.trim().toLowerCase() ==
                    k.posisiDibutuhkan.trim().toLowerCase())
                .length;
            return {
              'posisi_dibutuhkan': k.posisiDibutuhkan,
              'kuota': k.jumlahAnggotaDibutuhkan,
              'terisi': terisiCount,
            };
          }).toList(),
        }).toList();

        if (_myTeams.isNotEmpty) {
          _selectedTeamId = _myTeams.first['id_tim'];
          final pos = _availablePositions;
          if (pos.isNotEmpty) {
            _selectedPosition = pos.keys.first;
          }
        }
        _loadingTeams = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _teamsErrorMsg = e.toString().replaceFirst('Exception: ', '');
        _loadingTeams = false;
      });
    }
  }

  Map<String, int> get _availablePositions {
    final team = _myTeams.where((item) => item['id_tim'] == _selectedTeamId);
    if (team.isEmpty) return {};

    final needs = team.first['kebutuhan_tim'] as List<dynamic>? ?? [];
    final map = <String, int>{};
    for (final item in needs) {
      final pos = item['posisi_dibutuhkan']?.toString() ?? '';
      final kuota = (item['kuota'] as num?)?.toInt() ?? 1;
      final terisi = (item['terisi'] as num?)?.toInt() ?? 0;
      final remaining = kuota - terisi;
      if (remaining > 0 && pos.isNotEmpty) {
        map[pos] = remaining;
      }
    }
    return map;
  }

  Future<void> _sendInvitation() async {
    if (_selectedTeamId == null || _selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tim dan posisi terlebih dahulu.'),
          backgroundColor: AppColors.statusDangerText,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      await TalentSearchService.inviteMember(
        idTim: _selectedTeamId!,
        idPengguna: widget.member.idPengguna,
        posisi: _selectedPosition!,
        pesanPengajuan: _msgCtrl.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Undangan berhasil dikirim kepada ${widget.member.namaPengguna}!',
          ),
          backgroundColor: AppColors.statusSuccessText,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Judul Sheet
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ajak Bergabung ke Tim',
                          style: AppTextStyles.titleMd.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Kirim undangan kepada ${widget.member.namaPengguna}',
                          style: AppTextStyles.labelSm
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 16),

              if (_loadingTeams)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (_teamsErrorMsg != null)
                Text(_teamsErrorMsg!,
                    style:
                        const TextStyle(color: AppColors.statusDangerText))
              else if (_myTeams.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.textMuted, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Anda belum memiliki tim yang aktif.',
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Buat tim terlebih dahulu di tab MyTeam untuk dapat mengundang anggota.',
                        style: AppTextStyles.labelSm
                            .copyWith(color: AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else ...[
                // Pilih Tim
                Text('Pilih Tim Anda',
                    style: AppTextStyles.labelMd
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedTeamId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  items: _myTeams.map((t) {
                    return DropdownMenuItem<String>(
                      value: t['id_tim'],
                      child: Text(t['nama_tim'], style: AppTextStyles.bodySm),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedTeamId = val;
                      final pos = _availablePositions;
                      _selectedPosition =
                          pos.isNotEmpty ? pos.keys.first : null;
                    });
                  },
                ),
                const SizedBox(height: 14),

                // Pilih Posisi
                Text('Posisi yang Ditawarkan',
                    style: AppTextStyles.labelMd
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                if (_availablePositions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.statusDangerBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Semua kuota posisi pada tim ini telah penuh.',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.statusDangerText),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPosition,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    items: _availablePositions.entries.map((e) {
                      return DropdownMenuItem<String>(
                        value: e.key,
                        child: Text('${e.key} (Sisa ${e.value} kuota)',
                            style: AppTextStyles.bodySm),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedPosition = val);
                    },
                  ),
                const SizedBox(height: 14),

                // Pesan Ajakan
                Text('Pesan Ajakan (Opsional)',
                    style: AppTextStyles.labelMd
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _msgCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'Tuliskan alasan mengapa Anda mengajak mahasiswa ini bergabung...',
                    hintStyle: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textMuted),
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Tombol Kirim Undangan
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _sendInvitation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Kirim Undangan Sekarang',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
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
}
