import 'package:flutter/material.dart';
import '../models/item.dart';
import '../state/app_state_scope.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_button.dart';
import 'app_text_field.dart';

/// Shows a bottom sheet to add a new item, or edit an existing one.
/// Returns the created/edited Item, or null if cancelled. Reused from both
/// the Home screen and the Add/Edit Lending Record screen's "+ New Item".
Future<Item?> showItemFormSheet(BuildContext context, {Item? existing}) {
  return showModalBottomSheet<Item>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _ItemFormSheet(existing: existing),
  );
}

class _ItemFormSheet extends StatefulWidget {
  final Item? existing;
  const _ItemFormSheet({this.existing});

  @override
  State<_ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends State<_ItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late String _category;
  late String _condition;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _description = TextEditingController(text: widget.existing?.description ?? '');
    _category = widget.existing?.category ?? kItemCategories.first;
    _condition = widget.existing?.condition ?? kItemConditions.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final appState = AppStateScope.of(context);
    Item result;
    if (widget.existing != null) {
      appState.updateItem(
        widget.existing!.id,
        name: _name.text.trim(),
        category: _category,
        description: _description.text.trim(),
        condition: _condition,
      );
      result = appState.itemById(widget.existing!.id)!;
    } else {
      result = appState.addItem(
        name: _name.text.trim(),
        category: _category,
        description: _description.text.trim(),
        condition: _condition,
      );
    }
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isEditing ? 'Edit item' : 'New item', style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Item name',
                  controller: _name,
                  hint: 'e.g. Laptop',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter an item name' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Category', style: AppTextStyles.labelLarge.copyWith(fontSize: 14)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _category,
                  items: kItemCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Condition', style: AppTextStyles.labelLarge.copyWith(fontSize: 14)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _condition,
                  items: kItemConditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _condition = v!),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(label: 'Description', controller: _description, hint: 'Short description', maxLines: 3),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(child: SecondaryButton(label: 'Cancel', onPressed: () => Navigator.pop(context))),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: PrimaryButton(label: 'Save', onPressed: _save)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
