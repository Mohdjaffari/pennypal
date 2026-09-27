import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/language_service.dart';

/// Modal bottom sheet for selecting the application language.
class LanguageSelectorSheet extends StatelessWidget {
  final String currentLanguage;

  const LanguageSelectorSheet({
    super.key,
    required this.currentLanguage,
  });

  static List<Map<String, String>> get languages => LanguageService.supportedLanguages;

  static Future<String?> show(BuildContext context, String currentLanguage) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LanguageSelectorSheet(currentLanguage: currentLanguage),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = AppColors.surfaceOf(context);
    final borderColor = AppColors.borderOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('select_language'),
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ...languages.map((lang) {
                final isSelected = lang['name'] == currentLanguage;
                return ListTile(
                  onTap: () => Navigator.of(context).pop(lang['name']),
                  tileColor: isSelected
                      ? (isDark ? AppColors.darkSurfaceMuted : AppColors.primaryBlueLight)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppColors.primaryBlue.withValues(alpha: 0.25) : AppColors.primaryBlueLight)
                          : (isDark ? AppColors.darkSurfaceMuted : AppColors.background),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        lang['code']!.toUpperCase(),
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    lang['name']!,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : textPrimary,
                      fontSize: 14.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    lang['native']!,
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue)
                      : null,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
