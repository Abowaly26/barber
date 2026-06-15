// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:app/features/quti_shared/quti_shared.dart';
import 'package:app/features/booking_type/presentation/views/booking_type_view.dart';

// ==========================================
// 1. AI ADVISOR INTRO
// ==========================================
class AIAdvisorIntroScreen extends StatelessWidget {
  const AIAdvisorIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF5A9A9C), Color(0xFF438587)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'AI-Powered',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AI Hair Advisor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Not sure which haircut suits you best? Upload a photo, tell us your preferences, and let our AI recommend the perfect style — personalized just for you.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // How It Works
            const Text(
              'How It Works',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildStepRow(Icons.camera_alt_outlined, 'Upload a front-facing photo'),
            const SizedBox(height: 12),
            _buildStepRow(Icons.tune, 'Select your style preferences'),
            const SizedBox(height: 12),
            _buildStepRow(Icons.auto_awesome_outlined, 'Get AI-powered recommendations'),
            const SizedBox(height: 28),

            // Feature Cards
            _buildFeatureCard(
              Icons.face,
              'Personalized Match',
              'Tailored to your face shape & style',
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              Icons.flash_on,
              'Instant Results',
              'Get recommendations in seconds',
            ),
            const SizedBox(height: 12),
            _buildFeatureCard(
              Icons.lock_outline,
              'Private & Secure',
              'Your photo is only used for analysis',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AIAdvisorUploadScreen()),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Start Analysis',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, height: 1.3),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. UPLOAD PHOTO
// ==========================================
class AIAdvisorUploadScreen extends StatefulWidget {
  const AIAdvisorUploadScreen({super.key});

  @override
  State<AIAdvisorUploadScreen> createState() => _AIAdvisorUploadScreenState();
}

class _AIAdvisorUploadScreenState extends State<AIAdvisorUploadScreen> {
  bool _isUploaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Upload Photo'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isUploaded = !_isUploaded; // Toggle upload state for demo
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: _isUploaded
                      ? AppColors.primaryLight.withOpacity(0.5)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isUploaded
                        ? AppColors.primary
                        : AppColors.borderGrey,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isUploaded) ...[
                      const Icon(
                        Icons.camera_alt_outlined,
                        color: AppColors.textGrey,
                        size: 32,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Add Your Photo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Upload a clear, front-facing photo',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 13,
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Photo Uploaded',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap to change photo',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.image_outlined,
                      size: 18,
                      color: AppColors.textDark,
                    ),
                    label: const Text(
                      'Gallery',
                      style: TextStyle(color: AppColors.textDark),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.borderGrey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      size: 18,
                      color: AppColors.textDark,
                    ),
                    label: const Text(
                      'Camera',
                      style: TextStyle(color: AppColors.textDark),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.borderGrey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Photo Tips',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildTipRow(
                    Icons.visibility_outlined,
                    'Face clearly visible',
                  ),
                  _buildTipRow(Icons.light_mode_outlined, 'Good lighting'),
                  _buildTipRow(Icons.person_outline, 'Front-facing angle'),
                  _buildTipRow(
                    Icons.do_not_disturb_alt,
                    'No heavy filters',
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline, size: 16, color: Colors.amber),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your photo is private and only used for style analysis. It is not stored or shared with anyone.',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isUploaded
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AIAdvisorPreferencesScreen(),
                    ),
                  )
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isUploaded
                  ? AppColors.primary
                  : AppColors.borderGrey,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipRow(IconData icon, String text, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 16),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

// ==========================================
// 3. YOUR PREFERENCES
// ==========================================
class AIAdvisorPreferencesScreen extends StatefulWidget {
  const AIAdvisorPreferencesScreen({super.key});

  @override
  State<AIAdvisorPreferencesScreen> createState() =>
      _AIAdvisorPreferencesScreenState();
}

class _AIAdvisorPreferencesScreenState
    extends State<AIAdvisorPreferencesScreen> {
  String _stylePref = 'Modern';
  String _lengthTarget = 'Short';
  String _fadePref = 'Low Fade';
  String _beardPref = 'Light Beard';
  String _maintenance = 'Medium';
  String _occasion = 'Daily';
  String _confidence = 'Balanced';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Your Preferences'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Help us understand your style. Select your preferences below and we\'ll find the best match.',
              style: TextStyle(color: AppColors.textGrey, height: 1.5),
            ),
            const SizedBox(height: 32),
            _buildPreferenceSection(
              'Style Preference',
              ['Classic', 'Modern', 'Bold', 'Minimal', 'Premium'],
              _stylePref,
              (v) => setState(() => _stylePref = v),
            ),
            _buildPreferenceSection(
              'Hair Length Target',
              ['Very Short', 'Short', 'Medium'],
              _lengthTarget,
              (v) => setState(() => _lengthTarget = v),
            ),
            _buildPreferenceSection(
              'Fade Preference',
              ['No Fade', 'Low Fade', 'Mid Fade', 'High Fade'],
              _fadePref,
              (v) => setState(() => _fadePref = v),
            ),
            _buildPreferenceSection(
              'Beard Preference',
              ['Clean Shave', 'Light Beard', 'Full Beard'],
              _beardPref,
              (v) => setState(() => _beardPref = v),
            ),
            _buildPreferenceSection(
              'Maintenance Level',
              ['Low', 'Medium', 'High'],
              _maintenance,
              (v) => setState(() => _maintenance = v),
            ),
            _buildPreferenceSection(
              'Occasion',
              ['Daily', 'Work', 'Event', 'Wedding', 'Photoshoot'],
              _occasion,
              (v) => setState(() => _occasion = v),
            ),
            _buildPreferenceSection(
              'Confidence Level',
              ['Safe', 'Balanced', 'Bold'],
              _confidence,
              (v) => setState(() => _confidence = v),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AIAdvisorLoadingScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: 18),
                SizedBox(width: 8),
                Text(
                  'Analyze My Look',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceSection(
    String title,
    List<String> options,
    String selectedValue,
    Function(String) onSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: options.map((option) {
              final isSelected = option == selectedValue;
              return GestureDetector(
                onTap: () => onSelected(option),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.borderGrey,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textDark,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. ANALYZING YOUR LOOK (LOADING SCREEN)
// ==========================================
class AIAdvisorLoadingScreen extends StatefulWidget {
  const AIAdvisorLoadingScreen({super.key});

  @override
  State<AIAdvisorLoadingScreen> createState() => _AIAdvisorLoadingScreenState();
}

class _AIAdvisorLoadingScreenState extends State<AIAdvisorLoadingScreen> {
  String _statusText = 'Analyzing face shape...';

  @override
  void initState() {
    super.initState();
    _startMockAnalysis();
  }

  void _startMockAnalysis() async {
    // Simulate analyzing process
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _statusText = 'Analyzing hair texture...');
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _statusText = 'Finding best styles...');
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AIAdvisorRecommendationsScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Analyzing Your Look',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Our AI is finding the best styles for you.',
              style: TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.borderGrey,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _statusText,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 5. YOUR RECOMMENDATIONS
// ==========================================
class AIAdvisorRecommendationsScreen extends StatelessWidget {
  const AIAdvisorRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Your Recommendations'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
                SizedBox(width: 8),
                Text(
                  'AI Analysis Complete',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Based on your face shape, hair texture, and preferences, here are your top recommendations.',
              style: TextStyle(
                color: AppColors.textGrey,
                height: 1.5,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            _buildRecCard(
              context,
              title: 'Modern Textured Crop',
              badge: 'Best Match',
              badgeColor: AppColors.primary,
              desc:
                  'A clean, textured crop with a low fade that balances modern style with easy maintenance.',
              tags: ['Face Shape Match', 'Easy Maintenance', 'Trend-Forward'],
              onDetails: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AIAdvisorDetailScreen(
                    title: 'Modern Textured Crop',
                    badge: 'Best Match',
                    badgeColor: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildRecCard(
              context,
              title: 'Classic Side Part',
              badge: 'Safe Choice',
              badgeColor: Colors.blueGrey,
              desc:
                  'A timeless side part with clean lines — versatile for professional and social settings.',
              tags: ['Face Shape Match', 'Versatile', 'Works With Beard'],
              onDetails: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AIAdvisorDetailScreen(
                    title: 'Classic Side Part',
                    badge: 'Safe Choice',
                    badgeColor: Colors.blueGrey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildRecCard(
              context,
              title: 'High Fade Pompadour',
              badge: 'Bold Option',
              badgeColor: Colors.orange,
              desc:
                  'A statement pompadour with a sharp high fade — confident, polished, and head-turning.',
              tags: ['Trend-Forward', 'Statement Look', 'Event Ready'],
              onDetails: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AIAdvisorDetailScreen(
                    title: 'High Fade Pompadour',
                    badge: 'Bold Option',
                    badgeColor: Colors.orange,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: const BorderSide(color: AppColors.borderGrey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRecCard(
    BuildContext context, {
    required String title,
    required String badge,
    required Color badgeColor,
    required String desc,
    required List<String> tags,
    required VoidCallback onDetails,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderGrey),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(19),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey.shade200, Colors.grey.shade400],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(Icons.bookmark_border, color: Colors.white),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  desc,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags
                      .map(
                        (t) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            t,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'View Details →',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BookingTypeScreen(),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Book This Style',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 6. RECOMMENDATION DETAILS
// ==========================================
class AIAdvisorDetailScreen extends StatelessWidget {
  final String title;
  final String badge;
  final Color badgeColor;

  const AIAdvisorDetailScreen({
    super.key,
    required this.title,
    required this.badge,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey.shade100, Colors.grey.shade400],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionBtn(Icons.bookmark_border, 'Save'),
                  _buildActionBtn(Icons.share_outlined, 'Share'),
                  _buildActionBtn(Icons.content_cut, 'Show To Barber'),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Why It Suits You',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Your face shape pairs well with the volume on top, creating a balanced and structured look. The textured layers add dimension without requiring heavy styling.',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        height: 1.5,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag('Face Shape Match'),
                      _buildTag('Easy Maintenance'),
                      _buildTag('Trend-Forward'),
                    ],
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Style Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailSection(
                    'Face Shape',
                    'Oval to square — the volume on top adds length while the fade keeps the sides clean.',
                  ),
                  _buildDetailSection(
                    'Hair Type',
                    'Works best with straight to slightly wavy hair. Medium density recommended.',
                  ),
                  _buildDetailSection(
                    'Maintenance',
                    'Low to medium — a quick style with matte clay or texture paste each morning.',
                  ),
                  _buildDetailSection(
                    'Beard Compatibility',
                    'Pairs well with a light stubble or clean-shaven look. A full beard can work but keep it well-groomed.',
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Barber Instructions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderGrey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.content_cut,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ask for a scissor-cut top with 1-2 inches of length. Request a low skin fade on the sides, blending into the natural hairline.',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              height: 1.5,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'View All Recommendations',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: PrimaryBottomButton(
        text: 'Book This Look',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookingTypeScreen()),
        ),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.primary, fontSize: 11),
      ),
    );
  }

  Widget _buildDetailSection(String title, String desc) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderGrey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
