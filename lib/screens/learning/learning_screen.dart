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
                      showFeatured: _selectedCategory == 'All',
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
            padding: const EdgeInsets.only(right: 16),
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
                  isAllDone ? 'All articles completed' : 'Your Progress',
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

/// Featured hero card showing key educational guide.
class _FeaturedArticleCard extends StatelessWidget {
  final LearningArticleModel article;
  final VoidCallback onTap;

  const _FeaturedArticleCard({
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 185,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            if (article.imagePath != null)
              Image.asset(
                article.imagePath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: article.imageColor,
                ),
              )
            else
              Container(color: article.imageColor),

            // Gradient Overlay for contrast
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.40, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),

            // Card Content & Ripple Tap
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                splashColor: Colors.white.withValues(alpha: 0.15),
                highlightColor: Colors.white.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Featured Pill & Duration
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  'FEATURED • ${article.category.toUpperCase()}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.7,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              article.duration,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Bottom: Title & Action
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              Text(
                                'Read Guide',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Article list with bounce physics and optional hero featured card.
class _ArticleList extends StatelessWidget {
  final List<LearningArticleModel> articles;
  final bool showFeatured;
  final Future<void> Function(LearningArticleModel) onArticleTap;

  const _ArticleList({
    required this.articles,
    required this.showFeatured,
    required this.onArticleTap,
  });

  @override
  Widget build(BuildContext context) {
    if (showFeatured && articles.isNotEmpty && articles.first.imagePath != null) {
      final featured = articles.first;
      final rest = articles.sublist(1);

      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        physics: const BouncingScrollPhysics(),
        children: [
          _FeaturedArticleCard(
            article: featured,
            onTap: () => onArticleTap(featured),
          ),
          const SizedBox(height: 22),
          Text(
            'All Guides',
            style: TextStyle(
              color: AppColors.textPrimaryOf(context),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          ...rest.map((article) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: LearningArticleCard(
                  article: article,
                  onTap: () => onArticleTap(article),
                ),
              )),
        ],
      );
    }

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
