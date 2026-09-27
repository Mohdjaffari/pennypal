import 'package:flutter/material.dart';
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
        return Material(
          color: Colors.transparent,
          child: Tooltip(
            message: tooltip ?? '',
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: backgroundColor ?? AppColors.surfaceOf(context),
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor ?? AppColors.borderOf(context), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(icon, color: iconColor ?? AppColors.textPrimaryOf(context), size: iconSize),
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
    final displayTitle = title ?? '${context.tr('hello')}, $userName 👋';
    final displaySubtitle = subtitle ?? context.tr('header_subtitle');
    final bg = AppColors.backgroundOf(context);
    final surface = AppColors.surfaceOf(context);
    final border = AppColors.borderOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);

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
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onMenuPressed ??
                            () {
                              if (isBackNavigation) {
                                Navigator.of(context).maybePop();
                              } else {
                                Scaffold.of(context).openDrawer();
                              }
                            },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: border, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
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

              // Right: Custom Action Buttons or Notification Bell with Pink Badge
              if (actions != null && actions!.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                )
              else
                circularButton(
                  icon: Icons.notifications_none_rounded,
                  onTap: onNotificationPressed ??
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        );
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
