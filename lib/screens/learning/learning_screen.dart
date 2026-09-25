import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/learning_article_model.dart';
import '../../components/learning/learning_category_filter.dart';
import '../../components/learning/learning_article_card.dart';
import '../../components/learning/article_detail_sheet.dart';

/// Screen representing the Financial Learning section in PennyPal.
/// Displays categorized guides with dynamic category filtering and detail preview.
class LearningScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const LearningScreen({super.key, this.onBack});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  final List<String> _categories = const ['All', 'Basics', 'Budgeting', 'Saving'];
  String _selectedCategory = 'All';

  final List<LearningArticleModel> _articles = LearningArticleModel.defaultArticles;

  List<LearningArticleModel> get _filteredArticles {
    if (_selectedCategory == 'All') {
      return _articles;
    }
    return _articles
        .where((article) => article.category.toLowerCase() == _selectedCategory.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayArticles = _filteredArticles;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Learning',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded, color: AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Saved articles bookmarked'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // 1. Horizontal Category Filter Chips
            LearningCategoryFilter(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: (cat) {
                setState(() => _selectedCategory = cat);
              },
            ),
            const SizedBox(height: 18),

            // 2. Filtered Articles Feed
            Expanded(
              child: displayArticles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            size: 48,
                            color: AppColors.textMuted.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No articles found for $_selectedCategory',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: displayArticles.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final article = displayArticles[index];
                        return LearningArticleCard(
                          article: article,
                          onTap: () {
                            ArticleDetailSheet.show(context, article);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
