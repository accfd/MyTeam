import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../features/team_feed/services/team_feed_service.dart';
import 'notifications_modal.dart';

/// AppBar Resmi dan Seragam untuk 5 Layar Utama MyTeam
/// - Kiri: Logo resmi MyTeam + Nama Aplikasi 'MyTeam' + Subjudul 2-3 kata
/// - Kanan: Ikon Notifikasi universal dengan indikator notifikasi
class MainHeaderAppBar extends StatefulWidget implements PreferredSizeWidget {
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
  State<MainHeaderAppBar> createState() => _MainHeaderAppBarState();
}

class _MainHeaderAppBarState extends State<MainHeaderAppBar> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await TeamFeedService.fetchUnreadNotificationCount();
      if (mounted) setState(() => _unreadCount = count);
    } catch (error) {
      debugPrint('Gagal memuat jumlah notifikasi belum dibaca: $error');
    }
  }

  Future<void> _showNotifications() async {
    await NotificationsModal.show(context);
    await _loadUnreadCount();
  }

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
                  widget.subtitle,
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
        if (widget.extraActions != null) ...widget.extraActions!,

        // Tombol Segarkan (opsional)
        if (widget.onRefresh != null)
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
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              onPressed: widget.onRefresh,
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
                onPressed: _showNotifications,
                tooltip: 'Pusat Notifikasi',
              ),
              if (_unreadCount > 0)
                Positioned(
                  top: 3,
                  right: 2,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16),
                    height: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.statusDangerText,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      _unreadCount > 99 ? '99+' : '$_unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
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
