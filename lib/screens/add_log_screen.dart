import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/photos.dart';
import '../widgets/ui.dart';

class AddLogScreen extends StatefulWidget {
  final Vehicle vehicle;
  final Category category;
  final VoidCallback onBack;
  final ValueChanged<LogEntry> onSave;

  const AddLogScreen({
    super.key,
    required this.vehicle,
    required this.category,
    required this.onBack,
    required this.onSave,
  });

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  late Map<String, Object?> _values;
  String _note = '';
  late String _date;
  late String _odo;
  List<String> _photos = [];

  @override
  void initState() {
    super.initState();
    _values = {for (final f in widget.category.fields) f.label: f.type == 'checkbox' ? false : ''};
    _date = todayIso();
    _odo = widget.vehicle.odometer.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final inlineFields = widget.category.fields.where((f) => f.type != 'select').toList();
    final selectFields = widget.category.fields.where((f) => f.type == 'select').toList();

    return Container(
      color: c.bg,
      child: Column(
        children: [
          TopBar(title: widget.category.name, onBack: widget.onBack),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpace.side, 12, AppSpace.side, 40),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                AppCard(
                  children: [
                    AppField(label: 'Date', value: _date, placeholder: 'YYYY-MM-DD', onChanged: (v) => setState(() => _date = v)),
                    AppField(
                      label: 'Odometer',
                      value: _odo,
                      unit: 'km',
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      last: inlineFields.isEmpty,
                      onChanged: (v) => setState(() => _odo = v),
                    ),
                    for (var i = 0; i < inlineFields.length; i++)
                      inlineFields[i].type == 'checkbox'
                          ? CheckRow(
                              label: inlineFields[i].label,
                              checked: _values[inlineFields[i].label] == true,
                              onToggle: () => setState(() => _values[inlineFields[i].label] = !(_values[inlineFields[i].label] == true)),
                              last: i == inlineFields.length - 1,
                            )
                          : AppField(
                              label: inlineFields[i].label,
                              unit: inlineFields[i].unit,
                              value: (_values[inlineFields[i].label] as String?) ?? '',
                              onChanged: (v) => setState(() => _values[inlineFields[i].label] = v),
                              keyboardType: inlineFields[i].type == 'number' ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
                              placeholder: inlineFields[i].unit != null ? 'e.g. 0.6' : '',
                              last: i == inlineFields.length - 1,
                            ),
                  ],
                ),
                if (widget.category.fields.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpace.rowY),
                    child: Text(
                      'This category has no measurement fields — logging the date and km is enough.',
                      style: AppTypography.small.copyWith(color: c.muted),
                    ),
                  ),
                for (final f in selectFields) ...[
                  const SizedBox(height: AppSpace.block),
                  Label(f.label, margin: const EdgeInsets.only(bottom: 10)),
                  AppCard(
                    children: [
                      OptionList<String>(
                        options: f.options ?? const [],
                        value: _values[f.label] as String?,
                        onChanged: (v) => setState(() => _values[f.label] = v),
                        getLabel: (v) => v,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpace.block),
                const Label('Note', margin: EdgeInsets.only(bottom: 10)),
                AppCard(
                  children: [
                    TextField(
                      onChanged: (v) => _note = v,
                      maxLines: null,
                      minLines: 3,
                      style: AppTypography.body.copyWith(color: c.ink),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.cardPad, vertical: AppSpace.fieldY),
                        border: InputBorder.none,
                        hintText: 'Anything worth remembering',
                        hintStyle: AppTypography.body.copyWith(color: c.faint),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.block),
                const Label('Photos', margin: EdgeInsets.only(bottom: 10)),
                AppCard(
                  padding: const EdgeInsets.all(AppSpace.cardPad),
                  children: [PhotoStrip(uris: _photos, editable: true, onChange: (p) => setState(() => _photos = p))],
                ),
                ActionRow(
                  label: 'Save entry',
                  onPressed: () => widget.onSave(LogEntry(
                    categoryId: widget.category.id,
                    categoryName: widget.category.name,
                    date: _date,
                    odometer: double.tryParse(_odo) ?? 0,
                    values: _values,
                    note: _note,
                    photos: _photos,
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
