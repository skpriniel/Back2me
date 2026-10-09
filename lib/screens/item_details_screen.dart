import 'package:flutter/material.dart';
import '../models/lending_record.dart';
import '../state/app_state_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_date_utils.dart';
import '../widgets/add_item_sheet.dart';
import '../widgets/app_button.dart';
import '../widgets/category_icon.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/status_badge.dart';

class ItemDetailsScreen extends StatelessWidget {
  final String itemId;
  const ItemDetailsScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final item = appState.itemById(itemId);

    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Item details')),
        body: const Center(child: Text('This item no longer exists.')),
      );
    }

    final activeRecord = appState.activeLendingRecordForItem(itemId);
    final history = appState.recordsForItem(itemId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              if (appState.activeLendingRecordForItem(itemId) != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This item is currently lent out. Mark it returned before deleting.')),
                );
                return;
              }
              final ok = await showConfirmDialog(
                context,
                title: 'Delete item?',
                message: 'This removes "${item.name}" from your items. Its past lending history stays with other records.',
                confirmLabel: 'Delete',
                isDestructive: true,
              );
              if (ok) {
                appState.deleteItem(itemId);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  CategoryAvatar(category: item.category),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: AppTextStyles.titleMedium),
                        Text(
                          '${item.category} \u00b7 ${item.condition} condition',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.mutedText),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge.forItem(item.status),
                ],
              ),
            ),
          ),
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description', style: AppTextStyles.labelLarge.copyWith(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(item.description, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            ),
          ],
          if (activeRecord != null) ...[
            const SizedBox(height: AppSpacing.md),
            _DueBanner(record: activeRecord),
            const SizedBox(height: AppSpacing.sm),
            _LendingInfoCard(record: activeRecord),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (history.isNotEmpty) ...[
            Text('Lending history', style: AppTextStyles.titleMedium.copyWith(fontSize: 16)),
            const SizedBox(height: AppSpacing.sm),
            ...history.map((r) {
              final borrower = appState.borrowerById(r.borrowerId);
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  title: Text(borrower?.name ?? 'Unknown borrower'),
                  subtitle: Text(
                    r.actualReturnDate != null
                        ? 'Returned ${AppDateUtils.formatDate(r.actualReturnDate!)}'
                        : 'Borrowed ${AppDateUtils.formatDate(r.borrowDate)}',
                  ),
                  trailing: StatusBadge.forRecord(r),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (activeRecord != null) ...[
                PrimaryButton(
                  label: 'Mark as returned',
                  icon: Icons.check_circle_outline,
                  onPressed: () async {
                    final ok = await showConfirmDialog(
                      context,
                      title: 'Mark as returned?',
                      message: 'This confirms "${item.name}" has been returned and updates its status.',
                      confirmLabel: 'Confirm',
                    );
                    if (ok) appState.markReturned(activeRecord.id);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              SecondaryButton(
                label: 'Edit details',
                icon: Icons.edit_outlined,
                onPressed: () => showItemFormSheet(context, existing: item),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DueBanner extends StatelessWidget {
  final LendingRecord record;
  const _DueBanner({required this.record});

  @override
  Widget build(BuildContext context) {
    final overdue = record.isOverdue;
    final color = overdue ? AppColors.error : AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(overdue ? Icons.warning_amber_rounded : Icons.schedule, color: Colors.white),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              AppDateUtils.relativeDueLabel(record.expectedReturnDate),
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(
              overdue ? 'Overdue' : 'On schedule',
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _LendingInfoCard extends StatelessWidget {
  final LendingRecord record;
  const _LendingInfoCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final borrower = appState.borrowerById(record.borrowerId);
    final initial = (borrower?.name.isNotEmpty ?? false) ? borrower!.name.substring(0, 1).toUpperCase() : '?';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current lending info', style: AppTextStyles.labelLarge.copyWith(fontSize: 14)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.accent.withOpacity(0.2),
                  child: Text(initial, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(borrower?.name ?? 'Unknown', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                      Text(borrower?.contactNumber ?? '', style: AppTextStyles.labelSmall.copyWith(color: AppColors.mutedText)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.call_outlined, color: AppColors.primary),
                  onPressed: () => ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Demo only -- no real call is placed.'))),
                ),
                IconButton(
                  icon: const Icon(Icons.message_outlined, color: AppColors.primary),
                  onPressed: () => ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Demo only -- no real message is sent.'))),
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            _InfoRow(icon: Icons.calendar_today_outlined, label: 'Borrow date', value: AppDateUtils.formatDate(record.borrowDate)),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(icon: Icons.event_available_outlined, label: 'Due date', value: AppDateUtils.formatDate(record.expectedReturnDate)),
            if (record.note != null && record.note!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('Lending note', style: AppTextStyles.labelSmall.copyWith(color: AppColors.mutedText, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('"${record.note}"', style: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.mutedText),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
        Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
