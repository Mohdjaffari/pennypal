import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/learning_article_model.dart';

/// Card item presenting a financial literacy article in the Learning feed.
/// Shows a completion checkmark overlay when [article.isCompleted] is true.
class LearningArticleCard extends StatelessWidget {
  final LearningArticleModel article;
  final VoidCallback? onTap;

  const LearningArticleCard({
    super.key,
    required this.article,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = article.isCompleted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Opacity(
          opacity: isCompleted ? 0.78 : 1.0,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted
                    ? AppColors.successGreen.withValues(alpha: isDark ? 0.35 : 0.25)
                    : AppColors.borderOf(context),
                width: isCompleted ? 1.2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Article Thumbnail Squircle
                Stack(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: isDark
                            ? article.imageColor.withValues(alpha: 0.2)
                            : article.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        article.imageIcon,
                        color: isCompleted
                            ? article.imageColor.withValues(alpha: 0.5)
                            : article.imageColor,
                        size: 32,
                      ),
                    ),
                    // Completed overlay badge
                    if (isCompleted)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.successGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),

                // 2. Article Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimaryOf(context),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          decoration: isCompleted ? TextDecoration.none : null,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Duration, Difficulty Level, and Category Row
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textMuted,
                            size: 13.5,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            article.duration,
                            style: TextStyle(
                              color: AppColors.textSecondaryOf(context),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          // Dot separator
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0),
                            child: Container(
                              width: 3.5,
                              height: 3.5,
                              decoration: BoxDecoration(
                                color: (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textMuted)
                                    .withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),

                          // Level tag
                          Text(
                            article.level,
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      // Completed label
                      if (isCompleted) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: const [
                            Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.successGreen,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Completed',
                              style: TextStyle(
                                color: AppColors.successGreen,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // 3. Trailing icon — check for completed, play for unread
                Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.successGreen.withValues(alpha: isDark ? 0.2 : 0.1)
                          : AppColors.primaryBlue.withValues(
                              alpha: isDark ? 0.2 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check_rounded
                          : Icons.arrow_forward_ios_rounded,
                      color: isCompleted
                          ? AppColors.successGreen
                          : AppColors.primaryBlue,
                      size: isCompleted ? 18 : 14,
                    ),
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
