import 'package:flutter/material.dart';
import '../models/item.dart';
import '../state/app_state_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_date_utils.dart';
import '../widgets/add_item_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_card.dart';
import '../widgets/app_button.dart';
import '../widgets/status_badge.dart';
import 'add_edit_lending_record_screen.dart';
import 'item_details_screen.dart';
import 'lending_records_screen.dart';
import 'login_screen.dart';

enum _ItemFilter { all, borrowed, available }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  _ItemFilter _filter = _ItemFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              const Text('Demo user -- this local profile is not synced anywhere.'),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text('Log out'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    final visibleItems = appState.items.where((item) {
      final activeRecord = appState.activeLendingRecordForItem(item.id);
      final borrowerName = activeRecord != null ? appState.borrowerById(activeRecord.borrowerId)?.name : null;
      final matchesQuery = _query.isEmpty ||
          item.name.toLowerCase().contains(_query.toLowerCase()) ||
          (borrowerName?.toLowerCase().contains(_query.toLowerCase()) ?? false);
      final matchesFilter = switch (_filter) {
        _ItemFilter.all => true,
        _ItemFilter.borrowed => item.status == ItemStatus.borrowed,
        _ItemFilter.available => item.status == ItemStatus.available,
      };
      return matchesQuery && matchesFilter;
    }).toList();

    final dueSoon = appState.nextDueSoonRecord;

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
            children: const [TextSpan(text: 'Back2'), TextSpan(text: 'me', style: TextStyle(color: AppColors.accent))],
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.account_circle_outlined), onPressed: () => _showProfileSheet(context)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(hintText: 'Search your items', prefixIcon: Icon(Icons.search)),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                  child: IconButton(
                    icon: const Icon(Icons.tune),
                    tooltip: 'Cycle filter',
                    onPressed: () => setState(() {
                      _filter = _ItemFilter.values[(_filter.index + 1) % _ItemFilter.values.length];
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                CountTile(label: 'Items', value: '${appState.ownedCount}', icon: Icons.inventory_2_outlined, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                CountTile(label: 'Active', value: '${appState.activeBorrowedCount}', icon: Icons.access_time, color: AppColors.accent, selected: true),
                const SizedBox(width: AppSpacing.sm),
                CountTile(label: 'Safe', value: '${appState.returnedCount}', icon: Icons.check_circle_outline, color: AppColors.success),
              ],
            ),
            if (dueSoon != null) ...[
              const SizedBox(height: AppSpacing.md),
              _DueSoonBanner(recordId: dueSoon.id),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My items', style: AppTextStyles.titleMedium),
                Text('Showing ${_filter.name}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.mutedText)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                ChoiceChip(
                  label: Text('All (${appState.items.length})'),
                  selected: _filter == _ItemFilter.all,
                  onSelected: (_) => setState(() => _filter = _ItemFilter.all),
                ),
                ChoiceChip(
                  label: Text('Borrowed (${appState.items.where((i) => i.status == ItemStatus.borrowed).length})'),
                  selected: _filter == _ItemFilter.borrowed,
                  onSelected: (_) => setState(() => _filter = _ItemFilter.borrowed),
                ),
                ChoiceChip(
                  label: Text('Available (${appState.items.where((i) => i.status == ItemStatus.available).length})'),
                  selected: _filter == _ItemFilter.available,
                  onSelected: (_) => setState(() => _filter = _ItemFilter.available),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (visibleItems.isEmpty)
              const EmptyState(
                icon: Icons.inbox_outlined,
                title: 'No items yet',
                subtitle: 'Add your first item when you create a lending record.',
              )
            else
              ...visibleItems.map((item) {
                final record = appState.activeLendingRecordForItem(item.id);
                final borrowerName = record != null ? appState.borrowerById(record.borrowerId)?.name : null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ItemCard(
                    item: item,
                    activeRecord: record,
                    borrowerName: borrowerName,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemDetailsScreen(itemId: item.id))),
                  ),
                );
              }),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: '+ Add lending',
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddEditLendingRecordScreen())),
            ),
            const SizedBox(height: AppSpacing.sm),
            SecondaryButton(label: '+ New item', onPressed: () => showItemFormSheet(context)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LendingRecordsScreen()));
          } else if (i == 2) {
            _showProfileSheet(context);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _DueSoonBanner extends StatelessWidget {
  final String recordId;
  const _DueSoonBanner({required this.recordId});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final record = appState.lendingRecordById(recordId);
    if (record == null) return const SizedBox.shrink();
    final item = appState.itemById(record.itemId);
    final borrower = appState.borrowerById(record.borrowerId);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_outlined, color: Colors.white),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '${item?.name ?? 'Item'} \u2014 ${AppDateUtils.relativeDueLabel(record.expectedReturnDate).toLowerCase()} from ${borrower?.name ?? 'borrower'}',
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reminder sent (demo only -- no real message is sent).')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.white.withOpacity(0.15)),
            child: const Text('Nudge'),
          ),
        ],
      ),
    );
  }
}
