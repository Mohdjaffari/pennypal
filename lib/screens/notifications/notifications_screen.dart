import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/notification_model.dart';
import '../../components/notifications/notification_tile.dart';
import '../../core/localization/language_service.dart';

import '../../core/notifications/notification_service.dart';

/// Screen representing the Notifications view in PennyPal (Screen 11).
/// Supports marking notifications as read, swipe dismissal, and clearing alerts.
class NotificationsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const NotificationsScreen({super.key, this.onBack});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    NotificationService.instance.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    NotificationService.instance.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  void _markAllAsRead() {
    NotificationService.instance.markAllAsRead();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleNotificationRead(String id) {
    NotificationService.instance.toggleRead(id);
  }

  void _removeNotification(int index, NotificationModel removed) {
    NotificationService.instance.removeNotification(removed.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${removed.title}" removed'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.primaryBlue,
          onPressed: () {
            NotificationService.instance.insertNotification(index, removed);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifications = NotificationService.instance.notifications;
    final hasUnread = notifications.any((n) => n.isUnread);

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundOf(context),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimaryOf(context)),
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          context.tr('notifications'),
          style: TextStyle(
            color: AppColors.textPrimaryOf(context),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                context.tr('mark_all_read'),
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(
                        alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.1,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_off_outlined,
                      size: 32,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('all_caught_up'),
                    style: TextStyle(
                      color: AppColors.textPrimaryOf(context),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('no_alerts'),
                    style: TextStyle(
                      color: AppColors.textSecondaryOf(context),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 0.8,
                color: AppColors.borderOf(context),
                indent: 20,
                endIndent: 20,
              ),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return NotificationTile(
                  notification: notif,
                  onTap: () => _toggleNotificationRead(notif.id),
                  onDismissed: (direction) => _removeNotification(index, notif),
                );
              },
            ),
    );
  }
}
