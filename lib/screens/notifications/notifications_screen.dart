import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/notification_model.dart';
import '../../components/notifications/notification_tile.dart';

/// Screen representing the Notifications view in PennyPal (Screen 11).
/// Supports marking notifications as read, swipe dismissal, and clearing alerts.
class NotificationsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const NotificationsScreen({super.key, this.onBack});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationModel> _notifications =
      List.from(NotificationModel.defaultNotifications);

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isUnread: false);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleNotificationRead(int index) {
    setState(() {
      final current = _notifications[index];
      _notifications[index] = current.copyWith(isUnread: !current.isUnread);
    });
  }

  void _removeNotification(int index) {
    final removed = _notifications[index];
    setState(() {
      _notifications.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${removed.title}" removed'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.primaryBlue,
          onPressed: () {
            setState(() {
              _notifications.insert(index, removed);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _notifications.any((n) => n.isUnread);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark read',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlueLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_off_outlined,
                      size: 32,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'All Caught Up!',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'No new alerts at the moment.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 0.8,
                color: AppColors.border,
                indent: 20,
                endIndent: 20,
              ),
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return NotificationTile(
                  notification: notif,
                  onTap: () => _toggleNotificationRead(index),
                  onDismissed: (direction) => _removeNotification(index),
                );
              },
            ),
    );
  }
}
