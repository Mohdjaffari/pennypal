import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Data model representing a notification in PennyPal.
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final bool isUnread;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.isUnread = false,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? timeAgo,
    IconData? icon,
    Color? color,
    Color? backgroundColor,
    bool? isUnread,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timeAgo: timeAgo ?? this.timeAgo,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isUnread: isUnread ?? this.isUnread,
    );
  }

  /// Initial default notifications matching Screen 11 from the Figma board
  static List<NotificationModel> get defaultNotifications => const [
        NotificationModel(
          id: 'notif_1',
          title: 'Spending Alert',
          message: "You've spent 80% of your food budget",
          timeAgo: '2h ago',
          icon: Icons.error_outline_rounded,
          color: AppColors.primaryPink,
          backgroundColor: AppColors.primaryPinkLight,
          isUnread: true,
        ),
        NotificationModel(
          id: 'notif_2',
          title: 'Goal Reminder',
          message: "Keep going! You're 50% done with your laptop goal",
          timeAgo: '6h ago',
          icon: Icons.track_changes_rounded,
          color: AppColors.primaryBlue,
          backgroundColor: AppColors.primaryBlueLight,
          isUnread: true,
        ),
        NotificationModel(
          id: 'notif_3',
          title: 'New Learning Article',
          message: "Check out new tips on smart saving",
          timeAgo: '1d ago',
          icon: Icons.lightbulb_outline_rounded,
          color: AppColors.successGreen,
          backgroundColor: AppColors.successGreenLight,
          isUnread: false,
        ),
        NotificationModel(
          id: 'notif_4',
          title: 'System Update',
          message: "New features are now available",
          timeAgo: '3d ago',
          icon: Icons.system_update_alt_rounded,
          color: AppColors.purple,
          backgroundColor: AppColors.purpleLight,
          isUnread: false,
        ),
      ];
}
