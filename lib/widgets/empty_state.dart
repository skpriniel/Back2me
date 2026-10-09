import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.mutedText),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mutedText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
