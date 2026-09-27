import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

IconData categoryIcon(String category) {
  switch (category) {
    case 'Electronics':
      return Icons.devices_other;
    case 'Books':
      return Icons.menu_book;
    case 'Tools':
      return Icons.build;
    case 'Sports Equipment':
      return Icons.sports_basketball;
    case 'Clothing':
      return Icons.checkroom;
    default:
      return Icons.category;
  }
}

/// Small rounded icon used as a stand-in for an item photo on cards.
class CategoryAvatar extends StatelessWidget {
  final String category;
  const CategoryAvatar({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Icon(categoryIcon(category), color: AppColors.primary, size: 22),
    );
  }
}
