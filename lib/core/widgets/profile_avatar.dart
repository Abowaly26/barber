import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A customizable profile avatar widget with optional edit overlay and loading state
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? userName;
  final double radius;
  final bool showArc;
  final bool showEditOverlay;
  final bool isLoading;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.userName,
    this.radius = 40,
    this.showArc = true,
    this.showEditOverlay = true,
    this.isLoading = false,
    this.onTap,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Main Avatar
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor ?? Colors.grey.shade200,
            ),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: radius,
                      height: radius,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          textColor ?? Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  )
                : ClipOval(child: _buildAvatarContent(context)),
          ),

          // Edit Overlay (if enabled)
          if (showEditOverlay && !isLoading)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: radius * 0.6,
                height: radius * 0.6,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: radius * 0.35,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent(BuildContext context) {
    // If image URL is provided and not empty, show network image
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: radius * 2,
        height: radius * 2,
        errorBuilder: (context, error, stackTrace) {
          return _buildInitialsAvatar(context);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: radius,
              height: radius,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    }

    // Otherwise, show initials or default icon
    return _buildInitialsAvatar(context);
  }

  Widget _buildInitialsAvatar(BuildContext context) {
    // If userName is provided, show initials
    if (userName != null && userName!.isNotEmpty) {
      final initials = _getInitials(userName!);
      return Container(
        width: radius * 2,
        height: radius * 2,
        color: backgroundColor ?? Colors.grey.shade300,
        child: Center(
          child: Text(
            initials,
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontSize: radius * 0.7,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // Default: show person icon
    return Container(
      width: radius * 2,
      height: radius * 2,
      color: backgroundColor ?? Colors.grey.shade300,
      child: Icon(
        Icons.person,
        color: textColor ?? Colors.grey.shade600,
        size: radius * 1.2,
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      // Single name: return first letter
      return parts[0][0].toUpperCase();
    }

    // Multiple names: return first letter of first and last name
    final firstInitial = parts[0][0].toUpperCase();
    final lastInitial = parts[parts.length - 1][0].toUpperCase();
    return '$firstInitial$lastInitial';
  }
}
