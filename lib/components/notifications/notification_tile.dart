import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/notification_model.dart';

/// Single item tile for displaying a notification,
/// directly matching Screen 11 from the PennyPal Figma board.
class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final DismissDirectionCallback? onDismissed;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: onDismissed,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: AppColors.expenseRed,
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: Material(
        color: notification.isUnread
            ? AppColors.surface
            : AppColors.background,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Unread Blue Indicator Dot
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 18),
                  decoration: BoxDecoration(
                    color: notification.isUnread
                        ? AppColors.primaryBlue
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),

                // 2. Colored Icon Squircle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: notification.backgroundColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    notification.icon,
                    color: notification.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // 3. Text Content (Title, Timestamp, and Message)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & TimeAgo Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14.5,
                                fontWeight: notification.isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            notification.timeAgo,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Message Body
                      Text(
                        notification.message,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
