import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/top_bar.dart';
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
  late Map<String, String> _values;
  String _note = '';
  late String _date;
  late String _odo;

  @override
  void initState() {
    super.initState();
    _values = {for (final f in widget.category.fields) f.label: ''};
    _date = todayIso();
    _odo = widget.vehicle.odometer.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.side),
          child: TopBar(title: widget.category.name, onBack: widget.onBack),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.side, 0, AppSpace.side, 32),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              AppField(label: 'Date', value: _date, placeholder: '2026-08-17', onChanged: (v) => setState(() => _date = v)),
              AppField(
                label: 'Odometer',
                value: _odo,
                unit: 'km',
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => _odo = v),
              ),
              for (final f in widget.category.fields)
                f.type == 'select'
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: OptionList<String>(
                          options: f.options ?? const [],
                          value: _values[f.label],
                          onChanged: (v) => setState(() => _values[f.label] = v),
                          getLabel: (v) => v,
                        ),
                      )
                    : AppField(
                        label: f.label,
                        value: _values[f.label] ?? '',
                        unit: f.unit,
                        keyboardType: f.type == 'number' ? TextInputType.number : TextInputType.text,
                        placeholder: f.unit != null ? '0' : '',
                        onChanged: (v) => setState(() => _values[f.label] = v),
                      ),
              AppField(label: 'Note', value: _note, placeholder: 'Optional', onChanged: (v) => setState(() => _note = v)),
              Padding(
                padding: const EdgeInsets.only(top: 28),
                child: ActionRow(
                  label: 'Save entry',
                  onPressed: () => widget.onSave(LogEntry(
                    categoryId: widget.category.id,
                    categoryName: widget.category.name,
                    date: _date,
                    odometer: double.tryParse(_odo) ?? 0,
                    values: _values,
                    note: _note,
                  )),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
