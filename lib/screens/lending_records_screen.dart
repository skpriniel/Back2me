import 'package:flutter/material.dart';
import '../models/lending_record.dart';
import '../state/app_state_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_text_styles.dart';
import '../widgets/empty_state.dart';
import '../widgets/lending_record_card.dart';
import '../widgets/status_badge.dart';
import 'item_details_screen.dart';

enum _HistoryFilter { all, active, returned }

class LendingRecordsScreen extends StatefulWidget {
  const LendingRecordsScreen({super.key});

  @override
  State<LendingRecordsScreen> createState() => _LendingRecordsScreenState();
}

class _LendingRecordsScreenState extends State<LendingRecordsScreen> {
  _HistoryFilter _filter = _HistoryFilter.all;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final records = [...appState.lendingRecords]
      ..sort((a, b) => (b.actualReturnDate ?? b.borrowDate).compareTo(a.actualReturnDate ?? a.borrowDate));

    final visible = records.where((r) {
      return switch (_filter) {
        _HistoryFilter.all => true,
        _HistoryFilter.active => r.status == LendingStatus.active,
        _HistoryFilter.returned => r.status == LendingStatus.returned,
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text('${records.length} total transactions logged', style: AppTextStyles.labelSmall.copyWith(color: AppColors.mutedText)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              CountTile(
                label: 'Return rate',
                value: '${(appState.returnRate * 100).round()}%',
                icon: Icons.verified_outlined,
                color: AppColors.success,
              ),
              const SizedBox(width: AppSpacing.sm),
              CountTile(label: 'Active', value: '${appState.activeBorrowedCount}', icon: Icons.alarm, color: AppColors.accent),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _HistoryFilterChip(
                  label: 'All (${records.length})',
                  selected: _filter == _HistoryFilter.all,
                  onTap: () => setState(() => _filter = _HistoryFilter.all),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _HistoryFilterChip(
                  label: 'Active (${records.where((r) => r.status == LendingStatus.active).length})',
                  selected: _filter == _HistoryFilter.active,
                  onTap: () => setState(() => _filter = _HistoryFilter.active),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _HistoryFilterChip(
                  label: 'Returned (${records.where((r) => r.status == LendingStatus.returned).length})',
                  selected: _filter == _HistoryFilter.returned,
                  onTap: () => setState(() => _filter = _HistoryFilter.returned),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (visible.isEmpty)
            const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No records here',
              subtitle: 'Lending records will show up here once you start lending items.',
            )
          else
            ...visible.map((r) {
              final item = appState.itemById(r.itemId);
              final borrower = appState.borrowerById(r.borrowerId);
              return HistoryCard(
                record: r,
                itemName: item?.name ?? 'Deleted item',
                itemCategory: item?.category ?? 'Others',
                borrowerName: borrower?.name ?? 'Unknown',
                onTap: item == null
                    ? () {}
                    : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemDetailsScreen(itemId: item.id))),
              );
            }),
        ],
      ),
    );
  }
}

/// Same compact, single-line pill used on Home, so filter controls look
/// consistent across screens.
class _HistoryFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _HistoryFilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.accent : AppColors.divider),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check, size: 14, color: AppColors.onAccent),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: selected ? AppColors.onAccent : AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
