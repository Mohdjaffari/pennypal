import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Modal bottom sheet for selecting the application language.
class LanguageSelectorSheet extends StatelessWidget {
  final String currentLanguage;

  const LanguageSelectorSheet({
    super.key,
    required this.currentLanguage,
  });

  static const List<Map<String, String>> languages = [
    {'name': 'English', 'native': 'English', 'code': 'en'},
    {'name': 'Urdu', 'native': 'اردو', 'code': 'ur'},
    {'name': 'Arabic', 'native': 'العربية', 'code': 'ar'},
    {'name': 'Spanish', 'native': 'Español', 'code': 'es'},
    {'name': 'French', 'native': 'Français', 'code': 'fr'},
  ];

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
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
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
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Language',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ...languages.map((lang) {
                final isSelected = lang['name'] == currentLanguage;
                return ListTile(
                  onTap: () => Navigator.of(context).pop(lang['name']),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryBlueLight
                          : AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        lang['code']!.toUpperCase(),
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.textSecondary,
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
                          : AppColors.textPrimary,
                      fontSize: 14.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    lang['native']!,
                    style: const TextStyle(
                      color: AppColors.textMuted,
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
