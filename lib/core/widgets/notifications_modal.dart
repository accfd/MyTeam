import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../features/team_feed/services/team_feed_service.dart';

/// Modal Bottom Sheet Notifikasi Sistem MyTeam (Universal Inbox)
class NotificationsModal extends StatefulWidget {
  const NotificationsModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsModal(),
    );
  }

  @override
  State<NotificationsModal> createState() => _NotificationsModalState();
}

class _NotificationsModalState extends State<NotificationsModal> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await TeamFeedService.fetchNotifications();
      if (mounted) {
        setState(() {
          _notifications = data;
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

  IconData _iconForType(String? type) {
    return switch (type) {
      'undangan_tim' || 'undangan_masuk' => Icons.mail_outline_rounded,
      'lamaran_diterima' ||
      'pengajuan_diterima' => Icons.check_circle_outline_rounded,
      'lamaran_ditolak' || 'pengajuan_ditolak' => Icons.highlight_off_rounded,
      'anggota_baru' || 'respon_undangan' => Icons.group_add_outlined,
      _ => Icons.notifications_none_rounded,
    };
  }

  Color _colorForType(String? type) {
    return switch (type) {
      'undangan_tim' || 'undangan_masuk' => AppColors.primary,
      'lamaran_diterima' || 'pengajuan_diterima' => AppColors.statusSuccessText,
      'lamaran_ditolak' || 'pengajuan_ditolak' => AppColors.statusDangerText,
      'anggota_baru' || 'respon_undangan' => AppColors.primaryContainer,
      _ => AppColors.textMuted,
    };
  }

  Future<void> _markAllAsRead() async {
    try {
      await TeamFeedService.markAllNotificationsRead();
      await _loadNotifications();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menandai notifikasi dibaca: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) {
      final isRead = n['status_dibaca'] ?? n['dibaca'];
      return isRead == false || isRead == 0;
    }).length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Pusat Notifikasi',
                            style: AppTextStyles.titleMd.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.statusDangerText,
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                '$unreadCount Baru',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        'Pembaruan undangan, lamaran & aktivitas tim',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (unreadCount > 0)
                  IconButton(
                    icon: const Icon(
                      Icons.mark_email_read_outlined,
                      color: AppColors.primary,
                    ),
                    onPressed: _markAllAsRead,
                    tooltip: 'Tandai semua dibaca',
                  ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Tutup',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Content
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

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
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.statusDangerText,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text('Gagal memuat notifikasi', style: AppTextStyles.titleMd),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                style: AppTextStyles.bodySm,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _loadNotifications,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
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
                  color: AppColors.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textMuted,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Belum Ada Notifikasi',
                style: AppTextStyles.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Aktivitas undangan tim, respon lamaran, dan pembaruan penting akan muncul di sini.',
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
      onRefresh: _loadNotifications,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final notif = _notifications[index];
          final type = (notif['tipe'] ?? notif['jenis_notifikasi'])?.toString();
          final readValue = notif['status_dibaca'] ?? notif['dibaca'];
          final isRead = readValue == true || readValue == 1;
          final title =
              notif['judul']?.toString() ??
              (type == 'undangan_masuk' ? 'Undangan Tim' : 'Pemberitahuan');
          final message =
              (notif['pesan'] ?? notif['pesan_notifikasi'])?.toString() ?? '';
          final createdAt =
              (notif['created_at'] ?? notif['waktu_notifikasi'])?.toString() ??
              '';

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isRead
                  ? Colors.white
                  : AppColors.primarySoft.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isRead ? AppColors.border : AppColors.primaryOutline,
                width: isRead ? 1 : 1.2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _colorForType(type).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _iconForType(type),
                    color: _colorForType(type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: AppTextStyles.titleMd.copyWith(
                                fontSize: 13.5,
                                fontWeight: isRead
                                    ? FontWeight.w600
                                    : FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: AppTextStyles.bodySm.copyWith(
                          fontSize: 12,
                          color: isRead ? AppColors.textMuted : AppColors.text,
                          height: 1.35,
                        ),
                      ),
                      if (createdAt.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          createdAt.length >= 16
                              ? createdAt.substring(0, 16)
                              : createdAt,
                          style: AppTextStyles.labelSm.copyWith(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
