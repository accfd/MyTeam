import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../profile/models/profile_detail_model.dart';
import '../../../profile/services/profile_service.dart';
import '../../../profile/views/widgets/profile_header_card.dart';
import '../../../team_management/services/team_management_service.dart';
import '../../models/talent_member_model.dart';
import '../../services/talent_search_service.dart';

/// Halaman Detail Profil Calon Anggota (FR-22)
/// Seragam 100% dengan ProfileScreen (Header Card + 4 Tab Filter: Tentang, Minat, Keahlian, Pengalaman)
/// + Sticky Bottom Bar: Ajak Bergabung ke Tim (FR-23: POST /applications/invite-member)
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
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ProfileService.getProfileDetail(widget.member.idPengguna);
      if (mounted) {
        setState(() {
          _profile = data;
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat membuka tautan: $url'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── FR-23: Buka Bottom Sheet Undang ke Tim ────────────────────────────────
  Future<void> _showInviteSheet() async {
    final myId = widget.myUserId.isNotEmpty
        ? widget.myUserId
        : (await StorageService.getUserId() ?? '');

    if (!mounted) return;

    if (myId == widget.member.idPengguna) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda tidak dapat mengundang diri sendiri.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _InviteBottomSheet(
        member: widget.member,
        myUserId: myId,
      ),
    );
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
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.text),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Kembali',
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Profil Calon Anggota',
              style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            Text(
              widget.member.namaPengguna,
              style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted, fontSize: 11),
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
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 20),
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
              const Icon(Icons.error_outline_rounded, color: AppColors.statusDangerText, size: 48),
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
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
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
          // ── Header Card Profil Seragam ────────────────────────────────────
          SliverToBoxAdapter(
            child: ProfileHeaderCard(
              user: p.pengguna,
              onGantiFoto: null, // Mode lihat profil orang lain
              onSettings: null,
            ),
          ),

          // ── Pinned 4 Tab Bar (Tentang, Minat, Keahlian, Pengalaman) ────────
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
  // 1. TAB TENTANG (Biodata, Kontak, Akademik, Riwayat Tim)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTentangTab(ProfileDetailModel p) {
    final dd = p.dataDiri;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        // Ringkasan Diri / Bio
        _buildSectionCard(
          title: 'Tentang Saya',
          icon: Icons.person_pin_rounded,
          child: Text(
            (dd != null && dd.deskripsiSingkat.isNotEmpty)
                ? dd.deskripsiSingkat
                : 'Mahasiswa ini belum menulis deskripsi diri.',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.text,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Informasi Akademik & Kontak
        _buildSectionCard(
          title: 'Informasi Akademik & Kontak',
          icon: Icons.school_rounded,
          child: Column(
            children: [
              _buildInfoRow('Program Studi', dd?.programStudi ?? '-'),
              const Divider(height: 16, color: AppColors.border),
              _buildInfoRow('Fakultas', dd?.fakultas ?? '-'),
              const Divider(height: 16, color: AppColors.border),
              _buildInfoRow('Indeks Prestasi Kumulatif (IPK)', dd != null ? dd.ipk.toStringAsFixed(2) : '-'),
              const Divider(height: 16, color: AppColors.border),
              _buildInfoRow('Kontak WhatsApp / HP', dd?.kontak ?? '-'),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Media Sosial & Portofolio Tautan
        if (p.mediaSosial.isNotEmpty) ...[
          _buildSectionCard(
            title: 'Tautan Media Sosial & Portofolio',
            icon: Icons.link_rounded,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: p.mediaSosial.map((m) {
                return ActionChip(
                  backgroundColor: AppColors.primarySoft,
                  side: const BorderSide(color: AppColors.primaryOutline),
                  avatar: const Icon(Icons.open_in_new_rounded, size: 15, color: AppColors.primary),
                  label: Text(
                    m.namaMediaSosial,
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => _launchUrl(m.linkMediaSosial),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Riwayat Tim yang Pernah Diikuti
        _buildSectionCard(
          title: 'Riwayat Tim yang Diikuti',
          icon: Icons.workspace_premium_rounded,
          child: p.timDiikuti.isEmpty
              ? Text(
                  'Belum ada riwayat tim yang tercatat.',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                )
              : Column(
                  children: p.timDiikuti.map((t) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.groups_rounded, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.namaTim,
                                  style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${t.posisi} • ${t.namaKegiatan}',
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: AppColors.textMuted,
                                    fontSize: 11.5,
                                  ),
                                ),
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
  // 2. TAB MINAT
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildMinatTab(ProfileDetailModel p) {
    if (p.minat.isEmpty) {
      return _buildEmptyTab('Belum ada data minat yang ditambahkan.');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: p.minat.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final m = p.minat[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.categoryResearchBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.interests_rounded, color: AppColors.categoryResearchText, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.minat,
                      style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (m.deskripsiMinat.isNotEmpty)
                      Text(
                        m.deskripsiMinat,
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted, fontSize: 11.5),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. TAB KEAHLIAN
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildKeahlianTab(ProfileDetailModel p) {
    if (p.keahlian.isEmpty) {
      return _buildEmptyTab('Belum ada data keahlian yang ditambahkan.');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: p.keahlian.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final k = p.keahlian[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      k.keahlian,
                      style: AppTextStyles.labelLg.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (k.deskripsiKeahlian.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        k.deskripsiKeahlian,
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.text, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. TAB PENGALAMAN
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPengalamanTab(ProfileDetailModel p) {
    if (p.pengalaman.isEmpty) {
      return _buildEmptyTab('Belum ada riwayat pengalaman yang ditambahkan.');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: p.pengalaman.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final exp = p.pengalaman[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
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
                      style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.categoryCompetitionBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${exp.tahun}',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.categoryCompetitionText,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                exp.peran,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              if (exp.deskripsiPengalaman.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  exp.deskripsiPengalaman,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.titleMd.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyTab(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // ── Sticky Bottom Bar: Ajak Bergabung ke Tim ──────────────────────────────
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

// ── Persistent TabBar Delegate ──────────────────────────────────────────────
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;

  _SliverTabBarDelegate(this.tabController);

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: tabController,
        isScrollable: false,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w500, fontSize: 13),
        tabs: const [
          Tab(text: 'Tentang'),
          Tab(text: 'Minat'),
          Tab(text: 'Keahlian'),
          Tab(text: 'Pengalaman'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// INVITE BOTTOM SHEET (FR-23) — Dropdown pilih tim & posisi berkuota
// ─────────────────────────────────────────────────────────────────────────────
class _InviteBottomSheet extends StatefulWidget {
  final TalentMemberModel member;
  final String myUserId;

  const _InviteBottomSheet({required this.member, required this.myUserId});

  @override
  State<_InviteBottomSheet> createState() => _InviteBottomSheetState();
}

class _InviteBottomSheetState extends State<_InviteBottomSheet> {
  final _msgCtrl = TextEditingController();
  bool _isSending = false;
  String? _errorMsg;

  List<Map<String, dynamic>> _myTeams = [];
  bool _loadingTeams = true;
  String? _selectedTeamId;
  String? _selectedPosition;
  String? _teamsErrorMsg;

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

      final eligible = teams.where((t) => t.statusTim.toLowerCase() != 'selesai').toList();

      setState(() {
        _myTeams = eligible.map((t) => {
          'id_tim': t.idTim,
          'nama_tim': t.namaTim,
          'nama_kegiatan': t.namaKegiatan,
          'kebutuhan_tim': t.kebutuhanTim.map((k) {
            final terisiCount = t.anggotaTim
                .where((a) => a.posisi.trim().toLowerCase() == k.posisiDibutuhkan.trim().toLowerCase())
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
      setState(() => _errorMsg = 'Pilih tim dan posisi terlebih dahulu.');
      return;
    }

    final message = _msgCtrl.text.trim();
    if (message.isEmpty) {
      setState(() => _errorMsg = 'Pesan ajakan bergabung wajib diisi.');
      return;
    }

    setState(() {
      _isSending = true;
      _errorMsg = null;
    });

    try {
      await TalentSearchService.inviteMember(
        idTim: _selectedTeamId!,
        idPengguna: widget.member.idPengguna,
        posisi: _selectedPosition!,
        pesanPengajuan: message,
      );

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Undangan berhasil dikirimkan ke ${widget.member.namaPengguna}!',
          ),
          backgroundColor: AppColors.statusSuccessText,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMsg = e.toString().replaceFirst('Exception: ', '');
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.send_rounded, color: AppColors.primary, size: 18),
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
                          style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted),
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
                Text(_teamsErrorMsg!, style: const TextStyle(color: AppColors.statusDangerText))
              else if (_myTeams.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.textMuted, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Anda belum memiliki tim yang aktif.',
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Buat tim terlebih dahulu di tab MyTeam untuk dapat mengundang anggota.',
                        style: AppTextStyles.labelSm.copyWith(color: AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else ...[
                // Pilih Tim
                Text('Pilih Tim Anda', style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedTeamId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                      _selectedPosition = pos.isNotEmpty ? pos.keys.first : null;
                    });
                  },
                ),
                const SizedBox(height: 14),

                // Pilih Posisi
                Text('Posisi yang Ditawarkan', style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold)),
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
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.statusDangerText),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPosition,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    items: _availablePositions.entries.map((e) {
                      return DropdownMenuItem<String>(
                        value: e.key,
                        child: Text('${e.key} (Sisa ${e.value} kuota)', style: AppTextStyles.bodySm),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedPosition = val),
                  ),
                const SizedBox(height: 14),

                // Pesan Ajakan
                Text('Pesan Ajakan Bergabung', style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _msgCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Tuliskan alasan mengapa Anda mengajak mahasiswa ini...',
                    hintStyle: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                if (_errorMsg != null) ...[
                  const SizedBox(height: 8),
                  Text(_errorMsg!, style: const TextStyle(color: AppColors.statusDangerText, fontSize: 12)),
                ],
                const SizedBox(height: 18),

                // Tombol Kirim
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: (_isSending || _availablePositions.isEmpty) ? null : _sendInvitation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Kirim Undangan Sekarang',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
