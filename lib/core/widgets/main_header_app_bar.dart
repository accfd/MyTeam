import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'notifications_modal.dart';

/// AppBar Resmi dan Seragam untuk 5 Layar Utama MyTeam
/// - Kiri: Logo resmi MyTeam + Nama Aplikasi 'MyTeam' + Subjudul 2-3 kata
/// - Kanan: Ikon Notifikasi universal dengan indikator notifikasi
class MainHeaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String subtitle;
  final VoidCallback? onRefresh;
  final List<Widget>? extraActions;

  const MainHeaderAppBar({
    super.key,
    required this.subtitle,
    this.onRefresh,
    this.extraActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.border,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      toolbarHeight: 60,
      title: Row(
        children: [
          // Logo MyTeam Seragam
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryOutline, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.asset(
                'assets/images/logo-MyTeam.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.groups_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Judul & Subjudul
          Expanded(
            child: Column(
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
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (extraActions != null) ...extraActions!,

        // Tombol Segarkan (opsional)
        if (onRefresh != null)
          Container(
            margin: const EdgeInsets.only(right: 8),
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
              onPressed: onRefresh,
              tooltip: 'Segarkan Halaman',
            ),
          ),

        // Tombol Notifikasi Universal (Pojok Kanan Atas di Seluruh Layar Utama)
        Container(
          margin: const EdgeInsets.only(right: 16),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.primary,
                  size: 21,
                ),
                onPressed: () => NotificationsModal.show(context),
                tooltip: 'Pusat Notifikasi',
              ),
              // Titik Indikator Notifikasi
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.statusDangerText,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
