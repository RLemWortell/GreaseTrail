import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/photos.dart';
import '../widgets/ui.dart';

class ServiceScreen extends StatefulWidget {
  final Vehicle vehicle;
  final String packageId;
  final VoidCallback onBack;
  final ValueChanged<List<LogEntry>> onSave;

  const ServiceScreen({super.key, required this.vehicle, required this.packageId, required this.onBack, required this.onSave});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  late String _date;
  late String _odo;
  String _note = '';
  final Map<String, bool> _done = {};
  final Map<String, Map<String, Object?>> _values = {};
  List<String> _photos = [];

  @override
  void initState() {
    super.initState();
    _date = todayIso();
    _odo = widget.vehicle.odometer.round().toString();
  }

  void _toggle(Category cat) {
    final turningOn = !(_done[cat.id] ?? false);
    setState(() {
      _done[cat.id] = turningOn;
      if (turningOn) {
        _values[cat.id] = emptyFieldValues(cat, true);
      } else {
        _values.remove(cat.id);
      }
    });
  }

  void _setField(String catId, String label, Object? value) {
    setState(() => _values[catId] = {...(_values[catId] ?? {}), label: value});
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final pack = getServicePackages(widget.vehicle).where((p) => p.id == widget.packageId).firstOrNull;

    if (pack == null) {
      return Container(color: c.bg, child: Column(children: [TopBar(title: 'Service', onBack: widget.onBack)]));
    }

    final checked = pack.categories.where((cat) => _done[cat.id] == true).toList();

    return Container(
      color: c.bg,
      child: Column(
        children: [
          TopBar(title: pack.name, onBack: widget.onBack),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpace.side, 12, AppSpace.side, 40),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                AppCard(children: [
                  AppField(label: 'Date', value: _date, placeholder: 'YYYY-MM-DD', onChanged: (v) => setState(() => _date = v)),
                  AppField(
                    label: 'Odometer',
                    value: _odo,
                    unit: 'km',
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    last: true,
                    onChanged: (v) => setState(() => _odo = v),
                  ),
                ]),
                const SizedBox(height: AppSpace.block),
                const Label('Checklist', margin: EdgeInsets.only(bottom: 10)),
                AppCard(children: _buildChecklistRows(pack.categories)),
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
                        hintText: 'Optional — applies to every item',
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
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(AppSpace.side, 14, AppSpace.side, 14),
            decoration: BoxDecoration(color: c.bg, border: Border(top: BorderSide(color: c.hairline, width: AppSpace.hairline))),
            child: PrimaryButton(
              label: checked.isNotEmpty ? 'Save · ${checked.length}' : 'Tick items first',
              onPressed: checked.isEmpty
                  ? null
                  : () {
                      final odometer = double.tryParse(_odo) ?? 0;
                      widget.onSave([
                        for (final cat in checked)
                          LogEntry(
                            categoryId: cat.id,
                            categoryName: cat.name,
                            date: _date,
                            odometer: odometer,
                            values: _values[cat.id] ?? {},
                            note: _note,
                            service: pack.name,
                            photos: _photos,
                          ),
                      ]);
                    },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChecklistRows(List<Category> categories) {
    final rows = <Widget>[];
    for (var ci = 0; ci < categories.length; ci++) {
      final cat = categories[ci];
      final isLastCategory = ci == categories.length - 1;
      final on = _done[cat.id] == true;
      final showFields = on && cat.fields.isNotEmpty;
      final catValues = _values[cat.id] ?? {};

      rows.add(CheckRow(label: cat.name, checked: on, onToggle: () => _toggle(cat), last: showFields || isLastCategory));

      if (showFields) {
        final inline = cat.fields.where((f) => f.type != 'select').toList();
        final selects = cat.fields.where((f) => f.type == 'select').toList();

        for (var fi = 0; fi < inline.length; fi++) {
          final f = inline[fi];
          final isLastInline = isLastCategory && fi == inline.length - 1 && selects.isEmpty;
          if (f.type == 'checkbox') {
            rows.add(CheckRow(
              label: f.label,
              checked: catValues[f.label] == true,
              onToggle: () => _setField(cat.id, f.label, !(catValues[f.label] == true)),
              last: isLastInline,
            ));
          } else {
            rows.add(AppField(
              label: f.label,
              unit: f.unit,
              value: (catValues[f.label] as String?) ?? '',
              onChanged: (v) => _setField(cat.id, f.label, v),
              keyboardType: f.type == 'number' ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
              placeholder: f.unit != null ? 'e.g. 0.6' : '',
              last: isLastInline,
            ));
          }
        }

        for (var si = 0; si < selects.length; si++) {
          final f = selects[si];
          final isLastSelect = isLastCategory && si == selects.length - 1;
          rows.add(Padding(
            padding: const EdgeInsets.fromLTRB(AppSpace.cardPad, 10, AppSpace.cardPad, 0),
            child: Builder(builder: (context) => AppText.meta(f.label, color: AppColors.of(context).muted)),
          ));
          rows.add(OptionList<String>(
            options: f.options ?? const [],
            value: catValues[f.label] as String?,
            onChanged: (v) => _setField(cat.id, f.label, v),
            getLabel: (v) => v,
          ));
          if (!isLastSelect) rows.add(const AppDivider());
        }
      }
    }
    return rows;
  }
}
