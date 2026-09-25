import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../components/home/home_header.dart';

/// Screen allowing users to reach out to the PennyPal support & developer team.
/// Features quick contact cards with tap-to-copy, direct email compose,
/// campus office hours, and an interactive message inquiry form.
class ContactUsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ContactUsScreen({super.key, this.onBack});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _selectedCategory = 'General Inquiry';
  bool _isSending = false;

  final List<String> _categories = [
    'General Inquiry',
    'Feature Suggestion',
    'Bug Report',
    'Budget / Calculation Issue',
    'Student Plan Assistance',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _isSending = false);

    _nameController.clear();
    _emailController.clear();
    _messageController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded,
                color: AppColors.successGreen, size: 26),
            SizedBox(width: 10),
            Text('Message Sent!',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ],
        ),
        content: const Text(
          'Thank you for reaching out! Our student support team will respond to your email within 2-4 hours.',
          style: TextStyle(
              fontSize: 13.5, color: AppColors.textSecondary, height: 1.45),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Great'),
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
        title: 'Contact Us 📬',
        subtitle: 'We are here to help anytime',
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
              // 1. Reach Channels Row
              _buildChannelTile(
                icon: Icons.alternate_email_rounded,
                color: AppColors.primaryPink,
                bgColor: AppColors.primaryPinkLight,
                title: 'Email Support',
                value: 'support@pennypal.app',
                subtitle: 'Guaranteed 2-4h response time',
                onTap: () =>
                    _copyToClipboard('support@pennypal.app', 'Email address'),
              ),
              const SizedBox(height: 10),
              _buildChannelTile(
                icon: Icons.chat_bubble_outline_rounded,
                color: AppColors.successGreen,
                bgColor: AppColors.successGreenLight,
                title: 'WhatsApp Student Desk',
                value: '+92 300 1234567',
                subtitle: 'Mon - Sat: 9:00 AM - 9:00 PM',
                onTap: () => _copyToClipboard('+923001234567', 'Helpline number'),
              ),
              const SizedBox(height: 10),
              _buildChannelTile(
                icon: Icons.business_outlined,
                color: AppColors.primaryBlue,
                bgColor: AppColors.primaryBlueLight,
                title: 'Campus Headquarters',
                value: 'Technology Park, University Ave',
                subtitle: 'Karachi & Lahore Labs, Pakistan',
                onTap: () => _copyToClipboard(
                    'Technology Park, University Ave, Karachi', 'Office address'),
              ),
              const SizedBox(height: 26),

              // 2. Interactive Inquiry Form Header
              const Text(
                'Send Us a Direct Message',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Have a feature request, question, or need budget advice? Write to us below.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),

              // 3. Message Form
              _buildForm(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChannelTile({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String value,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(value,
                        style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMuted)),
                  ],
                ),
              ),
              const Icon(Icons.copy_rounded,
                  size: 16, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            _label('Your Name'),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration(
                hint: 'e.g. Mohd Jaffari',
                prefixIcon: Icons.person_outline_rounded,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 14),

            // Email Field
            _label('Email Address'),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration(
                hint: 'name@university.edu',
                prefixIcon: Icons.email_outlined,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Subject / Category Dropdown
            _label('Inquiry Subject'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary),
                  items: _categories.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(c,
                          style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Message Body
            _label('Your Message'),
            TextFormField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe how we can help you...',
                hintStyle:
                    const TextStyle(color: AppColors.textMuted, fontSize: 13),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppColors.primaryPink, width: 1.5),
                ),
              ),
              validator: (v) => (v == null || v.trim().length < 10)
                  ? 'Message should be at least 10 characters'
                  : null,
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.2, color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.send_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Send Inquiry',
                              style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary, size: 18),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryPink, width: 1.5),
      ),
    );
  }
}
