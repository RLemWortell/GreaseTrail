import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui.dart';

class ManageCategoriesScreen extends StatefulWidget {
  final Vehicle vehicle;
  final VoidCallback onBack;
  final ValueChanged<Vehicle> onUpdateVehicle;

  const ManageCategoriesScreen({super.key, required this.vehicle, required this.onBack, required this.onUpdateVehicle});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  late List<Category> _categories;
  String _newCatName = '';
  String? _addingFieldFor;
  String _newFieldLabel = '';
  String _newFieldUnit = '';

  @override
  void initState() {
    super.initState();
    _categories = widget.vehicle.categories;
  }

  void _commit(List<Category> next) {
    setState(() => _categories = next);
    widget.onUpdateVehicle(widget.vehicle.copyWith(categories: next));
  }

  void _removeField(String catId, String fieldId) {
    _commit(_categories
        .map((c) => c.id == catId ? c.copyWith(fields: c.fields.where((f) => f.id != fieldId).toList()) : c)
        .toList());
  }

  Future<void> _confirmRemoveCategory(String catId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove "$name"?'),
        content: const Text('Logged history for this category will be hidden.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Remove', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _commit(_categories.where((c) => c.id != catId).toList());
    }
  }

  void _confirmAddField(String catId) {
    if (_newFieldLabel.trim().isEmpty) return;
    final unit = _newFieldUnit.trim().isEmpty ? null : _newFieldUnit.trim();
    _commit(_categories
        .map((c) => c.id == catId
            ? c.copyWith(fields: [...c.fields, FieldDef(label: _newFieldLabel.trim(), unit: unit, type: unit != null ? 'number' : 'text')])
            : c)
        .toList());
    setState(() {
      _addingFieldFor = null;
      _newFieldLabel = '';
      _newFieldUnit = '';
    });
  }

  void _updateIntervalKm(String catId, String val) {
    _commit(_categories.map((c) => c.id == catId ? c.copyWith(intervalKm: int.tryParse(val), clearIntervalKm: val.isEmpty) : c).toList());
  }

  void _updateIntervalMonths(String catId, String val) {
    _commit(_categories
        .map((c) => c.id == catId ? c.copyWith(intervalMonths: int.tryParse(val), clearIntervalMonths: val.isEmpty) : c)
        .toList());
  }

  void _addCategory() {
    if (_newCatName.trim().isEmpty) return;
    _commit([..._categories, Category(name: _newCatName.trim())]);
    setState(() => _newCatName = '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.side),
          child: TopBar(title: 'Categories', onBack: widget.onBack),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.side, 0, AppSpace.side, 32),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              for (final c in _categories)
                Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(c.name.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: AppColors.ink)),
                            GestureDetector(
                              onTap: () => _confirmRemoveCategory(c.id, c.name),
                              child: AppText.small('Remove', color: AppColors.accent),
                            ),
                          ],
                        ),
                      ),
                      AppCard(
                        children: [
                          for (final f in c.fields)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: AppColors.hairline, width: AppSpace.hairline)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: AppTypography.body.copyWith(color: AppColors.ink),
                                      children: [
                                        TextSpan(text: f.label),
                                        if (f.unit != null) TextSpan(text: '  ${f.unit}', style: const TextStyle(color: AppColors.muted)),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _removeField(c.id, f.id),
                                    child: AppText.small('Remove', color: AppColors.muted),
                                  ),
                                ],
                              ),
                            ),
                          if (_addingFieldFor == c.id)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppField(label: 'Field', value: _newFieldLabel, placeholder: 'Torque', onChanged: (v) => setState(() => _newFieldLabel = v)),
                                  AppField(label: 'Unit', value: _newFieldUnit, placeholder: 'mm', onChanged: (v) => setState(() => _newFieldUnit = v)),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => _confirmAddField(c.id),
                                          child: AppText.body('Add', color: AppColors.ink, fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(width: 16),
                                        GestureDetector(
                                          onTap: () => setState(() {
                                            _addingFieldFor = null;
                                            _newFieldLabel = '';
                                            _newFieldUnit = '';
                                          }),
                                          child: AppText.body('Cancel', color: AppColors.muted),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            InkWell(
                              onTap: () => setState(() => _addingFieldFor = c.id),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: AppText.small('Add field', color: AppColors.muted),
                              ),
                            ),
                        ],
                      ),
                      AppField(
                        label: 'Every km',
                        value: c.intervalKm?.toString() ?? '',
                        placeholder: 'off',
                        keyboardType: TextInputType.number,
                        onChanged: (v) => _updateIntervalKm(c.id, v),
                      ),
                      AppField(
                        label: 'Every months',
                        value: c.intervalMonths?.toString() ?? '',
                        placeholder: 'off',
                        keyboardType: TextInputType.number,
                        onChanged: (v) => _updateIntervalMonths(c.id, v),
                      ),
                    ],
                  ),
                ),
              AppField(label: 'New category', value: _newCatName, placeholder: 'Fork oil', onChanged: (v) => setState(() => _newCatName = v)),
              Padding(padding: const EdgeInsets.only(top: 16), child: ActionRow(label: 'Add category', onPressed: _addCategory)),
            ],
          ),
        ),
      ],
    );
  }
}
