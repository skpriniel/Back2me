import 'package:flutter/material.dart';
import '../models/lending_record.dart';
import '../state/app_state_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
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
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              ChoiceChip(
                label: Text('All (${records.length})'),
                selected: _filter == _HistoryFilter.all,
                onSelected: (_) => setState(() => _filter = _HistoryFilter.all),
              ),
              ChoiceChip(
                label: Text('Active (${records.where((r) => r.status == LendingStatus.active).length})'),
                selected: _filter == _HistoryFilter.active,
                onSelected: (_) => setState(() => _filter = _HistoryFilter.active),
              ),
              ChoiceChip(
                label: Text('Returned (${records.where((r) => r.status == LendingStatus.returned).length})'),
                selected: _filter == _HistoryFilter.returned,
                onSelected: (_) => setState(() => _filter = _HistoryFilter.returned),
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
