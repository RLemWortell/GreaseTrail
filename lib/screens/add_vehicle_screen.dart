import 'package:flutter/material.dart';

import '../data/config.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/photos.dart';
import '../widgets/ui.dart';

class _ConfigOption {
  final String id;
  final String name;
  const _ConfigOption(this.id, this.name);
}

class AddVehicleScreen extends StatefulWidget {
  final VoidCallback onBack;
  final ValueChanged<Vehicle> onSave;
  final List<GtConfig> configs;
  final String? initialConfigId;
  final String? initialType;

  const AddVehicleScreen({
    super.key,
    required this.onBack,
    required this.onSave,
    this.configs = const [],
    this.initialConfigId,
    this.initialType,
  });

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  late String _type;
  late String _configId;
  String _name = '';
  String _model = '';
  String _odo = '';
  List<String> _photos = [];

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? 'motorcycle';
    _configId = (widget.initialConfigId != null && widget.initialConfigId != 'default') ? widget.initialConfigId! : 'default';
  }

  void _selectType(String next) {
    final stillValid = _configId == 'default' || widget.configs.any((cfg) => cfg.id == _configId && cfg.type == next);
    setState(() {
      _type = next;
      if (!stillValid) _configId = 'default';
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final typeOptions = typeMeta.keys.toList();
    final configOptions = [
      const _ConfigOption('default', 'Default for type'),
      for (final cfg in widget.configs.where((cfg) => cfg.type == _type && !cfg.builtin)) _ConfigOption(cfg.id, cfg.name),
    ];

    return Container(
      color: c.bg,
      child: Column(
        children: [
          TopBar(title: 'Add vehicle', onBack: widget.onBack),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpace.side, 12, AppSpace.side, 40),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                const Label('Type', margin: EdgeInsets.only(bottom: 10)),
                AppCard(
                  children: [
                    OptionList<String>(
                      options: typeOptions,
                      value: _type,
                      onChanged: _selectType,
                      getLabel: (t) => typeMeta[t]!.label,
                    ),
                  ],
                ),
                if (configOptions.length > 1) ...[
                  const SizedBox(height: AppSpace.block),
                  const Label('Config', margin: EdgeInsets.only(bottom: 10)),
                  AppCard(
                    children: [
                      OptionList<_ConfigOption>(
                        options: configOptions,
                        value: configOptions.firstWhere((o) => o.id == _configId, orElse: () => configOptions.first),
                        onChanged: (o) => setState(() => _configId = o.id),
                        getLabel: (o) => o.name,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpace.block),
                AppCard(children: [
                  AppField(label: 'Name', value: _name, placeholder: 'e.g. Suzuki V-Strom', onChanged: (v) => _name = v),
                  AppField(label: 'Model', value: _model, placeholder: 'e.g. DL650', onChanged: (v) => _model = v),
                  AppField(
                    label: 'Odometer',
                    value: _odo,
                    placeholder: '0',
                    unit: 'km',
                    keyboardType: TextInputType.number,
                    last: true,
                    onChanged: (v) => _odo = v,
                  ),
                ]),
                const SizedBox(height: AppSpace.block),
                const Label('Photos', margin: EdgeInsets.only(bottom: 10)),
                AppCard(
                  padding: const EdgeInsets.all(AppSpace.cardPad),
                  children: [PhotoStrip(uris: _photos, editable: true, onChange: (p) => setState(() => _photos = p))],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Standard categories come from the selected config. You can change them later.',
                    style: AppTypography.small.copyWith(color: c.muted, height: 1.35),
                  ),
                ),
                ActionRow(
                  label: 'Create vehicle',
                  onPressed: () {
                    if (_name.trim().isEmpty) return;
                    final cfg = _configId != 'default' ? widget.configs.where((x) => x.id == _configId).firstOrNull : null;
                    final v = cfg != null
                        ? vehicleFromConfig(cfg, _name.trim(), _model.trim(), double.tryParse(_odo) ?? 0)
                        : seedVehicle(_type, _name.trim(), _model.trim(), double.tryParse(_odo) ?? 0);
                    widget.onSave(v.copyWith(photos: _photos));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
