import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../components/home/home_header.dart';

/// Screen allowing students to submit ratings, feedback, and feature suggestions.
/// Features dynamic emoji-rating cards, feedback category selection,
/// quick suggestion tags, and early beta access opt-in.
class FeedbackScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const FeedbackScreen({super.key, this.onBack});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _selectedRating = 5;
  String _selectedCategory = 'UI & Design';
  final TextEditingController _feedbackController = TextEditingController();
  bool _joinBetaTesters = true;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'UI & Design',
    'Expense Tracker',
    'Budgets & Limits',
    'Savings Goals',
    'Penny AI',
    'Speed & Performance',
  ];

  final List<String> _quickTags = [
    'Super Clean UI',
    'Add PDF Statement Export',
    'More Currencies',
    'Dark Mode Polish',
    'Smart Receipts Scanner',
  ];

  final Map<int, Map<String, String>> _ratingData = {
    1: {'emoji': '😟', 'label': 'Needs Work'},
    2: {'emoji': '😐', 'label': 'Could Be Better'},
    3: {'emoji': '🙂', 'label': 'Good'},
    4: {'emoji': '😊', 'label': 'Great Experience'},
    5: {'emoji': '🤩', 'label': 'Loved It!'},
  };

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _appendTag(String tag) {
    if (_feedbackController.text.contains(tag)) return;
    setState(() {
      if (_feedbackController.text.trim().isEmpty) {
        _feedbackController.text = tag;
      } else {
        _feedbackController.text += ', $tag';
      }
    });
  }

  Future<void> _submitFeedback() async {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a few words to your feedback!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: const [
            Icon(Icons.favorite_rounded, color: AppColors.primaryPink, size: 28),
            SizedBox(width: 10),
            Text('Thank You!',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ],
        ),
        content: Text(
          'Your $_selectedRating-star feedback for "$_selectedCategory" has been delivered directly to the PennyPal product team. We build for students like you!',
          style: const TextStyle(
              fontSize: 13.5, color: AppColors.textSecondary, height: 1.45),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).maybePop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Back to App'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HomeHeader(
        title: 'App Feedback 💬',
        subtitle: 'Help us make PennyPal better',
        isBackNavigation: true,
        onMenuPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Rating Selector Card
              _buildRatingCard(),
              const SizedBox(height: 22),

              // 2. Feedback Category Chips
              const Text(
                'What are you reviewing?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _buildCategorySelector(),
              const SizedBox(height: 20),

              // 3. Quick Tag Recommendations
              const Text(
                'Quick Suggestion Tags (tap to add)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              _buildQuickTags(),
              const SizedBox(height: 18),

              // 4. Feedback Input Text Area
              const Text(
                'Your Thoughts & Ideas',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _buildCommentBox(),
              const SizedBox(height: 16),

              // 5. Beta Access Toggle
              _buildBetaTesterTile(),
              const SizedBox(height: 24),

              // 6. Submit Button
              _buildSubmitButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingCard() {
    final current = _ratingData[_selectedRating]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            current['emoji']!,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 8),
          Text(
            current['label']!,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final star = index + 1;
              final isLit = star <= _selectedRating;
              return GestureDetector(
                onTap: () => setState(() => _selectedRating = star),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Icon(
                    isLit ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isLit ? const Color(0xFFFFB703) : AppColors.border,
                    size: 38,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((c) {
        final isSelected = _selectedCategory == c;
        return ChoiceChip(
          label: Text(c),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) setState(() => _selectedCategory = c);
          },
          selectedColor: AppColors.primaryPink,
          backgroundColor: AppColors.surface,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? AppColors.primaryPink : AppColors.border,
            ),
          ),
          showCheckmark: false,
        );
      }).toList(),
    );
  }

  Widget _buildQuickTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _quickTags.map((tag) {
        return ActionChip(
          label: Text('+ $tag'),
          backgroundColor: AppColors.background,
          labelStyle: const TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
          ),
          onPressed: () => _appendTag(tag),
        );
      }).toList(),
    );
  }

  Widget _buildCommentBox() {
    return TextField(
      controller: _feedbackController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Tell us what you love or what we should add next...',
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primaryPink, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildBetaTesterTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.purpleLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.science_outlined,
                color: AppColors.purple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Join PennyPal Beta Club',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Try new experimental features first',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _joinBetaTesters,
            activeThumbColor: AppColors.purple,
            activeTrackColor: AppColors.purpleLight,
            onChanged: (val) => setState(() => _joinBetaTesters = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitFeedback,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPink,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.2, color: Colors.white),
              )
            : const Text(
                'Submit Feedback',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }
}
