import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Data model representing an educational article in the PennyPal Learning module.
class LearningArticleModel {
  final String id;
  final String title;
  final String duration;
  final String level;
  final String category; // 'Basics', 'Budgeting', 'Saving', etc.
  final Color imageColor;
  final Color backgroundColor;
  final IconData imageIcon;
  final String summary;

  const LearningArticleModel({
    required this.id,
    required this.title,
    required this.duration,
    required this.level,
    required this.category,
    required this.imageColor,
    required this.backgroundColor,
    required this.imageIcon,
    this.summary = '',
  });

  /// Factory preset of articles matching Screen 8 from the Figma board
  static List<LearningArticleModel> get defaultArticles => const [
        LearningArticleModel(
          id: 'art_1',
          title: 'Smart Budgeting for Students',
          duration: '5 min',
          level: 'Beginner',
          category: 'Budgeting',
          imageColor: AppColors.shoppingOrange,
          backgroundColor: AppColors.shoppingOrangeLight,
          imageIcon: Icons.school_rounded,
          summary:
              'Learn the 50/30/20 rule tailored for student budgets and part-time income streams.',
        ),
        LearningArticleModel(
          id: 'art_2',
          title: 'Saving Tips That Work',
          duration: '4 min',
          level: 'Beginner',
          category: 'Saving',
          imageColor: AppColors.primaryPink,
          backgroundColor: AppColors.primaryPinkLight,
          imageIcon: Icons.savings_rounded,
          summary:
              'Simple daily habits to automate micro-savings and build an emergency cushion.',
        ),
        LearningArticleModel(
          id: 'art_3',
          title: 'Understand Your Spending',
          duration: '8 min',
          level: 'Intermediate',
          category: 'Basics',
          imageColor: AppColors.purple,
          backgroundColor: AppColors.purpleLight,
          imageIcon: Icons.pie_chart_rounded,
          summary:
              'How to spot hidden recurring subscriptions and identify unnecessary impulse buys.',
        ),
        LearningArticleModel(
          id: 'art_4',
          title: 'Financial Goals 101',
          duration: '7 min',
          level: 'Beginner',
          category: 'Saving',
          imageColor: AppColors.successGreen,
          backgroundColor: AppColors.successGreenLight,
          imageIcon: Icons.track_changes_rounded,
          summary:
              'Set SMART milestone targets for gadgets, travel, and personal investments.',
        ),
      ];
}
