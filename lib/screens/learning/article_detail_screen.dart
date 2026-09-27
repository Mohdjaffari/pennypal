import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../models/learning_article_model.dart';

/// Full-screen detail page for a financial literacy article.
///
/// Architecture:
///   - Hero transition from the article card icon
///   - Sticky gradient app bar with transparent-to-surface scroll effect
///   - Key Takeaways chip-list at top
///   - Rich multi-section body with dividers
///   - Practical Action Steps with numbered callouts
///   - Persistent bottom "Mark as Completed" CTA bar
class ArticleDetailScreen extends StatefulWidget {
  final LearningArticleModel article;

  /// Called when the user marks the article as completed.
  /// Returns the updated model so the parent can persist the state.
  final ValueChanged<LearningArticleModel>? onCompleted;

  const ArticleDetailScreen({
    super.key,
    required this.article,
    this.onCompleted,
  });

  /// Push a [MaterialPageRoute] with a slide-up transition.
  static Future<LearningArticleModel?> push(
    BuildContext context,
    LearningArticleModel article, {
    ValueChanged<LearningArticleModel>? onCompleted,
  }) {
    return Navigator.of(context).push<LearningArticleModel>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ArticleDetailScreen(article: article, onCompleted: onCompleted),
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(opacity: curved, child: child),
          );
        },
      ),
    );
  }

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isCompleted = false;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.article.isCompleted;
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() => _scrollOffset = _scrollController.offset);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _markCompleted() {
    HapticFeedback.mediumImpact();
    final updated = widget.article.copyWith(isCompleted: true);
    setState(() => _isCompleted = true);
    widget.onCompleted?.call(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              '"${widget.article.title}" marked as completed!',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
      ),
    );

    // Pop and return updated model after a brief delay so snackbar shows
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) Navigator.of(context).pop(updated);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final article = widget.article;

    // App bar fades from transparent to surface as user scrolls
    final appBarOpacity = (_scrollOffset / 100).clamp(0.0, 1.0);
    final appBarBg = AppColors.surfaceOf(context).withValues(alpha: appBarOpacity);
    final textPrimary = AppColors.textPrimaryOf(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      extendBodyBehindAppBar: true,

      // ── Sticky App Bar ────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        leading: _BackButton(isDark: isDark),
        actions: [
          if (_isCompleted)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.successGreen,
                size: 22,
              ),
            ),
        ],
      ),

      // ── Body ─────────────────────────────────────────────────────────────────
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Banner
                _ArticleBanner(article: article, isDark: isDark),

                // 2. Padded article body
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2a. Meta row: duration + level
                      _MetaRow(article: article, isDark: isDark),
                      const SizedBox(height: 20),

                      // 2b. Summary paragraph
                      _SummaryBlock(
                        summary: article.summary,
                        textPrimary: textPrimary,
                        isDark: isDark,
                        article: article,
                      ),

                      if (article.keyTakeaways.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        _SectionHeader(label: 'Key Takeaways', textPrimary: textPrimary),
                        const SizedBox(height: 14),
                        _KeyTakeawaysList(
                          takeaways: article.keyTakeaways,
                          accentColor: article.imageColor,
                          isDark: isDark,
                        ),
                      ],

                      if (article.sections.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        _SectionHeader(label: 'Full Article', textPrimary: textPrimary),
                        const SizedBox(height: 6),
                        ...List.generate(article.sections.length, (i) {
                          final section = article.sections[i];
                          return _ArticleSectionBlock(
                            section: section,
                            index: i,
                            accentColor: article.imageColor,
                            textPrimary: textPrimary,
                            isDark: isDark,
                          );
                        }),
                      ],

                      if (article.actionSteps.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        _SectionHeader(label: 'Action Steps', textPrimary: textPrimary),
                        const SizedBox(height: 4),
                        _ActionStepsCaption(isDark: isDark),
                        const SizedBox(height: 14),
                        _ActionStepsList(
                          steps: article.actionSteps,
                          accentColor: article.imageColor,
                          isDark: isDark,
                          textPrimary: textPrimary,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Persistent bottom CTA bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomCTABar(
              isCompleted: _isCompleted,
              onTap: _isCompleted ? null : _markCompleted,
              accentColor: article.imageColor,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Sub-widgets (human-readable, single-responsibility components)
// ────────────────────────────────────────────────────────────────────────────

/// Circular back button that floats over the banner.
class _BackButton extends StatelessWidget {
  final bool isDark;
  const _BackButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 18,
            color: AppColors.textPrimaryOf(context),
          ),
        ),
      ),
    );
  }
}

/// Gradient header banner with hero icon, category pill, and title.
class _ArticleBanner extends StatelessWidget {
  final LearningArticleModel article;
  final bool isDark;

  const _ArticleBanner({required this.article, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final accentColor = article.imageColor;
    final bgColor = isDark
        ? accentColor.withValues(alpha: 0.18)
        : article.backgroundColor;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 60,
        bottom: 32,
        left: 22,
        right: 22,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        // Subtle gradient overlay
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accentColor.withValues(alpha: isDark ? 0.22 : 0.12),
            accentColor.withValues(alpha: isDark ? 0.08 : 0.04),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.25 : 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: accentColor.withValues(alpha: isDark ? 0.4 : 0.25),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(article.imageIcon, color: accentColor, size: 13),
                const SizedBox(width: 5),
                Text(
                  article.category.toUpperCase(),
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Article Title
          Text(
            article.title,
            style: TextStyle(
              color: AppColors.textPrimaryOf(context),
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.25,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Duration + difficulty level meta info row.
class _MetaRow extends StatelessWidget {
  final LearningArticleModel article;
  final bool isDark;

  const _MetaRow({required this.article, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final mutedColor = AppColors.textSecondaryOf(context);

    return Row(
      children: [
        _MetaChip(
          icon: Icons.access_time_rounded,
          label: '${article.duration} read',
          color: mutedColor,
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _MetaChip(
          icon: Icons.signal_cellular_alt_rounded,
          label: article.level,
          color: AppColors.primaryBlue,
          isDark: isDark,
          highlighted: true,
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final bool highlighted;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.primaryBlue.withValues(alpha: isDark ? 0.2 : 0.08)
            : AppColors.surfaceMutedOf(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlighted
              ? AppColors.primaryBlue.withValues(alpha: 0.25)
              : AppColors.borderOf(context),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lead summary paragraph inside a subtle accent container.
class _SummaryBlock extends StatelessWidget {
  final String summary;
  final Color textPrimary;
  final bool isDark;
  final LearningArticleModel article;

  const _SummaryBlock({
    required this.summary,
    required this.textPrimary,
    required this.isDark,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    if (summary.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: article.imageColor.withValues(alpha: isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: article.imageColor.withValues(alpha: isDark ? 0.25 : 0.15),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote_rounded, color: article.imageColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              summary,
              style: TextStyle(
                color: textPrimary,
                fontSize: 14.5,
                height: 1.6,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Styled section heading with decorative left accent bar.
class _SectionHeader extends StatelessWidget {
  final String label;
  final Color textPrimary;

  const _SectionHeader({required this.label, required this.textPrimary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: textPrimary,
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

/// Scrollable horizontal chip list of key takeaways.
class _KeyTakeawaysList extends StatelessWidget {
  final List<String> takeaways;
  final Color accentColor;
  final bool isDark;

  const _KeyTakeawaysList({
    required this.takeaways,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(takeaways.length, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.2 : 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 11,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  takeaways[i],
                  style: TextStyle(
                    color: AppColors.textPrimaryOf(context),
                    fontSize: 13.5,
                    height: 1.55,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// One article section: heading + divider + body paragraph.
class _ArticleSectionBlock extends StatelessWidget {
  final ArticleSection section;
  final int index;
  final Color accentColor;
  final Color textPrimary;
  final bool isDark;

  const _ArticleSectionBlock({
    required this.section,
    required this.index,
    required this.accentColor,
    required this.textPrimary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section heading with accent dot
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  section.heading,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Thin divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Body paragraph
          Text(
            section.body,
            style: TextStyle(
              color: AppColors.textSecondaryOf(context),
              fontSize: 14,
              height: 1.7,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionStepsCaption extends StatelessWidget {
  final bool isDark;
  const _ActionStepsCaption({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Apply these steps before your next money check-in:',
      style: TextStyle(
        color: AppColors.textSecondaryOf(context),
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

/// Numbered action steps with accent bubble index labels.
class _ActionStepsList extends StatelessWidget {
  final List<String> steps;
  final Color accentColor;
  final bool isDark;
  final Color textPrimary;

  const _ActionStepsList({
    required this.steps,
    required this.accentColor,
    required this.isDark,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(steps.length, (i) {
          final isLast = i == steps.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Numbered bubble
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        steps[i],
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 13.5,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 54,
                  color: AppColors.borderOf(context),
                ),
            ],
          );
        }),
      ),
    );
  }
}

/// Fixed bottom bar with the "Mark as Completed" CTA.
class _BottomCTABar extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback? onTap;
  final Color accentColor;
  final bool isDark;

  const _BottomCTABar({
    required this.isCompleted,
    required this.onTap,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        border: Border(
          top: BorderSide(color: AppColors.borderOf(context), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isCompleted
            ? _CompletedState(key: const ValueKey('completed'))
            : _CTAButton(
                key: const ValueKey('cta'),
                onTap: onTap,
                accentColor: accentColor,
              ),
      ),
    );
  }
}

class _CTAButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color accentColor;

  const _CTAButton({super.key, required this.onTap, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_outline_rounded, size: 18),
            SizedBox(width: 8),
            Text(
              'Mark as Completed',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedState extends StatelessWidget {
  const _CompletedState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.successGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.successGreen.withValues(alpha: 0.3),
        ),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 18),
          SizedBox(width: 8),
          Text(
            'Article Completed',
            style: TextStyle(
              color: AppColors.successGreen,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
