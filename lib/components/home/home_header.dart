import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/language_service.dart';
import '../../core/notifications/notification_service.dart';
import '../../screens/notifications/notifications_screen.dart';

/// Sleek and sticky App Bar for screens across the PennyPal application.
/// Implements [PreferredSizeWidget] so it can be passed directly as [Scaffold.appBar],
/// keeping it permanently pinned at the top while content smoothly scrolls underneath.
class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String userName;
  final String? subtitle;
  final bool hasUnreadNotification;
  final bool isBackNavigation;
  final bool showNotificationButton;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final List<Widget>? actions;

  const HomeHeader({
    super.key,
    this.title,
    this.userName = 'Mohd Jaffari',
    this.subtitle,
    this.hasUnreadNotification = true,
    this.isBackNavigation = false,
    this.showNotificationButton = true,
    this.onMenuPressed,
    this.onNotificationPressed,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(74);

  /// Helper builder for matching elevated circular action buttons on the header
  static Widget circularButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? backgroundColor,
    Color? borderColor,
    double iconSize = 22,
    Widget? badge,
    String? tooltip,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bg = backgroundColor ?? AppColors.surfaceOf(context);
        final bd = borderColor ?? AppColors.borderOf(context);
        final ic = iconColor ?? AppColors.textPrimaryOf(context);

        return Material(
          color: bg,
          shape: CircleBorder(
            side: BorderSide(color: bd, width: 1),
          ),
          elevation: isDark ? 0 : 1.5,
          shadowColor: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
          clipBehavior: Clip.antiAlias,
          child: Tooltip(
            message: tooltip ?? '',
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onTap();
              },
              child: SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(icon, color: ic, size: iconSize),
                    ?badge,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final displayTitle = title ?? '${context.tr('hello')}, $userName';
    final displaySubtitle = subtitle ?? context.tr('header_subtitle');
    final bg = AppColors.backgroundOf(context);
    final surface = AppColors.surfaceOf(context);
    final border = AppColors.borderOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);

    Widget buildNotificationBell() {
      return circularButton(
        icon: Icons.notifications_none_rounded,
        onTap: () {
          if (onNotificationPressed != null) {
            onNotificationPressed!();
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationsScreen(),
              ),
            );
          }
        },
        tooltip: 'Notifications',
        iconColor: textPrimary,
        backgroundColor: surface,
        borderColor: border,
        badge: (hasUnreadNotification && NotificationService.instance.unreadCount > 0)
            ? Positioned(
                top: 10,
                right: 11,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: surface,
                      width: 1.5,
                    ),
                  ),
                ),
              )
            : null,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: border,
            width: 0.8,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left/Start: Squircle Button (Menu or Back) + Title/Subtitle
              Expanded(
                child: Row(
                  children: [
                    // Squircle Button
                    Material(
                      color: surface,
                      borderRadius: BorderRadius.circular(12),
                      elevation: 0,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          if (onMenuPressed != null) {
                            onMenuPressed!();
                          } else if (isBackNavigation) {
                            Navigator.of(context).maybePop();
                          } else {
                            Scaffold.of(context).openDrawer();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: border, width: 1),
                          ),
                          child: Icon(
                            isBackNavigation
                                ? (isRTL
                                    ? Icons.arrow_forward_rounded
                                    : Icons.arrow_back_rounded)
                                : Icons.menu_rounded,
                            color: textPrimary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Title & Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            displayTitle,
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 17.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              height: 1.35,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            displaySubtitle,
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Right: Custom Action Buttons and/or Notification Bell with Pink Badge
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (actions != null && actions!.isNotEmpty) ...[
                    for (int i = 0; i < actions!.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      actions![i],
                    ],
                    if (showNotificationButton) ...[
                      const SizedBox(width: 8),
                      buildNotificationBell(),
                    ],
                  ] else if (showNotificationButton)
                    buildNotificationBell(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

