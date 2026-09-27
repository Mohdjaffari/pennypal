import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/learning_article_model.dart';
import '../../components/learning/learning_category_filter.dart';
import '../../components/learning/learning_article_card.dart';
import '../learning/article_detail_screen.dart';

/// Financial Learning screen — PennyPal.
///
/// Features:
///   - Extended category filter (All, Basics, Budgeting, Saving, Investing, Credit, Taxes)
///   - Completion state persisted in memory during session
///   - Progress banner showing how many articles are completed
///   - Navigates to [ArticleDetailScreen] (full-screen) on article tap
class LearningScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const LearningScreen({super.key, this.onBack});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  /// All available filter categories — one per financial topic.
  static const List<String> _categories = [
    'All',
    'Basics',
    'Budgeting',
    'Saving',
    'Investing',
    'Credit',
    'Taxes',
  ];

  String _selectedCategory = 'All';

  /// Mutable copy of articles so completion state can be toggled in-session.
  late List<LearningArticleModel> _articles;

  @override
  void initState() {
    super.initState();
    _articles = List<LearningArticleModel>.from(LearningArticleModel.defaultArticles);
  }

  // ── Derived state ────────────────────────────────────────────────────────

  List<LearningArticleModel> get _filteredArticles {
    if (_selectedCategory == 'All') return _articles;
    return _articles
        .where((a) => a.category.toLowerCase() == _selectedCategory.toLowerCase())
        .toList();
  }

  int get _completedCount => _articles.where((a) => a.isCompleted).length;
  int get _totalCount => _articles.length;

  // ── Handlers ────────────────────────────────────────────────────────────

  /// Opens the full-screen detail page and syncs the returned completion state.
  Future<void> _openArticle(LearningArticleModel article) async {
    final updated = await ArticleDetailScreen.push(
      context,
      article,
      onCompleted: (updatedArticle) {
        // Eager update for instant feedback on the card
        _syncArticle(updatedArticle);
      },
    );

    // Also sync if user used the pop mechanism directly
    if (updated != null) _syncArticle(updated);
  }

  void _syncArticle(LearningArticleModel updated) {
    if (!mounted) return;
    setState(() {
      final idx = _articles.indexWhere((a) => a.id == updated.id);
      if (idx != -1) _articles[idx] = updated;
    });
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayArticles = _filteredArticles;

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Progress banner (only visible when at least one article started)
            if (_completedCount > 0) ...[
              _ProgressBanner(
                completed: _completedCount,
                total: _totalCount,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
            ],

            // Category filter chips
            LearningCategoryFilter(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: (cat) {
                setState(() => _selectedCategory = cat);
              },
            ),
            const SizedBox(height: 18),

            // Article list or empty state
            Expanded(
              child: displayArticles.isEmpty
                  ? _EmptyState(category: _selectedCategory)
                  : _ArticleList(
                      articles: displayArticles,
                      onArticleTap: _openArticle,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundOf(context),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimaryOf(context)),
        onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        'Financial Learning',
        style: TextStyle(
          color: AppColors.textPrimaryOf(context),
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        // Completed count badge
        if (_completedCount > 0)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.successGreen.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  '$_completedCount/$_totalCount',
                  style: const TextStyle(
                    color: AppColors.successGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

/// Green progress banner with a linear indicator.
class _ProgressBanner extends StatelessWidget {
  final int completed;
  final int total;
  final bool isDark;

  const _ProgressBanner({
    required this.completed,
    required this.total,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    final isAllDone = completed == total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isAllDone
              ? AppColors.successGreen.withValues(alpha: isDark ? 0.2 : 0.1)
              : AppColors.primaryBlue.withValues(alpha: isDark ? 0.18 : 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAllDone
                ? AppColors.successGreen.withValues(alpha: 0.3)
                : AppColors.primaryBlue.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAllDone ? '🎉 All articles completed!' : 'Your Progress',
                  style: TextStyle(
                    color: isAllDone ? AppColors.successGreen : AppColors.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$completed of $total articles',
                  style: TextStyle(
                    color: isAllDone ? AppColors.successGreen : AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: isAllDone
                    ? AppColors.successGreen.withValues(alpha: 0.15)
                    : AppColors.primaryBlue.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isAllDone ? AppColors.successGreen : AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Article list with bounce physics.
class _ArticleList extends StatelessWidget {
  final List<LearningArticleModel> articles;
  final Future<void> Function(LearningArticleModel) onArticleTap;

  const _ArticleList({
    required this.articles,
    required this.onArticleTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: articles.length,
      separatorBuilder: (_, i) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final article = articles[index];
        return LearningArticleCard(
          article: article,
          onTap: () => onArticleTap(article),
        );
      },
    );
  }
}

/// Empty state shown when no articles match the selected category.
class _EmptyState extends StatelessWidget {
  final String category;
  const _EmptyState({required this.category});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 52,
            color: AppColors.textMuted.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 14),
          Text(
            'No articles in "$category" yet',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Check back soon — more content is on the way.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
