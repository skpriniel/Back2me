import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/lending_record.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_date_utils.dart';
import 'category_icon.dart';
import 'status_badge.dart';

/// Card used on the Home screen for each of the user's items.
class ItemCard extends StatelessWidget {
  final Item item;
  final LendingRecord? activeRecord;
  final String? borrowerName;
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.activeRecord,
    this.borrowerName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CategoryAvatar(category: item.category),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                        Text(
                          activeRecord != null ? 'Lent to ${borrowerName ?? 'Unknown'}' : item.category,
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.mutedText),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge.forItem(item.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.sm),
              if (activeRecord != null)
                Row(
                  children: [
                    Icon(Icons.event, size: 16, color: activeRecord!.isOverdue ? AppColors.error : AppColors.mutedText),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        AppDateUtils.relativeDueLabel(activeRecord!.expectedReturnDate),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: activeRecord!.isOverdue ? AppColors.error : AppColors.mutedText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(onPressed: onTap, child: const Text('View Item')),
                  ],
                )
              else
                Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                    const SizedBox(width: 6),
                    Text('Ready to lend', style: AppTextStyles.labelSmall),
                    const Spacer(),
                    TextButton(onPressed: onTap, child: const Text('View Item')),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
