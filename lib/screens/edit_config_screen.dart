import 'package:flutter/material.dart';

import '../data/config.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/ui.dart';

class _FieldForm {
  final int catIndex;
  final int? fieldIndex;
  String label;
  String unit;
  String type;
  _FieldForm({required this.catIndex, this.fieldIndex, this.label = '', this.unit = '', this.type = 'number'});
}

List<FieldTypeOption> _typeOptionsFor(String current) {
  if (current == 'select' && !fieldTypeOptions.any((t) => t.key == 'select')) {
    return [...fieldTypeOptions, const FieldTypeOption('select', 'Select')];
  }
  return fieldTypeOptions;
}

/// Full-screen view of a single config — read-only for the built-in
/// defaults, fully editable (name, categories, fields, intervals) for
/// custom ones.
class EditConfigScreen extends StatefulWidget {
  final GtConfig config;
  final VoidCallback onBack;
  final ValueChanged<GtConfig> onUpdate;
  final VoidCallback onDuplicate;
  final VoidCallback onCreateVehicle;
  final VoidCallback onExport;
  final VoidCallback? onDelete;

  const EditConfigScreen({
    super.key,
    required this.config,
    required this.onBack,
    required this.onUpdate,
    required this.onDuplicate,
    required this.onCreateVehicle,
    required this.onExport,
    this.onDelete,
  });

  @override
  State<EditConfigScreen> createState() => _EditConfigScreenState();
}

class _EditConfigScreenState extends State<EditConfigScreen> {
  late List<ConfigCategorySpec> _categories;
  late final TextEditingController _nameController;
  String _newCatName = '';
  _FieldForm? _fieldForm;
  final Map<int, TextEditingController> _catNameControllers = {};

  bool get _editable => !widget.config.builtin;

  @override
  void initState() {
    super.initState();
    _categories = widget.config.categories;
    _nameController = TextEditingController(text: widget.config.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final c in _catNameControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _catNameController(int index, String name) {
    return _catNameControllers.putIfAbsent(index, () => TextEditingController(text: name));
  }

  void _commit(List<ConfigCategorySpec> next) {
    setState(() => _categories = next);
    widget.onUpdate(widget.config.copyWith(categories: next));
  }

  void _persistName(String raw) {
    final name = raw.trim();
    if (name.isEmpty) {
      _nameController.text = widget.config.name;
      return;
    }
    widget.onUpdate(widget.config.copyWith(name: name));
  }

  void _persistCatName(int index, String raw) {
    final name = raw.trim();
    if (name.isEmpty) {
      _catNameController(index, _categories[index].name).text = _categories[index].name;
      return;
    }
    final next = [..._categories];
    next[index] = next[index].copyWith(name: name);
    _commit(next);
  }

  void _removeField(int catIndex, int fieldIndex) {
    final next = [..._categories];
    final fields = [...next[catIndex].fields]..removeAt(fieldIndex);
    next[catIndex] = next[catIndex].copyWith(fields: fields);
    // A later field's index in this category shifted — drop any open form
    // rather than risk it pointing at the wrong field now.
    if (_fieldForm?.catIndex == catIndex) _fieldForm = null;
    _commit(next);
  }

  Future<void> _confirmRemoveCategory(int index, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove "$name"?'),
        content: const Text('Vehicles already created from this config keep their own categories.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Remove', style: TextStyle(color: AppColors.of(ctx).alert))),
        ],
      ),
    );
    if (confirmed == true) {
      final next = [..._categories]..removeAt(index);
      // Indices shift on removal, so drop every cached controller/open form
      // rather than risk one landing on the wrong row.
      for (final ctrl in _catNameControllers.values) {
        ctrl.dispose();
      }
      _catNameControllers.clear();
      _fieldForm = null;
      _commit(next);
    }
  }

  void _openAddField(int catIndex) => setState(() => _fieldForm = _FieldForm(catIndex: catIndex));

  void _openEditField(int catIndex, int fieldIndex, ConfigFieldSpec f) =>
      setState(() => _fieldForm = _FieldForm(catIndex: catIndex, fieldIndex: fieldIndex, label: f.label, unit: f.unit ?? '', type: f.type));

  void _resetFieldForm() => setState(() => _fieldForm = null);

  void _saveFieldForm() {
    final form = _fieldForm;
    if (form == null || form.label.trim().isEmpty) return;
    final label = form.label.trim();
    final type = form.type;
    final unit = type == 'number' && form.unit.trim().isNotEmpty ? form.unit.trim() : null;

    final next = [..._categories];
    final fields = [...next[form.catIndex].fields];
    final spec = ConfigFieldSpec(label: label, unit: unit, type: type);
    if (form.fieldIndex != null) {
      fields[form.fieldIndex!] = spec;
    } else {
      fields.add(spec);
    }
    next[form.catIndex] = next[form.catIndex].copyWith(fields: fields);
    _commit(next);
    _resetFieldForm();
  }

  void _updateIntervalKm(int index, String val) {
    final next = [..._categories];
    next[index] = next[index].copyWith(intervalKm: int.tryParse(val), clearIntervalKm: val.isEmpty);
    _commit(next);
  }

  void _updateIntervalMonths(int index, String val) {
    final next = [..._categories];
    next[index] = next[index].copyWith(intervalMonths: int.tryParse(val), clearIntervalMonths: val.isEmpty);
    _commit(next);
  }

  void _addCategory() {
    if (_newCatName.trim().isEmpty) return;
    _commit([..._categories, ConfigCategorySpec(name: _newCatName.trim())]);
    setState(() => _newCatName = '');
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${widget.config.name}"?'),
        content: const Text('Vehicles already created from it stay as they are.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: TextStyle(color: AppColors.of(ctx).alert))),
        ],
      ),
    );
    if (confirmed == true) widget.onDelete?.call();
  }

  Widget _buildFieldForm(int catIndex) {
    final form = _fieldForm;
    if (form == null || form.catIndex != catIndex) return const SizedBox.shrink();
    final c = AppColors.of(context);
    final editing = form.fieldIndex != null;
    return StatefulBuilder(builder: (context, setFormState) {
      return Column(
        children: [
          AppField(
            label: 'Field name',
            value: form.label,
            placeholder: form.type == 'checkbox' ? 'e.g. Front' : 'e.g. Torque',
            onChanged: (v) => form.label = v,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpace.cardPad, 8, AppSpace.cardPad, 0),
                  child: AppText.meta('Type', color: c.muted),
                ),
                OptionList<FieldTypeOption>(
                  options: _typeOptionsFor(form.type),
                  value: _typeOptionsFor(form.type).where((o) => o.key == form.type).firstOrNull,
                  onChanged: (o) => setFormState(() => form.type = o.key),
                  getLabel: (o) => o.label,
                ),
              ],
            ),
          ),
          if (form.type == 'number')
            AppField(label: 'Unit', value: form.unit, placeholder: 'optional, e.g. mm', last: true, onChanged: (v) => form.unit = v),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.cardPad, vertical: 12),
            child: Row(
              children: [
                GestureDetector(onTap: _saveFieldForm, child: AppText.meta(editing ? 'Save' : 'Add', color: c.accent)),
                const SizedBox(width: 24),
                GestureDetector(onTap: _resetFieldForm, child: AppText.meta('Cancel', color: c.muted)),
              ],
            ),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final config = widget.config;
    final editable = _editable;

    return Container(
      color: c.bg,
      child: Column(
        children: [
          TopBar(title: editable ? 'Edit config' : 'Config', onBack: widget.onBack),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpace.side, 12, AppSpace.side, 40),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                const Label('Name', margin: EdgeInsets.only(bottom: 10)),
                AppCard(children: [
                  editable
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpace.cardPad, vertical: AppSpace.fieldY),
                          child: TextField(
                            controller: _nameController,
                            style: AppTypography.row.copyWith(color: c.ink),
                            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none),
                            onEditingComplete: () => _persistName(_nameController.text),
                            onTapOutside: (_) => _persistName(_nameController.text),
                          ),
                        )
                      : CardRow(left: config.name, divider: false),
                ]),
                const SizedBox(height: AppSpace.block),
                const Label('Overview', margin: EdgeInsets.only(bottom: 10)),
                AppCard(children: [
                  CardRow(left: 'Type', right: typeMeta[config.type]?.label ?? config.type),
                  CardRow(left: 'Categories', right: '${_categories.length}', divider: false),
                ]),
                const SizedBox(height: AppSpace.block),
                const SectionHeader('Categories'),
                for (var i = 0; i < _categories.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: AppCard(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(AppSpace.cardPad, 10, AppSpace.cardPad, 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: editable
                                    ? TextField(
                                        controller: _catNameController(i, _categories[i].name),
                                        style: AppTypography.category.copyWith(color: c.ink),
                                        decoration:
                                            const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none),
                                        onEditingComplete: () => _persistCatName(i, _catNameController(i, _categories[i].name).text),
                                        onTapOutside: (_) => _persistCatName(i, _catNameController(i, _categories[i].name).text),
                                      )
                                    : AppText.category(_categories[i].name, color: c.ink),
                              ),
                              if (editable)
                                GestureDetector(
                                  onTap: () => _confirmRemoveCategory(i, _categories[i].name),
                                  child: AppText.meta('Remove', color: c.accent),
                                ),
                            ],
                          ),
                        ),
                        for (var fi = 0; fi < _categories[i].fields.length; fi++)
                          _fieldForm?.catIndex == i && _fieldForm?.fieldIndex == fi
                              ? _buildFieldForm(i)
                              : Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: AppSpace.cardPad, vertical: AppSpace.rowY - 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: editable ? () => _openEditField(i, fi, _categories[i].fields[fi]) : null,
                                              child: RichText(
                                                text: TextSpan(
                                                  style: AppTypography.row.copyWith(color: c.ink),
                                                  children: [
                                                    TextSpan(text: _categories[i].fields[fi].label),
                                                    if (_categories[i].fields[fi].unit != null)
                                                      TextSpan(text: ' (${_categories[i].fields[fi].unit})', style: TextStyle(color: c.muted)),
                                                    if (_categories[i].fields[fi].type != 'number')
                                                      TextSpan(text: '  ·  ${_categories[i].fields[fi].type}', style: TextStyle(color: c.muted)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (editable)
                                            GestureDetector(onTap: () => _removeField(i, fi), child: AppText.small('×', color: c.muted)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                        height: AppSpace.hairline, color: c.hairline, margin: const EdgeInsets.symmetric(horizontal: AppSpace.cardPad)),
                                  ],
                                ),
                        if (_categories[i].fields.isEmpty && _fieldForm?.catIndex != i)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpace.cardPad, vertical: 8),
                            child: Text('No measurement fields.', style: AppTypography.small.copyWith(color: c.faint)),
                          ),
                        if (editable) ...[
                          if (_fieldForm?.catIndex == i && _fieldForm?.fieldIndex == null)
                            _buildFieldForm(i)
                          else if (_fieldForm != null && _fieldForm?.catIndex == i)
                            const SizedBox.shrink()
                          else
                            InkWell(
                              onTap: () => _openAddField(i),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpace.cardPad, vertical: 12),
                                child: AppText.meta('+ Add field', color: c.ink),
                              ),
                            ),
                          Container(height: AppSpace.hairline, color: c.hairline, margin: const EdgeInsets.symmetric(horizontal: AppSpace.cardPad)),
                          AppField(
                            label: 'Remind every',
                            value: _categories[i].intervalKm?.toString() ?? '',
                            placeholder: 'off',
                            unit: 'km',
                            keyboardType: TextInputType.number,
                            onChanged: (v) => _updateIntervalKm(i, v),
                          ),
                          AppField(
                            label: 'Remind every',
                            value: _categories[i].intervalMonths?.toString() ?? '',
                            placeholder: 'off',
                            unit: 'months',
                            keyboardType: TextInputType.number,
                            last: true,
                            onChanged: (v) => _updateIntervalMonths(i, v),
                          ),
                        ] else
                          CardRow(
                            left: 'Remind every',
                            right: _categories[i].intervalKm != null
                                ? '${_categories[i].intervalKm} km'
                                : _categories[i].intervalMonths != null
                                    ? '${_categories[i].intervalMonths} mo'
                                    : 'off',
                            divider: false,
                          ),
                      ],
                    ),
                  ),
                if (editable) ...[
                  const SizedBox(height: AppSpace.block),
                  const Label('Add category', margin: EdgeInsets.only(bottom: 10)),
                  AppCard(children: [
                    AppField(label: 'Name', value: _newCatName, placeholder: 'e.g. Fork oil', last: true, onChanged: (v) => _newCatName = v),
                  ]),
                  ActionRow(label: 'Add category', onPressed: _addCategory),
                ],
                const SizedBox(height: AppSpace.block),
                const SectionHeader('Actions'),
                AppCard(
                  margin: const EdgeInsets.only(top: 14),
                  children: [
                    CardRow(onPress: widget.onCreateVehicle, chevron: true, left: 'Create vehicle'),
                    CardRow(onPress: widget.onDuplicate, chevron: true, left: 'Duplicate'),
                    CardRow(onPress: widget.onExport, chevron: true, left: 'Export', divider: widget.onDelete != null),
                    if (widget.onDelete != null) CardRow(onPress: _confirmDelete, left: 'Delete', divider: false),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
