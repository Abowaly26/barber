// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:app/features/ai_flow/data/ai_hairstyle_service.dart';
import 'package:app/features/quti_shared/quti_shared.dart';
import 'package:app/features/booking_type/presentation/views/booking_type_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

const int _defaultRecommendationCount = 8;

class HairRecommendation {
  final String title;
  final String badge;
  final Color badgeColor;
  final String desc;
  final List<String> tags;
  final List<Color> previewColors;
  final String? imageUrl;

  const HairRecommendation({
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.desc,
    required this.tags,
    required this.previewColors,
    this.imageUrl,
  });

  HairRecommendation withImageUrl(String? imageUrl) {
    return HairRecommendation(
      title: title,
      badge: badge,
      badgeColor: badgeColor,
      desc: desc,
      tags: tags,
      previewColors: previewColors,
      imageUrl: imageUrl,
    );
  }
}

const List<HairRecommendation> _mockHairRecommendations = [
  HairRecommendation(
    title: 'Modern Textured Crop',
    badge: 'Best Match',
    badgeColor: AppColors.primary,
    desc:
        'A clean textured crop with a low fade that balances modern style with easy maintenance.',
    tags: ['Low Fade', 'Easy Maintenance', 'Modern'],
    previewColors: [Color(0xFFDEE9EA), Color(0xFF5A9A9C)],
  ),
  HairRecommendation(
    title: 'Classic Side Part',
    badge: 'Safe Choice',
    badgeColor: Colors.blueGrey,
    desc:
        'A timeless side part with clean lines, suitable for professional and daily looks.',
    tags: ['Classic', 'Work Ready', 'Neat'],
    previewColors: [Color(0xFFE8EEF2), Color(0xFF607D8B)],
  ),
  HairRecommendation(
    title: 'High Fade Pompadour',
    badge: 'Bold Option',
    badgeColor: Colors.orange,
    desc:
        'A sharp high fade with volume on top for a confident, polished, statement look.',
    tags: ['High Fade', 'Volume', 'Event Ready'],
    previewColors: [Color(0xFFFFE0B2), Color(0xFFFF9800)],
  ),
  HairRecommendation(
    title: 'Low Taper Fade',
    badge: 'Barber Favorite',
    badgeColor: Color(0xFF6D8F72),
    desc:
        'A subtle taper that keeps the sides clean while preserving a natural, flexible shape.',
    tags: ['Low Taper', 'Natural', 'Flexible'],
    previewColors: [Color(0xFFEAF3EA), Color(0xFF6D8F72)],
  ),
  HairRecommendation(
    title: 'Curly Top Fade',
    badge: 'Texture Match',
    badgeColor: Color(0xFF8E6BBE),
    desc:
        'Keeps curl texture visible on top with faded sides for shape and easier styling.',
    tags: ['Curly', 'Mid Fade', 'Texture'],
    previewColors: [Color(0xFFEDE7F6), Color(0xFF8E6BBE)],
  ),
  HairRecommendation(
    title: 'Buzz Cut Fade',
    badge: 'Low Effort',
    badgeColor: Color(0xFF455A64),
    desc:
        'A clean buzz with faded sides for a sharp look that needs almost no daily styling.',
    tags: ['Very Short', 'Clean', 'Low Maintenance'],
    previewColors: [Color(0xFFECEFF1), Color(0xFF455A64)],
  ),
  HairRecommendation(
    title: 'French Crop',
    badge: 'Modern',
    badgeColor: Color(0xFFC16B54),
    desc:
        'Short fringe and textured top with clean sides, ideal for a modern everyday cut.',
    tags: ['Short Fringe', 'Modern', 'Daily'],
    previewColors: [Color(0xFFFFECE6), Color(0xFFC16B54)],
  ),
  HairRecommendation(
    title: 'Slick Back Undercut',
    badge: 'Premium',
    badgeColor: Color(0xFF2F6F73),
    desc:
        'A polished slick back with strong side contrast, best for a premium groomed style.',
    tags: ['Undercut', 'Premium', 'Polished'],
    previewColors: [Color(0xFFDDEEEF), Color(0xFF2F6F73)],
  ),
];

List<HairRecommendation> _recommendationsFor(
  int count, {
  List<String> imageUrls = const [],
}) {
  final base = _mockHairRecommendations.take(count).toList(growable: false);

  return List<HairRecommendation>.generate(base.length, (index) {
    final imageUrl = index < imageUrls.length ? imageUrls[index] : null;
    return base[index].withImageUrl(imageUrl);
  }, growable: false);
}

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
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
                    'Upload your photo and get AI hairstyle options on your own face so you can choose what to send to your barber.',
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
            _buildStepRow(
              Icons.camera_alt_outlined,
              'Upload a front-facing photo',
            ),
            const SizedBox(height: 12),
            _buildStepRow(
              Icons.auto_awesome_outlined,
              'Generate 8 hairstyle options',
            ),
            const SizedBox(height: 12),
            _buildStepRow(
              Icons.content_cut,
              'Choose a look and show it to your barber',
            ),
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
              'Generate 8 looks after upload',
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
          child: Text(text, style: const TextStyle(fontSize: 14, height: 1.3)),
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
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedPhoto;
  bool _isPickingPhoto = false;

  bool get _isUploaded => _selectedPhoto != null;

  Future<void> _pickPhoto(ImageSource source) async {
    if (_isPickingPhoto) return;

    setState(() => _isPickingPhoto = true);

    try {
      final photo = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1400,
        imageQuality: 88,
      );

      if (!mounted || photo == null) return;

      // Crop the image
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: photo.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'تعديل الصورة',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
            showCropGrid: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
          IOSUiSettings(
            title: 'تعديل الصورة',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio4x3,
            ],
            aspectRatioLockEnabled: false,
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
            resetButtonHidden: false,
          ),
        ],
      );

      if (!mounted) return;

      if (croppedFile != null) {
        setState(() => _selectedPhoto = XFile(croppedFile.path));
      } else {
        // Use original if cropping was cancelled
        setState(() => _selectedPhoto = photo);
      }
    } on PlatformException catch (e) {
      if (!mounted || e.code == 'already_active') return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open image picker: ${e.message}')),
      );
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

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
              onTap: _isPickingPhoto
                  ? null
                  : () => _pickPhoto(ImageSource.gallery),
              child: Container(
                width: double.infinity,
                height: _isUploaded ? 280 : null,
                padding: EdgeInsets.symmetric(vertical: _isUploaded ? 0 : 40),
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
                child: _isUploaded
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(_selectedPhoto!.path),
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Photo selected. Tap to change it.',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: AppColors.textGrey,
                            size: 32,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Add Your Photo',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Upload a clear, front-facing photo',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isPickingPhoto
                        ? null
                        : () => _pickPhoto(ImageSource.gallery),
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
                    onPressed: _isPickingPhoto
                        ? null
                        : () => _pickPhoto(ImageSource.camera),
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
                      builder: (_) => AIAdvisorLoadingScreen(
                        photoPath: _selectedPhoto!.path,
                        preferences: const {},
                        recommendationCount: _defaultRecommendationCount,
                      ),
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
  final String photoPath;

  const AIAdvisorPreferencesScreen({super.key, required this.photoPath});

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
  int _recommendationCount = _defaultRecommendationCount;

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
            _buildCountSection(),
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
              MaterialPageRoute(
                builder: (_) => AIAdvisorLoadingScreen(
                  photoPath: widget.photoPath,
                  preferences: {
                    'stylePreference': _stylePref,
                    'hairLengthTarget': _lengthTarget,
                    'fadePreference': _fadePref,
                    'beardPreference': _beardPref,
                    'maintenanceLevel': _maintenance,
                    'occasion': _occasion,
                    'confidenceLevel': _confidence,
                  },
                  recommendationCount: _recommendationCount,
                ),
              ),
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

  Widget _buildCountSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Number of AI Looks',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start with 6 or 8 images to keep generation fast and affordable.',
            style: TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCountChip(6),
              const SizedBox(width: 10),
              _buildCountChip(8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountChip(int count) {
    final isSelected = count == _recommendationCount;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _recommendationCount = count),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderGrey,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$count looks',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. ANALYZING YOUR LOOK (LOADING SCREEN)
// ==========================================
class AIAdvisorLoadingScreen extends StatefulWidget {
  final String photoPath;
  final Map<String, String> preferences;
  final int recommendationCount;

  const AIAdvisorLoadingScreen({
    super.key,
    required this.photoPath,
    required this.preferences,
    this.recommendationCount = _defaultRecommendationCount,
  });

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
    // Replace this mock delay with your backend call:
    // POST /api/ai/hairstyles { imageUrl, preferences, count }.
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _statusText = 'Analyzing hair texture...');
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(
        () => _statusText =
            'Generating ${widget.recommendationCount} hairstyle previews...',
      );
    }

    List<String> imageUrls = const [];
    try {
      imageUrls = await AIHairstyleService().generateHairstyles(
        AIHairstyleGenerationRequest(
          photoPath: widget.photoPath,
          preferences: widget.preferences,
          count: widget.recommendationCount,
        ),
      );
    } catch (error, stackTrace) {
      developer.log(
        'AI hairstyle generation failed: $error',
        name: 'AIAdvisorLoadingScreen',
        stackTrace: stackTrace,
      );
      imageUrls = const [];
    }

    if (imageUrls.isEmpty) {
      await Future.delayed(const Duration(seconds: 1));
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AIAdvisorRecommendationsScreen(
            recommendationCount: widget.recommendationCount,
            recommendations: _recommendationsFor(
              widget.recommendationCount,
              imageUrls: imageUrls,
            ),
          ),
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
  final int recommendationCount;
  final List<HairRecommendation>? recommendations;

  const AIAdvisorRecommendationsScreen({
    super.key,
    this.recommendationCount = _defaultRecommendationCount,
    this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    final recommendations =
        this.recommendations ?? _recommendationsFor(recommendationCount);
    final hasGeneratedImages = recommendations.any(
      (recommendation) => recommendation.imageUrl != null,
    );

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
            Text(
              'Based on your face shape, hair texture, and preferences, here are $recommendationCount AI hairstyle options.',
              style: TextStyle(
                color: AppColors.textGrey,
                height: 1.5,
                fontSize: 13,
              ),
            ),
            if (!hasGeneratedImages) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.amber.withOpacity(0.35)),
                ),
                child: const Text(
                  'AI images are not available yet. Showing style placeholders until Supabase and the AI provider return image URLs.',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ...recommendations.map(
              (recommendation) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildRecCard(
                  context,
                  recommendation: recommendation,
                  onDetails: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AIAdvisorDetailScreen(
                        title: recommendation.title,
                        badge: recommendation.badge,
                        badgeColor: recommendation.badgeColor,
                        previewColors: recommendation.previewColors,
                        imageUrl: recommendation.imageUrl,
                      ),
                    ),
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
    required HairRecommendation recommendation,
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
                colors: recommendation.previewColors,
              ),
              image: recommendation.imageUrl == null
                  ? null
                  : DecorationImage(
                      image: NetworkImage(recommendation.imageUrl!),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.25),
                        BlendMode.darken,
                      ),
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
                      color: recommendation.badgeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      recommendation.badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Text(
                    recommendation.title,
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
                  recommendation.desc,
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
                  children: recommendation.tags
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
  final List<Color> previewColors;
  final String? imageUrl;

  const AIAdvisorDetailScreen({
    super.key,
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.previewColors,
    this.imageUrl,
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
                  colors: previewColors,
                ),
                image: imageUrl == null
                    ? null
                    : DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.25),
                          BlendMode.darken,
                        ),
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
