import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/learning_article_model.dart';

/// Modal bottom sheet displaying article details and reading content.
class ArticleDetailSheet extends StatelessWidget {
  final LearningArticleModel article;

  const ArticleDetailSheet({super.key, required this.article});

  static Future<void> show(BuildContext context, LearningArticleModel article) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ArticleDetailSheet(article: article),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
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
          const SizedBox(height: 20),

          // Header: Category Pill & Close Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: article.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  article.category,
                  style: TextStyle(
                    color: article.imageColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            article.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),

          // Duration & Level Row
          Row(
            children: [
              const Icon(Icons.access_time_rounded, color: AppColors.textMuted, size: 14),
              const SizedBox(width: 4),
              Text(
                '${article.duration} read',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.signal_cellular_alt_rounded, color: AppColors.primaryBlue, size: 14),
              const SizedBox(width: 4),
              Text(
                article.level,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Summary / Educational Content
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              article.summary.isNotEmpty
                  ? article.summary
                  : 'Consistent budgeting and mindful expenditure tracking are the foundations of long-term financial freedom. Start with small, realistic saving targets and review your progress weekly.',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Mark as Completed',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
