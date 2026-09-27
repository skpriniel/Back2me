import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../models/item.dart';
import '../models/lending_record.dart';

/// A small colored pill for statuses (Available, Borrowed, Returned, Overdue),
/// colors mapped to design-system roles rather than hardcoded per screen.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  factory StatusBadge.forItem(ItemStatus status) {
    return status == ItemStatus.available
        ? const StatusBadge(label: 'Available', color: AppColors.success)
        : const StatusBadge(label: 'Borrowed', color: AppColors.accent);
  }

  factory StatusBadge.forRecord(LendingRecord record) {
    if (record.status == LendingStatus.returned) {
      return const StatusBadge(label: 'Returned', color: AppColors.primary);
    }
    if (record.isOverdue) {
      return const StatusBadge(label: 'Overdue', color: AppColors.error);
    }
    return const StatusBadge(label: 'Borrowed', color: AppColors.accent);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }
}

/// A tappable summary tile, used for Owned/Borrowed/Returned on Home and
/// Return-rate/Active on History. Shares the badge's shape and color rules.
class CountTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  const CountTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? color : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : color),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.headlineSmall.copyWith(fontSize: 20, color: selected ? Colors.white : AppColors.textDark),
              ),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(color: selected ? Colors.white70 : AppColors.mutedText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
