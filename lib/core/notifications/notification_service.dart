import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../../models/notification_model.dart';
import '../../screens/notifications/notifications_screen.dart';

/// Centralized Notification & Push Alert Service for PennyPal.
/// Handles cross-screen reactive state synchronization (Settings, Drawer, Profile),
/// persistent SharedPreferences storage, in-app push notification banners,
/// and live notification collection management.
class NotificationService extends ChangeNotifier {
  static final NotificationService instance = NotificationService._internal();

  NotificationService._internal();

  static const String _prefNotificationsKey = 'pennypal_notifications_enabled';
  static const String _prefPushAlertsKey = 'pennypal_push_alerts_enabled';
  static const String _prefBudgetAlertsKey = 'pennypal_budget_alerts_enabled';
  static const String _prefSavingsAlertsKey = 'pennypal_savings_alerts_enabled';

  bool _notificationsEnabled = true;
  bool _pushAlertsEnabled = true;
  bool _budgetAlertsEnabled = true;
  bool _savingsAlertsEnabled = true;

  List<NotificationModel> _notifications =
      List.from(NotificationModel.defaultNotifications);

  bool get notificationsEnabled => _notificationsEnabled;
  bool get pushAlertsEnabled => _pushAlertsEnabled;
  bool get budgetAlertsEnabled => _budgetAlertsEnabled;
  bool get savingsAlertsEnabled => _savingsAlertsEnabled;

  /// Effective status: push alerts only trigger if both master switch & push alerts are enabled
  bool get isPushActive => _notificationsEnabled && _pushAlertsEnabled;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => n.isUnread).length;

  /// Initialize and load persisted user preferences from SharedPreferences
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool(_prefNotificationsKey) ?? true;
      _pushAlertsEnabled = prefs.getBool(_prefPushAlertsKey) ?? true;
      _budgetAlertsEnabled = prefs.getBool(_prefBudgetAlertsKey) ?? true;
      _savingsAlertsEnabled = prefs.getBool(_prefSavingsAlertsKey) ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('[NotificationService] init error: $e');
    }
  }

  /// Master notification toggle (used in Settings and Profile)
  Future<void> setNotificationsEnabled(bool value) async {
    if (_notificationsEnabled == value) return;
    _notificationsEnabled = value;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefNotificationsKey, value);
    } catch (e) {
      debugPrint('[NotificationService] save notifications error: $e');
    }
  }

  /// Push alerts toggle (used in Drawer and Granular Settings)
  Future<void> setPushAlertsEnabled(bool value) async {
    if (_pushAlertsEnabled == value) return;
    _pushAlertsEnabled = value;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefPushAlertsKey, value);
    } catch (e) {
      debugPrint('[NotificationService] save push alerts error: $e');
    }
  }

  /// Budget threshold alerts toggle
  Future<void> setBudgetAlertsEnabled(bool value) async {
    if (_budgetAlertsEnabled == value) return;
    _budgetAlertsEnabled = value;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefBudgetAlertsKey, value);
    } catch (e) {
      debugPrint('[NotificationService] save budget alerts error: $e');
    }
  }

  /// Savings milestone alerts toggle
  Future<void> setSavingsAlertsEnabled(bool value) async {
    if (_savingsAlertsEnabled == value) return;
    _savingsAlertsEnabled = value;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefSavingsAlertsKey, value);
    } catch (e) {
      debugPrint('[NotificationService] save savings alerts error: $e');
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    _notifications = _notifications
        .map((notif) => notif.copyWith(isUnread: false))
        .toList();
    notifyListeners();
  }

  /// Toggle read/unread state for a specific notification
  void toggleRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final current = _notifications[index];
      _notifications[index] = current.copyWith(isUnread: !current.isUnread);
      notifyListeners();
    }
  }

  /// Remove a notification item
  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  /// Reinsert an item (used for undo operations)
  void insertNotification(int index, NotificationModel item) {
    if (index >= 0 && index <= _notifications.length) {
      _notifications.insert(index, item);
      notifyListeners();
    }
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  /// Record and dispatch an in-app push notification banner
  void showInAppPushAlert(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.notifications_active_rounded,
    Color color = AppColors.primaryPink,
  }) {
    // If notifications or push alerts are disabled, respect user preference
    if (!isPushActive) return;

    // Add to notification history feed
    final newModel = NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      timeAgo: 'Just now',
      icon: icon,
      color: color,
      backgroundColor: color.withValues(alpha: 0.14),
      isUnread: true,
    );
    _notifications.insert(0, newModel);
    notifyListeners();

    // Display floating in-app banner with interactive dismiss and tap-to-view
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 12,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: isDark ? const Color(0xFF1E2846) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: color.withValues(alpha: 0.45),
            width: 1.2,
          ),
        ),
        duration: const Duration(seconds: 4),
        content: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationsScreen(),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Just now',
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                        fontSize: 12.5,
                        height: 1.25,
                      ),
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

  /// Triggers an immediate realistic test push notification
  void triggerTestAlert(BuildContext context) {
    if (!isPushActive) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Push alerts are currently muted. Enable them to receive notifications.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showInAppPushAlert(
      context,
      title: 'Spending Alert: Food & Dining',
      message:
          'You have reached 80% of your monthly food budget. Rs. 2,100 remaining.',
      icon: Icons.pie_chart_rounded,
      color: AppColors.primaryPink,
    );
  }
}
