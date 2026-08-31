import 'package:flutter/material.dart';

import '../data/config.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/ui.dart';

class _FieldForm {
  final String catId;
  final String? fieldId;
  String label;
  String unit;
  String type;
  _FieldForm({required this.catId, this.fieldId, this.label = '', this.unit = '', this.type = 'number'});
}

List<FieldTypeOption> _typeOptionsFor(String current) {
  if (current == 'select' && !fieldTypeOptions.any((t) => t.key == 'select')) {
    return [...fieldTypeOptions, const FieldTypeOption('select', 'Select')];
  }
  return fieldTypeOptions;
}

class ManageCategoriesScreen extends StatefulWidget {
  final Vehicle vehicle;
  final VoidCallback onBack;
  final ValueChanged<Vehicle> onUpdateVehicle;
  final ValueChanged<String> onEditService;
  final VoidCallback onAddService;
  final ValueChanged<GtConfig>? onSaveConfig;
  final VoidCallback onDeleteVehicle;

  const ManageCategoriesScreen({
    super.key,
    required this.vehicle,
    required this.onBack,
    required this.onUpdateVehicle,
    required this.onEditService,
    required this.onAddService,
    required this.onDeleteVehicle,
    this.onSaveConfig,
  });

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  late List<Category> _categories;
  String _newCatName = '';
  _FieldForm? _fieldForm;
  final Map<String, TextEditingController> _nameControllers = {};

  @override
  void initState() {
    super.initState();
    _categories = widget.vehicle.categories;
  }

  @override
  void dispose() {
    for (final c in _nameControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _nameController(Category cat) {
    return _nameControllers.putIfAbsent(cat.id, () => TextEditingController(text: cat.name));
  }

  void _commit(List<Category> next, {List<LogEntry>? logs}) {
    setState(() => _categories = next);
    widget.onUpdateVehicle(widget.vehicle.copyWith(categories: next, logs: logs ?? widget.vehicle.logs));
  }

  void _persistCatName(String catId, String raw) {
    final name = raw.trim();
    if (name.isEmpty) {
      final previous = widget.vehicle.categories.where((c) => c.id == catId).firstOrNull?.name;
      if (previous != null) {
        setState(() => _categories = _categories.map((c) => c.id == catId ? c.copyWith(name: previous) : c).toList());
        _nameController(_categories.firstWhere((c) => c.id == catId)).text = previous;
      }
      return;
    }
    final next = _categories.map((c) => c.id == catId ? c.copyWith(name: name) : c).toList();
    final logs = widget.vehicle.logs.map((l) => l.categoryId == catId
        ? LogEntry(
            id: l.id,
            categoryId: l.categoryId,
            categoryName: name,
            date: l.date,
            odometer: l.odometer,
            values: l.values,
            note: l.note,
            service: l.service,
            photos: l.photos,
          )
        : l).toList();
    _commit(next, logs: logs);
  }

  void _removeField(String catId, String fieldId) {
    _commit(_categories.map((cat) => cat.id == catId ? cat.copyWith(fields: cat.fields.where((f) => f.id != fieldId).toList()) : cat).toList());
  }

  Future<void> _confirmRemoveCategory(String catId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove "$name"?'),
        content: const Text('This also removes its logged history from view.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Remove', style: TextStyle(color: AppColors.of(ctx).alert))),
        ],
      ),
    );
    if (confirmed == true) {
      _commit(_categories.where((cat) => cat.id != catId).toList());
    }
  }

  Future<void> _confirmDeleteVehicle() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${widget.vehicle.name}"?'),
        content: const Text("This permanently removes the vehicle and all its logged history. This can't be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete', style: TextStyle(color: AppColors.of(ctx).alert))),
        ],
      ),
    );
    if (confirmed == true) widget.onDeleteVehicle();
  }

  void _openAddField(String catId) => setState(() => _fieldForm = _FieldForm(catId: catId));

  void _openEditField(Category cat, FieldDef f) =>
      setState(() => _fieldForm = _FieldForm(catId: cat.id, fieldId: f.id, label: f.label, unit: f.unit ?? '', type: f.type));

  void _resetFieldForm() => setState(() => _fieldForm = null);

  void _saveFieldForm() {
    final form = _fieldForm;
    if (form == null || form.label.trim().isEmpty) return;
    final label = form.label.trim();
    final type = form.type;
    final unit = type == 'number' && form.unit.trim().isNotEmpty ? form.unit.trim() : null;
    final cat = _categories.where((c) => c.id == form.catId).firstOrNull;
    if (cat == null) return;

    var logs = widget.vehicle.logs;

    if (form.fieldId != null) {
      final old = cat.fields.where((f) => f.id == form.fieldId).firstOrNull;
      final nextFields = cat.fields
          .map((f) => f.id == form.fieldId
              ? FieldDef(id: f.id, label: label, unit: unit, type: type, options: type == 'select' ? f.options : null)
              : f)
          .toList();
      if (old != null && old.label != label) {
        logs = logs.map((l) {
          if (l.categoryId != cat.id || !l.values.containsKey(old.label)) return l;
          final values = {...l.values};
          values[label] = values.remove(old.label);
          return LogEntry(
            id: l.id,
            categoryId: l.categoryId,
            categoryName: l.categoryName,
            date: l.date,
            odometer: l.odometer,
            values: values,
            note: l.note,
            service: l.service,
            photos: l.photos,
          );
        }).toList();
      }
      _commit(_categories.map((c) => c.id == cat.id ? c.copyWith(fields: nextFields) : c).toList(), logs: logs);
    } else {
      _commit(_categories.map((c) => c.id == cat.id ? c.copyWith(fields: [...c.fields, FieldDef(label: label, unit: unit, type: type)]) : c).toList());
    }
    _resetFieldForm();
  }

  void _updateIntervalKm(String catId, String val) {
    _commit(_categories.map((cat) => cat.id == catId ? cat.copyWith(intervalKm: int.tryParse(val), clearIntervalKm: val.isEmpty) : cat).toList());
  }

  void _updateIntervalMonths(String catId, String val) {
    _commit(_categories.map((cat) => cat.id == catId ? cat.copyWith(intervalMonths: int.tryParse(val), clearIntervalMonths: val.isEmpty) : cat).toList());
  }

  void _addCategory() {
    if (_newCatName.trim().isEmpty) return;
    _commit([..._categories, Category(name: _newCatName.trim())]);
    setState(() => _newCatName = '');
  }

  Future<void> _saveAsConfig() async {
    final cfg = configFromVehicle(widget.vehicle.copyWith(categories: _categories));
    widget.onSaveConfig?.call(cfg);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Config saved'),
        content: Text('"${cfg.name}" is in Setup → Configs.'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  Widget _buildFieldForm(String catId) {
    final form = _fieldForm;
    if (form == null || form.catId != catId) return const SizedBox.shrink();
    final c = AppColors.of(context);
    final editing = form.fieldId != null;
    return StatefulBuilder(builder: (context, setFormState) {
      return Column(
        children: [
          AppField(label: 'Field name', value: form.label, placeholder: form.type == 'checkbox' || form.type == 'status' ? 'e.g. Front' : 'e.g. Torque', onChanged: (v) {
            form.label = v;
          }),
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
            AppField(label: 'Unit', value: form.unit, placeholder: 'optional, e.g. mm', last: true, onChanged: (v) {
              form.unit = v;
            }),
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
    final services = getServicePackages(widget.vehicle.copyWith(categories: _categories));

    return Container(
      color: c.bg,
      child: Column(
        children: [
          TopBar(title: 'Categories', onBack: widget.onBack),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpace.side, 12, AppSpace.side, 40),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                for (final cat in _categories)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AppCard(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(AppSpace.cardPad, 10, AppSpace.cardPad, 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _nameController(cat),
                                  style: AppTypography.category.copyWith(color: c.ink),
                                  decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none),
                                  onEditingComplete: () => _persistCatName(cat.id, _nameController(cat).text),
                                  onTapOutside: (_) => _persistCatName(cat.id, _nameController(cat).text),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _confirmRemoveCategory(cat.id, cat.name),
                                child: AppText.meta('Remove', color: c.accent),
                              ),
                            ],
                          ),
                        ),
                        for (final f in cat.fields)
                          _fieldForm?.fieldId == f.id
                              ? _buildFieldForm(cat.id)
                              : Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: AppSpace.cardPad, vertical: AppSpace.rowY - 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () => _openEditField(cat, f),
                                              child: RichText(
                                                text: TextSpan(
                                                  style: AppTypography.row.copyWith(color: c.ink),
                                                  children: [
                                                    TextSpan(text: f.label),
                                                    if (f.unit != null) TextSpan(text: ' (${f.unit})', style: TextStyle(color: c.muted)),
                                                    if (f.type != 'number') TextSpan(text: '  ·  ${f.type}', style: TextStyle(color: c.muted)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => _removeField(cat.id, f.id),
                                            child: AppText.small('×', color: c.muted),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(height: AppSpace.hairline, color: c.hairline, margin: const EdgeInsets.symmetric(horizontal: AppSpace.cardPad)),
                                  ],
                                ),
                        if (cat.fields.isEmpty && _fieldForm?.catId != cat.id)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpace.cardPad, vertical: 8),
                            child: Text('No measurement fields.', style: AppTypography.small.copyWith(color: c.faint)),
                          ),
                        if (_fieldForm?.catId == cat.id && _fieldForm?.fieldId == null)
                          _buildFieldForm(cat.id)
                        else if (_fieldForm?.fieldId != null && _fieldForm?.catId == cat.id)
                          const SizedBox.shrink()
                        else
                          InkWell(
                            onTap: () => _openAddField(cat.id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpace.cardPad, vertical: 12),
                              child: AppText.meta('+ Add field', color: c.ink),
                            ),
                          ),
                        Container(height: AppSpace.hairline, color: c.hairline, margin: const EdgeInsets.symmetric(horizontal: AppSpace.cardPad)),
                        AppField(
                          label: 'Remind every',
                          value: cat.intervalKm?.toString() ?? '',
                          placeholder: 'off',
                          unit: 'km',
                          keyboardType: TextInputType.number,
                          onChanged: (v) => _updateIntervalKm(cat.id, v),
                        ),
                        AppField(
                          label: 'Remind every',
                          value: cat.intervalMonths?.toString() ?? '',
                          placeholder: 'off',
                          unit: 'months',
                          keyboardType: TextInputType.number,
                          last: true,
                          onChanged: (v) => _updateIntervalMonths(cat.id, v),
                        ),
                      ],
                    ),
                  ),
                const Label('Add your own', margin: EdgeInsets.only(bottom: 10)),
                AppCard(children: [
                  AppField(label: 'Name', value: _newCatName, placeholder: 'e.g. Fork oil', last: true, onChanged: (v) => _newCatName = v),
                ]),
                ActionRow(label: 'Add category', onPressed: _addCategory),
                if (widget.onSaveConfig != null) ActionRow(label: 'Save as config', onPressed: _saveAsConfig),
                const SizedBox(height: AppSpace.block),
                const Label('Services', margin: EdgeInsets.only(bottom: 10)),
                AppCard(children: [
                  for (final pack in services)
                    CardRow(onPress: () => widget.onEditService(pack.id), chevron: true, left: pack.name, right: '${pack.categories.length} items'),
                  CardRow(onPress: widget.onAddService, left: AppText.meta('+ Add service', color: c.ink), divider: false),
                ]),
                const SizedBox(height: AppSpace.block),
                const Label('Appearance', margin: EdgeInsets.only(bottom: 10)),
                AppCard(children: [
                  CheckRow(
                    label: 'Use app accent color',
                    checked: widget.vehicle.color == null,
                    onToggle: () => widget.onUpdateVehicle(widget.vehicle.copyWith(clearColor: true)),
                    last: true,
                  ),
                ]),
                AppCard(
                  margin: const EdgeInsets.only(top: 12),
                  children: [
                    ColorSwatchPicker(
                      colors: accentSwatches,
                      value: widget.vehicle.color,
                      onSelected: (color) => widget.onUpdateVehicle(widget.vehicle.copyWith(colorValue: color.toARGB32())),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.block),
                const Label('Danger zone', margin: EdgeInsets.only(bottom: 10)),
                ActionRow(label: 'Delete vehicle', onPressed: _confirmDeleteVehicle, destructive: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
