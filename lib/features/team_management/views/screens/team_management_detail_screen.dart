import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/config/app_config.dart';
import '../../models/team_model.dart';
import '../../viewmodels/team_management_viewmodel.dart';
import '../widgets/team_category_badge.dart';
import '../widgets/team_status_badge.dart';
import '../widgets/team_management_edit_modal.dart';

/// Halaman Detail Tim Milik Pembuat — FR-09
class TeamManagementDetailScreen extends StatefulWidget {
  final String idTim;
  final TeamManagementViewModel viewModel;

  const TeamManagementDetailScreen({
    super.key,
    required this.idTim,
    required this.viewModel,
  });

  @override
  State<TeamManagementDetailScreen> createState() => _TeamManagementDetailScreenState();
}

class _TeamManagementDetailScreenState extends State<TeamManagementDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.viewModel.loadTeamDetail(widget.idTim);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.isLoadingDetail) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (widget.viewModel.detailError != null) {
            return _buildError(widget.viewModel.detailError!);
          }
          final team = widget.viewModel.selectedTeam;
          if (team == null) {
            return const Center(child: Text('Tim tidak ditemukan'));
          }
          return _buildDetail(team);
        },
      ),
    );
  }

  Widget _buildDetail(TeamModel team) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 160,
          pinned: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryDark, AppColors.primaryContainer],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          TeamCategoryBadge(
                              kategori: team.kategoriKegiatan),
                          const SizedBox(width: 8),
                          TeamStatusBadge(status: team.statusTim),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        team.namaTim,
                        style: AppTextStyles.headlineLg
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        team.namaKegiatan,
                        style: AppTextStyles.bodySm
                            .copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
              onPressed: () => _navigateToEdit(team),
              tooltip: 'Edit Tim',
            ),
          ],
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Deskripsi
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardHeader(
                          Icons.description_outlined, 'Deskripsi Tim'),
                      const SizedBox(height: 10),
                      Text(team.deskripsi, style: AppTextStyles.bodyMd),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Kebutuhan Anggota
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardHeader(
                          Icons.checklist_rounded, 'Kebutuhan Anggota'),
                      const SizedBox(height: 12),
                      ...team.kebutuhanTim.map((k) => _buildKebutuhanRow(k)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Anggota Tim
                _buildCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildCardHeader(
                              Icons.group_outlined, 'Anggota Tim'),
                          const Spacer(),
                          Text(
                            '${team.anggotaTim.length} Anggota',
                            style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (team.anggotaTim.isEmpty)
                        Text(
                          'Belum ada anggota yang bergabung.',
                          style: AppTextStyles.bodySm,
                        )
                      else
                        ...team.anggotaTim
                            .map((a) => _buildAnggotaRow(a)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Dokumen Pendukung
                if (team.dokumenPendukung.isNotEmpty) ...[
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCardHeader(
                            Icons.attach_file_rounded, 'Dokumen Pendukung'),
                        const SizedBox(height: 12),
                        ...team.dokumenPendukung
                            .map((d) => _buildDokumenRow(d)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 56, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(message,
              style: AppTextStyles.bodySm, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => widget.viewModel.loadTeamDetail(widget.idTim),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: child,
    );
  }

  Widget _buildCardHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.headlineMd),
      ],
    );
  }

  Widget _buildKebutuhanRow(KebutuhanTimModel k) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.radio_button_checked_rounded,
              size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(k.posisiDibutuhkan, style: AppTextStyles.titleMd),
                const SizedBox(height: 2),
                Text(k.keahlianDibutuhkan, style: AppTextStyles.bodySm),
                const SizedBox(height: 4),
                Text(
                  'Kuota: ${k.jumlahAnggotaDibutuhkan} orang',
                  style: AppTextStyles.labelSm
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnggotaRow(AnggotaTimModel a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primarySoft,
            backgroundImage: _getAvatarImage(a.fotoProfil),
            onBackgroundImageError: (_, __) {},
            child: _getAvatarImage(a.fotoProfil) == null
                ? Text(
                    a.namaPengguna?.isNotEmpty == true
                        ? a.namaPengguna![0].toUpperCase()
                        : '?',
                    style: AppTextStyles.titleMd
                        .copyWith(color: AppColors.primary),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.namaPengguna ?? 'Anggota',
                    style: AppTextStyles.titleMd),
                if (a.programStudi != null)
                  Text(a.programStudi!, style: AppTextStyles.bodySm),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              a.posisi,
              style: AppTextStyles.labelSm.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDokumenRow(DokumenPendukungModel d) {
    final bool isPoster = d.jenisDokumen == 'poster';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPoster ? Icons.image_outlined : Icons.description_outlined,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.namaFile,
                    style: AppTextStyles.bodyMd,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                  d.jenisDokumen.toUpperCase(),
                  style: AppTextStyles.labelSm
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const Icon(Icons.open_in_new_rounded,
              size: 16, color: AppColors.textMuted),
        ],
      ),
    );
  }

  void _navigateToEdit(TeamModel team) async {
    final result = await TeamManagementEditModal.show(
      context,
      team: team,
      viewModel: widget.viewModel,
    );
    if (result == true) {
      widget.viewModel.loadTeamDetail(widget.idTim);
    }
  }

  ImageProvider? _getAvatarImage(String? foto) {
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
}
