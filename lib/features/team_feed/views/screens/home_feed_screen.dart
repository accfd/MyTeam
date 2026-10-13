import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/storage/storage_service.dart';
import '../../models/feed_team_model.dart';
import '../../../talent_search/models/talent_member_model.dart';
import '../../services/team_feed_service.dart';
import '../../../profile/views/screens/profile_screen.dart';
import '../../../team_management/views/screens/team_management_screen.dart';
import '../../../talent_search/views/screens/talent_search_screen.dart';
import '../../../talent_search/views/screens/received_invitations_screen.dart';

/// Home Screen — MyTeam
/// Feed utama: Rekomendasi Tim, Talenta Mahasiswa, CTA Buat Tim
/// Data real-time dari backend API MyTeam
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Session ───────────────────────────────────────────────────────────────
  String _nama = '';
  String _token = '';
  int _currentTab = 0;

  // ── Data ──────────────────────────────────────────────────────────────────
  List<TeamModel> _teams = [];
  List<MemberModel> _members = [];
  bool _loadingTeams = true;
  bool _loadingMembers = true;
  String? _teamError;

  // ── Filter & Search ───────────────────────────────────────────────────────
  String _selectedKategori = 'Semua';
  final _searchCtrl = TextEditingController();
  static const _kategoriList = ['Semua', 'Lomba', 'Penelitian', 'Proyek', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  Future<void> _initSession() async {
    _nama = await StorageService.getNama() ?? 'Mahasiswa';
    _token = await StorageService.getToken() ?? '';
    if (mounted) setState(() {});
    await Future.wait([_loadTeams(), _loadMembers()]);
  }

  Future<void> _loadTeams({String? search}) async {
    setState(() { _loadingTeams = true; _teamError = null; });
    try {
      final teams = await TeamService.fetchFeed(
        token: _token,
        search: search,
        kategori: _selectedKategori == 'Semua' ? null : _selectedKategori,
      );
      if (mounted) setState(() => _teams = teams);
    } catch (e) {
      if (mounted) setState(() => _teamError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingTeams = false);
    }
  }

  Future<void> _loadMembers() async {
    setState(() => _loadingMembers = true);
    try {
      final members = await TeamService.searchMembers(token: _token);
      if (mounted) setState(() => _members = members);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingMembers = false);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _currentTab == 4 ? null : _buildAppBar(),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: KeyedSubtree(
            key: ValueKey<int>(_currentTab),
            child: _buildBody(),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentTab) {
      case 0:
        return _buildPlaceholderTab(
          title: 'Feed & Rekomendasi Tim',
          moduleLabel: 'Modul 3 • Feed & Rekomendasi Kegiatan',
          description: 'Fitur untuk melihat pembukaan tim lomba, proyek, dan penelitian terbaru di lingkungan Universitas Andalas.',
          icon: Icons.explore_rounded,
        );
      case 1:
        // FR-21, FR-22, FR-23 — Modul 4 Diva Ramadhani
        return const TalentSearchScreen();
      case 2:
        return const TeamManagementScreen();
      case 3:
        // FR-24: Undangan Masuk + FR-25: Respon undangan & notifikasi
        return const ReceivedInvitationsScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget? _buildAppBar() {
    switch (_currentTab) {
      case 0:
        return _buildBrandedAppBar('Feed & Rekomendasi Kegiatan');
      case 1:
        // TalentSearchScreen manages its own header; AppBar still shown above
        return _buildBrandedAppBar('Eksplorasi & Pencarian Talenta');
      case 2:
      case 4:
        return null;
      case 3:
        // ReceivedInvitationsScreen has its own AppBar
        return null;
      default:
        return null;
    }
  }

  PreferredSizeWidget _buildBrandedAppBar(String subtitle) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.border,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/logo-MyTeam.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MyTeam',
                style: AppTextStyles.headlineMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
            onPressed: () {
              if (_currentTab == 0) {
                _loadTeams();
                _loadMembers();
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Halaman diperbarui.'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Segarkan Halaman',
          ),
        ),
      ],
    );
  }

  // ── Feed Body ─────────────────────────────────────────────────────────────
  // ignore: unused_element
  Widget _buildFeedBody() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildWelcomeSection()),
        SliverToBoxAdapter(child: _buildSearchBar()),
        SliverToBoxAdapter(child: _buildKategoriChips()),
        SliverToBoxAdapter(child: _buildCtaBanner()),
        SliverToBoxAdapter(child: _buildSectionHeader('Rekomendasi Tim', onLihatSemua: () {})),
        SliverToBoxAdapter(child: _buildTeamSection()),
        SliverToBoxAdapter(child: _buildSectionHeader('Talenta Mahasiswa', subtitle: 'Geser untuk melihat', onLihatSemua: () {})),
        SliverToBoxAdapter(child: _buildMemberSection()),
        SliverToBoxAdapter(child: _buildStatsBanner()),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  // ── Welcome Section ───────────────────────────────────────────────────────
  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Halo, ',
                        style: AppTextStyles.headlineMd.copyWith(fontSize: 20),
                      ),
                      TextSpan(
                        text: '$_nama! ',
                        style: AppTextStyles.headlineMd.copyWith(
                          fontSize: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      const TextSpan(
                        text: '👋',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Temukan tim impianmu hari ini',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: AppTextStyles.bodyMd,
                onSubmitted: (v) => _loadTeams(search: v.trim()),
                decoration: InputDecoration(
                  hintText: 'Cari tim, kegiatan, atau keahlian...',
                  hintStyle: AppTextStyles.bodySm,
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textMuted, size: 20),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  filled: false,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // ── Kategori Chips ────────────────────────────────────────────────────────
  Widget _buildKategoriChips() {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        scrollDirection: Axis.horizontal,
        itemCount: _kategoriList.length,
        itemBuilder: (context, i) {
          final k = _kategoriList[i];
          final isSelected = k == _selectedKategori;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedKategori = k);
              _loadTeams();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryContainer : Colors.white,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: isSelected ? AppColors.primaryContainer : AppColors.border,
                  width: 1,
                ),
              ),
              child: Text(
                k,
                style: AppTextStyles.bodyMd.copyWith(
                  color: isSelected ? Colors.white : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── CTA Banner ────────────────────────────────────────────────────────────
  Widget _buildCtaBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF006400), Color(0xFF008000)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(38),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '🚀 KOLABORASI CEPAT',
                      style: AppTextStyles.labelSm.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Punya Ide Kegiatan?',
                    style: AppTextStyles.headlineMd.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Buat tim impianmu dan temukan talenta terbaik se-Universitas Andalas!',
                    style: AppTextStyles.bodySm.copyWith(
                      color: Colors.white.withAlpha(204),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Buat Tim',
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded,
                              color: AppColors.primary, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.groups_rounded, color: Colors.white, size: 38),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Header ────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title,
      {String? subtitle, VoidCallback? onLihatSemua}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headlineMd.copyWith(fontSize: 17)),
                if (subtitle != null)
                  Text(subtitle, style: AppTextStyles.bodySm.copyWith(fontSize: 11)),
              ],
            ),
          ),
          if (onLihatSemua != null)
            GestureDetector(
              onTap: onLihatSemua,
              child: Text(
                'Lihat Semua →',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Team Section ──────────────────────────────────────────────────────────
  Widget _buildTeamSection() {
    if (_loadingTeams) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryContainer,
            strokeWidth: 2.5,
          ),
        ),
      );
    }
    if (_teamError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.statusDangerBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(_teamError!,
              style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.statusDangerText)),
        ),
      );
    }
    if (_teams.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off_rounded,
                  size: 48, color: AppColors.primaryOutline),
              const SizedBox(height: 8),
              Text('Belum ada tim tersedia',
                  style: AppTextStyles.bodySm),
            ],
          ),
        ),
      );
    }
    return Column(
      children: _teams.map((team) => _buildTeamCard(team)).toList(),
    );
  }

  Widget _buildTeamCard(TeamModel team) {
    final kategoriColor = _kategoriColor(team.kategori);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Left accent border (DESIGN.md 3.3: 3.5px green) ───────────
                Container(
                  width: 3.5,
                  color: _kategoriAccentColor(team.kategori),
                ),
                // ── Card Content ──────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: kategori badge + bookmark
            Row(
              children: [
                _buildBadge(team.kategori, kategoriColor.$1, kategoriColor.$2),
                const SizedBox(width: 6),
                if (team.kategori == 'Lomba')
                  _buildBadge('Kompetisi', AppColors.statusPendingBg, AppColors.statusPendingText),
                const Spacer(),
                const Icon(Icons.bookmark_border_rounded,
                    color: AppColors.textMuted, size: 20),
              ],
            ),
            const SizedBox(height: 10),

            // Nama Tim
            Text(
              team.namaTim,
              style: AppTextStyles.titleMd.copyWith(fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),

            // Nama Kegiatan
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 13, color: AppColors.textMuted),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    team.namaKegiatan,
                    style: AppTextStyles.bodySm.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const Divider(height: 20, color: AppColors.border),

            // Kebutuhan Tim
            if (team.kebutuhanTim.isNotEmpty) ...[
              Row(
                children: [
                  Text(
                    'Dibutuhkan:',
                    style: AppTextStyles.bodySm.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${team.totalPosisiTerbuka} Posisi Terbuka',
                    style: AppTextStyles.bodySm.copyWith(
                      fontSize: 11,
                      color: AppColors.statusDangerText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: team.kebutuhanTim
                    .take(3)
                    .map((k) => _buildSkillChip(k.posisi))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Ketua tim + tombol Detail
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primarySoft,
                  child: Text(
                    team.namaPengguna.isNotEmpty
                        ? team.namaPengguna[0].toUpperCase()
                        : 'T',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    team.namaPengguna,
                    style: AppTextStyles.bodySm.copyWith(
                        fontSize: 11, color: AppColors.textMuted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Detail',
                          style: AppTextStyles.labelMd.copyWith(
                              color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 13),
                      ],
                    ),
                  ),
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
    );
  }

  // ── Member Section (Talenta) ───────────────────────────────────────────────
  Widget _buildMemberSection() {
    if (_loadingMembers) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(
              color: AppColors.primaryContainer, strokeWidth: 2.5),
        ),
      );
    }
    if (_members.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 190,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 20, right: 8),
        scrollDirection: Axis.horizontal,
        itemCount: _members.length,
        itemBuilder: (context, i) => _buildMemberCard(_members[i]),
      ),
    );
  }

  Widget _buildMemberCard(MemberModel member) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primarySoft,
                    child: Text(
                      member.inisial,
                      style: AppTextStyles.titleMd.copyWith(
                          color: AppColors.primary, fontSize: 16),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppColors.statusSuccessText,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                            BorderSide(color: Colors.white, width: 2)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Nama
          Text(
            member.namaPengguna,
            style: AppTextStyles.bodyMd.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Prodi + Angkatan
          Text(
            '${member.programStudi} ${member.angkatan}',
            style: AppTextStyles.bodySm.copyWith(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Keahlian chips
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: member.keahlian
                .take(2)
                .map((k) => _buildSkillChip(k, fontSize: 9))
                .toList(),
          ),
          const Spacer(),

          // Lihat Profil
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryOutline, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lihat Profil',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.primary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.open_in_new_rounded,
                      color: AppColors.primary, size: 11),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats Banner ──────────────────────────────────────────────────────────
  Widget _buildStatsBanner() {
    final total = _teams.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryOutline, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.groups_rounded,
                  color: AppColors.primaryContainer, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$total Tim Aktif Tersedia',
                    style: AppTextStyles.titleMd.copyWith(
                      color: AppColors.primary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bergabung & wujudkan kolaborasi hebat',
                    style: AppTextStyles.bodySm.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.trending_up_rounded,
                color: AppColors.primaryContainer, size: 22),
          ],
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              _bottomNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Beranda'),
              _bottomNavItem(1, Icons.search_rounded, Icons.search_rounded, 'Cari'),
              _bottomNavItem(2, Icons.groups_outlined, Icons.groups_rounded, 'MyTeam'),
              _bottomNavItem(3, Icons.notifications_none_rounded, Icons.notifications_rounded, 'Notifikasi'),
              _bottomNavItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNavItem(int idx, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentTab == idx;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentTab = idx),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: isActive ? AppColors.primary : AppColors.textMuted,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── Placeholder Tabs ──────────────────────────────────────────────────────
  Widget _buildPlaceholderTab({
    required String title,
    required String moduleLabel,
    required String description,
    required IconData icon,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
              ),
              child: Icon(icon, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🚧', style: TextStyle(fontSize: 11)),
                  const SizedBox(width: 6),
                  Text(
                    'Tahap Pengembangan',
                    style: AppTextStyles.labelSm.copyWith(
                      color: const Color(0xFF92400E),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: AppTextStyles.headlineMd.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              moduleLabel,
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textMuted,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _currentTab = 4),
                icon: const Icon(Icons.person_rounded, size: 18),
                label: const Text('Buka Profil Saya (Modul 1)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: AppTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _buildBadge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSm.copyWith(color: fg, fontSize: 10),
      ),
    );
  }

  Widget _buildSkillChip(String label, {double fontSize = 10}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '• $label',
        style: AppTextStyles.labelSm.copyWith(
          color: AppColors.textMuted,
          fontSize: fontSize,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Color _kategoriAccentColor(String kategori) {
    return switch (kategori) {
      'Lomba' => AppColors.categoryCompetitionText,
      'Penelitian' => AppColors.categoryResearchText,
      'Proyek' => AppColors.statusPendingText,
      _ => AppColors.primaryContainer,
    };
  }

  (Color, Color) _kategoriColor(String kategori) {
    return switch (kategori) {
      'Lomba' => (AppColors.categoryCompetitionBg, AppColors.categoryCompetitionText),
      'Penelitian' => (AppColors.categoryResearchBg, AppColors.categoryResearchText),
      'Proyek' => (AppColors.statusPendingBg, AppColors.statusPendingText),
      _ => (AppColors.surfaceContainer, AppColors.textMuted),
    };
  }
}
