import 'package:flutter/material.dart';
import '../models/lending_record.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_date_utils.dart';
import 'category_icon.dart';
import 'status_badge.dart';

/// Card used on the History screen for each past/active lending record.
class HistoryCard extends StatelessWidget {
  final LendingRecord record;
  final String itemName;
  final String itemCategory;
  final String borrowerName;
  final VoidCallback onTap;

  const HistoryCard({
    super.key,
    required this.record,
    required this.itemName,
    required this.itemCategory,
    required this.borrowerName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel = record.actualReturnDate != null
        ? 'Returned on ${AppDateUtils.formatDate(record.actualReturnDate!)}'
        : 'Borrowed on ${AppDateUtils.formatDate(record.borrowDate)}';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CategoryAvatar(category: itemCategory),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$itemName \u203a $borrowerName', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                    Text(dateLabel, style: AppTextStyles.labelSmall.copyWith(color: AppColors.mutedText)),
                  ],
                ),
              ),
              StatusBadge.forRecord(record),
            ],
          ),
        ),
      ),
    );
  }
}
