import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../components/home/home_header.dart';
import 'contact_us_screen.dart';

/// Screen offering comprehensive Help & Support for students using PennyPal.
/// Includes real-time FAQ search, quick assistance shortcuts,
/// interactive expandable Q&A cards with helpfulness feedback, and direct contact routing.
class HelpSupportScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const HelpSupportScreen({super.key, this.onBack});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<int> _helpfulMarked = {};

  final List<Map<String, String>> _faqs = [
    {
      'q': 'How do I set up a Category Budget limit?',
      'a':
          'Open the app, tap the central "+" button in the bottom navigation bar, and select "Set Category Budget". Pick your category (e.g., Food & Dining or Transport), specify your monthly cap in Rupees, and save! PennyPal will visually track your consumption with color-coded alerts.',
      'category': 'Budgets',
    },
    {
      'q': 'Is my financial data stored securely and privately?',
      'a':
          'Yes, 100%! PennyPal is engineered with a strict local-first architecture. All transaction amounts, categories, and savings records stay right on your device storage. We never upload or monetize your financial behavior.',
      'category': 'Privacy',
    },
    {
      'q': 'How does a Savings Goal compute my monthly target?',
      'a':
          'When you create a goal (e.g. New Laptop for Rs. 50,000 by December), PennyPal counts the months remaining and automatically calculates your recommended monthly contribution to reach your milestone without stress.',
      'category': 'Goals',
    },
    {
      'q': 'Can I edit or delete past transactions?',
      'a':
          'Yes. Navigate to the "Expenses" tab from the bottom navigation bar, tap on any transaction tile to open its detail sheet, and you will find instant options to modify notes or delete the entry.',
      'category': 'Expenses',
    },
    {
      'q': 'How does the central "+" button work?',
      'a':
          'The central floating action button is your universal quick-launcher. Tapping it lets you record an Expense, add an Income entry, set a Savings Goal, or configure a Budget limit in seconds.',
      'category': 'Navigation',
    },
    {
      'q': 'Can I change app language or theme?',
      'a':
          'Go to Settings (accessible from the side drawer). You can toggle Dark Mode on/off, switch application languages (English, Urdu, Arabic, Spanish, French), or customize notifications.',
      'category': 'Settings',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredFaqs {
    if (_searchQuery.trim().isEmpty) return _faqs;
    final q = _searchQuery.toLowerCase();
    return _faqs.where((faq) {
      return faq['q']!.toLowerCase().contains(q) ||
          faq['a']!.toLowerCase().contains(q) ||
          faq['category']!.toLowerCase().contains(q);
    }).toList();
  }

  void _openContact() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ContactUsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredFaqs;

    return Scaffold(
      backgroundColor: AppColors.backgroundOf(context),
      appBar: HomeHeader(
        title: 'Help & Support 🛟',
        subtitle: 'FAQs, guides & instant answers',
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
              // 1. Live FAQ Search Bar
              _buildSearchBar(),
              const SizedBox(height: 20),

              // 2. Quick Support Tiles
              _buildQuickAssistanceRow(),
              const SizedBox(height: 26),

              // 3. FAQs Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryOf(context),
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    '${filtered.length} FAQs',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 4. Expandable FAQ Cards
              if (filtered.isEmpty) ...[
                _buildEmptyFaqState(),
              ] else ...[
                ...List.generate(filtered.length, (index) {
                  return _buildFaqTile(index, filtered[index]);
                }),
              ],

              const SizedBox(height: 24),

              // 5. Still Need Help Banner
              _buildStillNeedHelpCard(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: TextStyle(
          color: AppColors.textPrimaryOf(context),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Search help by question, keyword...',
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          prefixIcon:
              const Icon(Icons.search_rounded, color: AppColors.textMuted),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: AppColors.textMuted, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildQuickAssistanceRow() {
    return Row(
      children: [
        _quickTile(
          icon: Icons.chat_bubble_outline_rounded,
          color: AppColors.primaryPink,
          bg: AppColors.primaryPinkLight,
          label: 'Contact Us',
          onTap: _openContact,
        ),
        const SizedBox(width: 10),
        _quickTile(
          icon: Icons.school_outlined,
          color: AppColors.primaryBlue,
          bg: AppColors.primaryBlueLight,
          label: 'Quick Guide',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Tip: Use the "+" FAB button on the bottom bar for all entries!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        const SizedBox(width: 10),
        _quickTile(
          icon: Icons.auto_awesome_rounded,
          color: AppColors.purple,
          bg: AppColors.purpleLight,
          label: 'Ask Penny',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Penny AI assistant available in the main drawer!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _quickTile({
    required IconData icon,
    required Color color,
    required Color bg,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderOf(context)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryOf(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqTile(int index, Map<String, String> faq) {
    final isMarked = _helpfulMarked.contains(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryBlueLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                '?',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          title: Text(
            faq['q']!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryOf(context),
            ),
          ),
          children: [
            Text(
              faq['a']!,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryOf(context),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  isMarked ? 'Thank you! 👍' : 'Was this helpful?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isMarked ? FontWeight.w700 : FontWeight.w500,
                    color: isMarked
                        ? AppColors.successGreen
                        : AppColors.textMuted,
                  ),
                ),
                if (!isMarked) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      setState(() => _helpfulMarked.add(index));
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.thumb_up_alt_outlined,
                          size: 16, color: AppColors.primaryBlue),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFaqState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded,
              size: 40, color: AppColors.textSecondaryOf(context)),
          const SizedBox(height: 10),
          Text('No matching questions found',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryOf(context))),
          const SizedBox(height: 4),
          Text('Try searching with different terms or contact support directly.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 12.5, color: AppColors.textSecondaryOf(context))),
        ],
      ),
    );
  }

  Widget _buildStillNeedHelpCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.headset_mic_rounded,
                  color: AppColors.primaryPink, size: 24),
              const SizedBox(width: 10),
              Text(
                'Still need assistance?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryOf(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Can’t find the answer to your budgeting problem? Our student desk is ready to help 24/7.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryOf(context),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _openContact,
              icon: const Icon(Icons.mail_outline_rounded, size: 18),
              label: const Text('Contact Support Team',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
