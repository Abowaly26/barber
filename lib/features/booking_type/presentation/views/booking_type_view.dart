// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:app/features/quti_shared/quti_shared.dart';
import 'package:app/features/mens_flow/presentation/views/mens_flow_view.dart';
import 'package:app/features/womens_flow/presentation/views/womens_flow_view.dart';
import 'package:app/features/ai_flow/presentation/views/ai_flow_view.dart';
import 'package:app/features/store_flow/presentation/views/store_flow_view.dart';
import 'package:app/features/provider_flow/presentation/views/provider_flow_view.dart';

// --- Screen: Who are you booking for? ---
class UserSelectionScreen extends StatelessWidget {
  static const String routeName = '/user-selection';

  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose your experience',
                style: TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
              const SizedBox(height: 8),
              const Text(
                'Who are you booking for?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 32),
              _buildMainCard(
                context,
                title: 'Men',
                subtitle: 'Barbershops & Grooming',
                icon: '💈',
                color: Colors.grey.shade400,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingTypeScreen()),
                ),
              ),
              const SizedBox(height: 16),
              _buildMainCard(
                context,
                title: 'Women',
                subtitle: 'Salons & Beauty',
                icon: '💅',
                color: Colors.grey.shade300,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BeautyHomeScreen()),
                ),
              ),
              const SizedBox(height: 16),
              _buildMainCard(
                context,
                title: 'Kids',
                subtitle: 'Fun & Friendly Cuts',
                icon: '👦',
                color: Colors.grey.shade200,
                textColor: AppColors.textDark,
                onTap: () {},
              ),
              const SizedBox(height: 32),
              _buildActionTile(
                icon: Icons.shopping_bag_outlined,
                iconColor: Colors.pinkAccent,
                title: 'QUTI Store',
                subtitle: 'Shop grooming products',
                bgColor: AppColors.background,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StoreHomeScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                icon: Icons.content_cut,
                iconColor: Colors.redAccent,
                title: 'Join as Provider',
                subtitle: 'Barbers & shop owners',
                bgColor: const Color(0xFFFDF0F5),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProviderJoinScreen()),
                ),
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                icon: Icons.auto_awesome,
                iconColor: AppColors.primary,
                title: 'AI Hair Advisor',
                subtitle: 'Find your perfect style',
                bgColor: AppColors.primaryLight,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AIAdvisorIntroScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
    Color textColor = Colors.white,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey),
        ),
      ),
    );
  }
}

// --- Screen: Booking Type ---
class BookingTypeScreen extends StatelessWidget {
  static const String routeName = '/booking-type';

  const BookingTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Booking Type'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'How would you like\nyour service?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Choose where you want to get your service',
              style: TextStyle(color: AppColors.textGrey),
            ),
            const SizedBox(height: 40),
            _buildTypeCard(
              title: 'Visit a Shop',
              subtitle: 'Book a service at a barbershop or salon near you',
              icon: Icons.storefront,
              isSelected: false,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomeServiceScreen()),
              ),
              child: _buildTypeCard(
                title: 'Home Service',
                subtitle: 'Get a specialist to come to your location',
                icon: Icons.home_filled,
                isSelected: false,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AIAdvisorIntroScreen()),
              ),
              child: _buildTypeCard(
                title: 'Need help choosing a style?',
                subtitle: 'Try our AI Hair Advisor',
                icon: Icons.auto_awesome,
                isSelected: false,
                isSmall: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    bool isSmall = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 16 : 20),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryLight : Colors.white,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.borderGrey,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: isSmall ? 12 : 13,
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
