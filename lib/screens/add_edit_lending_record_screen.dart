import 'package:flutter/material.dart';
import '../models/item.dart';
import '../state/app_state_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_date_utils.dart';
import '../widgets/add_item_sheet.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

/// Add/Edit lending record. Pass [recordId] to edit an existing active
/// record; omit it to create a new one.
class AddEditLendingRecordScreen extends StatefulWidget {
  final String? recordId;
  const AddEditLendingRecordScreen({super.key, this.recordId});

  @override
  State<AddEditLendingRecordScreen> createState() => _AddEditLendingRecordScreenState();
}

class _AddEditLendingRecordScreenState extends State<AddEditLendingRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _borrowerName = TextEditingController();
  final _contact = TextEditingController();
  final _note = TextEditingController();
  String? _selectedItemId;
  DateTime _borrowDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _smsReminders = true;
  bool _initialized = false;

  bool get _isEditing => widget.recordId != null;

  @override
  void dispose() {
    _borrowerName.dispose();
    _contact.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isBorrowDate}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isBorrowDate ? _borrowDate : _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isBorrowDate) {
        _borrowDate = picked;
      } else {
        _dueDate = picked;
      }
    });
  }

  void _setReturnIn(int days) => setState(() => _dueDate = _borrowDate.add(Duration(days: days)));

  Future<void> _addNewItem() async {
    final item = await showItemFormSheet(context);
    if (item != null) setState(() => _selectedItemId = item.id);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedItemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select an item to lend.')));
      return;
    }
    if (_dueDate.isBefore(_borrowDate)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Due date cannot be before the borrow date.')));
      return;
    }

    final appState = AppStateScope.of(context);

    if (_isEditing) {
      final ok = appState.updateLendingRecord(
        widget.recordId!,
        borrowerName: _borrowerName.text.trim(),
        contactNumber: _contact.text.trim(),
        borrowDate: _borrowDate,
        expectedReturnDate: _dueDate,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This record can no longer be edited.')));
        return;
      }
    } else {
      final record = appState.createLendingRecord(
        itemId: _selectedItemId!,
        borrowerName: _borrowerName.text.trim(),
        contactNumber: _contact.text.trim(),
        borrowDate: _borrowDate,
        expectedReturnDate: _dueDate,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );
      if (record == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('That item is already lent out.')));
        return;
      }
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    if (!_initialized) {
      _initialized = true;
      if (_isEditing) {
        final record = appState.lendingRecordById(widget.recordId!);
        if (record != null) {
          final borrower = appState.borrowerById(record.borrowerId);
          _selectedItemId = record.itemId;
          _borrowerName.text = borrower?.name ?? '';
          _contact.text = borrower?.contactNumber ?? '';
          _note.text = record.note ?? '';
          _borrowDate = record.borrowDate;
          _dueDate = record.expectedReturnDate;
        }
      }
    }

    final currentItem = _selectedItemId != null ? appState.itemById(_selectedItemId!) : null;
    final selectableItems = <Item>[
      ...appState.availableItems,
      if (currentItem != null && currentItem.status == ItemStatus.borrowed) currentItem,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit lending record' : 'Add lending record')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const Icon(Icons.handshake_outlined, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Seamless tracking', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                      Text(
                        'Keep track of what you lend to friends and family',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.mutedText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select item', style: AppTextStyles.labelLarge.copyWith(fontSize: 14)),
                    TextButton.icon(onPressed: _addNewItem, icon: const Icon(Icons.add, size: 16), label: const Text('New item')),
                  ],
                ),
                DropdownButtonFormField<String>(
                  value: selectableItems.any((i) => i.id == _selectedItemId) ? _selectedItemId : null,
                  hint: const Text('Choose an item'),
                  items: selectableItems.map((i) => DropdownMenuItem(value: i.id, child: Text('${i.name} \u00b7 ${i.category}'))).toList(),
                  onChanged: (v) => setState(() => _selectedItemId = v),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: "Borrower's name",
                  controller: _borrowerName,
                  icon: Icons.person_outline,
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Enter the borrower's name" : null,
                ),
                if (appState.borrowers.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: appState.borrowers.take(6).map((b) {
                      return ActionChip(
                        label: Text(b.name),
                        onPressed: () => setState(() {
                          _borrowerName.text = b.name;
                          _contact.text = b.contactNumber;
                        }),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Contact number',
                        controller: _contact,
                        icon: Icons.call_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a contact number' : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('SMS reminders', style: AppTextStyles.labelSmall.copyWith(color: AppColors.mutedText)),
                        Switch(
                          value: _smsReminders,
                          activeColor: AppColors.primary,
                          onChanged: (v) {
                            setState(() => _smsReminders = v);
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text('Demo only -- no real SMS is sent.')));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(child: _DateField(label: 'Borrow date', date: _borrowDate, onTap: () => _pickDate(isBorrowDate: true))),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: _DateField(label: 'Due date', date: _dueDate, onTap: () => _pickDate(isBorrowDate: false))),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Text('Return in:', style: AppTextStyles.labelSmall.copyWith(color: AppColors.mutedText)),
                    ActionChip(label: const Text('3 days'), onPressed: () => _setReturnIn(3)),
                    ActionChip(label: const Text('1 week'), onPressed: () => _setReturnIn(7)),
                    ActionChip(label: const Text('2 weeks'), onPressed: () => _setReturnIn(14)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Lending note (optional)',
                  controller: _note,
                  hint: 'e.g. Please return with charger',
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(label: _isEditing ? 'Save changes' : 'Save', onPressed: _save),
                const SizedBox(height: AppSpacing.sm),
                SecondaryButton(label: 'Cancel', onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  const _DateField({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge.copyWith(fontSize: 14)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.mutedText),
                const SizedBox(width: 8),
                Text(AppDateUtils.formatDate(date), style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
