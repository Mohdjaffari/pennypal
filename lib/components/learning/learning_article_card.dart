import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/learning_article_model.dart';

/// Card item presenting a financial literacy article in the Learning feed.
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1),
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
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: article.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  article.imageIcon,
                  color: article.imageColor,
                  size: 32,
                ),
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
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Duration & Difficulty Level Row
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          color: AppColors.textMuted,
                          size: 13.5,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          article.duration,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        // Separator Dot
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Container(
                            width: 3.5,
                            height: 3.5,
                            decoration: BoxDecoration(
                              color: AppColors.textMuted.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        // Level Tag
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
                  ],
                ),
              ),

              // 3. Trailing Play/Read Icon
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.primaryBlue,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
