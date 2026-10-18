import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/config/app_config.dart';
import '../../models/team_model.dart';
import 'team_category_badge.dart';
import 'team_status_badge.dart';

/// Kartu tim berformat potret (FR-09) — 2 kolom horizontal di mobile
class TeamCard extends StatelessWidget {
  final TeamModel team;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TeamCard({
    super.key,
    required this.team,
    required this.onTap,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPosterHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 6, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Tim + menu titik tiga sejajar
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            team.namaTim,
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onEdit != null || onDelete != null) ...[
                          const SizedBox(width: 4),
                          _buildPopupMenu(context),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.emoji_events_outlined, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            team.namaKegiatan,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TeamCategoryBadge(kategori: team.kategoriKegiatan),
                        if (team.kebutuhanTim.isNotEmpty) ...[
                          ...team.kebutuhanTim
                              .take(1)
                              .map((k) => _PosisiChip(label: k.posisiDibutuhkan)),
                          if (team.kebutuhanTim.length > 1)
                            _PosisiChip(
                              label: '+${team.kebutuhanTim.length - 1}',
                              isCount: true,
                            ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.group_outlined, size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '${team.anggotaTim.length} anggota',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      tooltip: 'Opsi Tim',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.white,
      onSelected: (value) {
        if (value == 'edit' && onEdit != null) onEdit!();
        if (value == 'delete' && onDelete != null) onDelete!();
      },
      itemBuilder: (context) => [
        if (onEdit != null)
          PopupMenuItem<String>(
            value: 'edit',
            height: 42,
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.edit_outlined, size: 15, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Text('Edit Tim', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
            ]),
          ),
        if (onEdit != null && onDelete != null) const PopupMenuDivider(height: 1),
        if (onDelete != null)
          PopupMenuItem<String>(
            value: 'delete',
            height: 42,
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.statusDangerBg, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.delete_outline_rounded, size: 15, color: AppColors.statusDangerText),
              ),
              const SizedBox(width: 10),
              Text('Hapus Tim', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.statusDangerText)),
            ]),
          ),
      ],
      child: const SizedBox(
        width: 24,
        height: 24,
        child: Center(
          child: Icon(
            Icons.more_vert_rounded,
            size: 18,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  String _resolveImageUrl(String pathFile) {
    if (pathFile.startsWith('http://') || pathFile.startsWith('https://')) return pathFile;
    final rootUrl = AppConfig.baseUrl.replaceAll('/api/v1', '');
    String cleaned = pathFile.replaceAll(r'\', '/');
    if (cleaned.startsWith('/')) cleaned = cleaned.substring(1);
    if (!cleaned.startsWith('storage/')) cleaned = 'storage/$cleaned';
    return '$rootUrl/$cleaned';
  }

  Widget _buildPosterHeader() {
    DokumenPendukungModel? posterDoc;
    DokumenPendukungModel? panduanDoc;
    for (final d in team.dokumenPendukung.reversed) {
      final name = d.namaFile.toLowerCase();
      final p = d.pathFile.toLowerCase();
      if (d.jenisDokumen == 'poster' || name.endsWith('.jpg') || name.endsWith('.jpeg') || name.endsWith('.png') || name.endsWith('.webp') || p.endsWith('.jpg') || p.endsWith('.jpeg') || p.endsWith('.png') || p.endsWith('.webp')) {
        posterDoc = d; break;
      }
    }
    if (posterDoc == null) {
      for (final d in team.dokumenPendukung.reversed) {
        final name = d.namaFile.toLowerCase();
        final p = d.pathFile.toLowerCase();
        if (d.jenisDokumen == 'panduan' || name.endsWith('.pdf') || p.endsWith('.pdf')) { panduanDoc = d; break; }
      }
    }
    Widget imageContent;
    if (posterDoc != null) {
      final imageUrl = _resolveImageUrl(posterDoc.pathFile);
      imageContent = Image.network(imageUrl, width: double.infinity, height: 115, fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholderHeader(label: posterDoc!.namaFile));
    } else if (panduanDoc != null) {
      imageContent = Container(
        width: double.infinity, height: 115,
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.picture_as_pdf_rounded, size: 28, color: Color(0xFFDC2626)),
          const SizedBox(height: 4),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(panduanDoc.namaFile, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF991B1B)), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ])),
      );
    } else {
      imageContent = _buildPlaceholderHeader();
    }
    return Stack(children: [
      imageContent,
      Container(height: 115, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.35), Colors.transparent]))),
      Positioned(top: 8, left: 8, child: TeamStatusBadge(status: team.statusTim)),
      Positioned(bottom: 8, left: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(99)),
          child: Text(team.isOwner ? 'Pemilik' : 'Anggota',
              style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.primary)))),
    ]);
  }

  Widget _buildPlaceholderHeader({String? label}) {
    return Container(
      width: double.infinity, height: 115,
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF008744), Color(0xFF059669)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.groups_rounded, color: Colors.white.withValues(alpha: 0.9), size: 32),
        if (label != null) ...[
          const SizedBox(height: 4),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ])),
    );
  }
}

class _PosisiChip extends StatelessWidget {
  final String label;
  final bool isCount;
  const _PosisiChip({required this.label, this.isCount = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: isCount ? 40 : 85),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isCount ? const Color(0xFFF1F5F9) : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: isCount ? const Color(0xFFCBD5E1) : AppColors.primaryOutline),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.labelSm.copyWith(
          color: isCount ? const Color(0xFF475569) : AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 9.5,
        ),
      ),
    );
  }
}
