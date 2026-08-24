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

enum _Step { type, config, details, photos }

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
  int _stepIndex = 0;

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

  bool get _canCreate => _name.trim().isNotEmpty;

  void _create() {
    if (!_canCreate) return;
    final cfg = _configId != 'default' ? widget.configs.where((x) => x.id == _configId).firstOrNull : null;
    final v = cfg != null
        ? vehicleFromConfig(cfg, _name.trim(), _model.trim(), double.tryParse(_odo) ?? 0)
        : seedVehicle(_type, _name.trim(), _model.trim(), double.tryParse(_odo) ?? 0);
    widget.onSave(v.copyWith(photos: _photos));
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final typeOptions = typeMeta.keys.toList();
    final configOptions = [
      const _ConfigOption('default', 'Default for type'),
      for (final cfg in widget.configs.where((cfg) => cfg.type == _type && !cfg.builtin)) _ConfigOption(cfg.id, cfg.name),
    ];
    final steps = [
      _Step.type,
      if (configOptions.length > 1) _Step.config,
      _Step.details,
      _Step.photos,
    ];
    final stepIndex = _stepIndex < steps.length ? _stepIndex : steps.length - 1;
    final step = steps[stepIndex];
    final selectedConfigLabel = configOptions.firstWhere((o) => o.id == _configId, orElse: () => configOptions.first).name;

    void goToStep(int i) => setState(() => _stepIndex = i);
    void goBack() => stepIndex == 0 ? widget.onBack() : goToStep(stepIndex - 1);
    void goNext() => stepIndex == steps.length - 1 ? _create() : goToStep(stepIndex + 1);

    late final String stepTitle;
    late final Widget stepBody;
    Widget? footer;

    switch (step) {
      case _Step.type:
        stepTitle = 'What are you adding?';
        stepBody = _TypeGrid(
          options: typeOptions,
          value: _type,
          onSelected: (t) {
            _selectType(t);
            goToStep(stepIndex + 1);
          },
        );
      case _Step.config:
        stepTitle = 'Starting point';
        stepBody = AppCard(
          children: [
            OptionList<_ConfigOption>(
              options: configOptions,
              value: configOptions.firstWhere((o) => o.id == _configId, orElse: () => configOptions.first),
              onChanged: (o) {
                setState(() => _configId = o.id);
                goToStep(stepIndex + 1);
              },
              getLabel: (o) => o.name,
            ),
          ],
        );
      case _Step.details:
        stepTitle = 'Tell us about it';
        stepBody = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SummarySelection(type: _type, configLabel: selectedConfigLabel, onEdit: () => goToStep(0)),
            AppCard(children: [
              AppField(label: 'Name', value: _name, placeholder: 'e.g. Suzuki V-Strom', onChanged: (v) => setState(() => _name = v)),
              AppField(label: 'Model', value: _model, placeholder: 'e.g. DL650', onChanged: (v) => _model = v),
              AppField(
                label: 'Odometer',
                value: _odo,
                placeholder: '0',
                unit: 'km',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                last: true,
                onChanged: (v) => _odo = v,
              ),
            ]),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Standard categories come from the selected config. You can change them later.',
                style: AppTypography.small.copyWith(color: c.muted, height: 1.35),
              ),
            ),
          ],
        );
        footer = PrimaryButton(label: 'Next', onPressed: _canCreate ? goNext : null);
      case _Step.photos:
        stepTitle = 'Add a photo';
        stepBody = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SummarySelection(type: _type, configLabel: selectedConfigLabel, onEdit: () => goToStep(0)),
            AppCard(
              padding: const EdgeInsets.all(AppSpace.cardPad),
              children: [PhotoStrip(uris: _photos, editable: true, onChange: (p) => setState(() => _photos = p))],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Optional — you can add or change photos later.', style: AppTypography.small.copyWith(color: c.muted)),
            ),
          ],
        );
        footer = PrimaryButton(label: 'Create vehicle', onPressed: _create);
    }

    return Container(
      color: c.bg,
      child: Column(
        children: [
          TopBar(title: 'Add vehicle', onBack: goBack),
          _StepProgress(current: stepIndex, total: steps.length),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpace.side, 8, AppSpace.side, 32),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                Padding(padding: const EdgeInsets.only(bottom: 18), child: AppText.category(stepTitle, color: c.ink)),
                stepBody,
              ],
            ),
          ),
          if (footer != null)
            Container(
              padding: const EdgeInsets.fromLTRB(AppSpace.side, 14, AppSpace.side, 14),
              decoration: BoxDecoration(color: c.bg, border: Border(top: BorderSide(color: c.hairline, width: AppSpace.hairline))),
              child: footer,
            ),
        ],
      ),
    );
  }
}

/// Thin segmented bar showing progress through the wizard's steps.
class _StepProgress extends StatelessWidget {
  final int current;
  final int total;
  const _StepProgress({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpace.side, 0, AppSpace.side, 16),
      child: Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: i <= current ? c.accent : c.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A recap of the type/config already chosen, shown above later steps with a
/// quick way back to the type step to change them.
class _SummarySelection extends StatelessWidget {
  final String type;
  final String configLabel;
  final VoidCallback onEdit;
  const _SummarySelection({required this.type, required this.configLabel, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final meta = typeMeta[type]!;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.block),
      child: Row(
        children: [
          TypeIcon(type: type, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.row(meta.label, color: c.ink),
                Padding(padding: const EdgeInsets.only(top: 2), child: AppText.small(configLabel, color: c.muted)),
              ],
            ),
          ),
          GestureDetector(onTap: onEdit, child: AppText.label('Change', color: c.accent)),
        ],
      ),
    );
  }
}

class _TypeGrid extends StatelessWidget {
  final List<String> options;
  final String value;
  final ValueChanged<String> onSelected;
  const _TypeGrid({required this.options, required this.value, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        for (final t in options)
          _TypeCard(
            label: typeMeta[t]!.label,
            icon: typeMeta[t]!.icon,
            selected: t == value,
            onTap: () => onSelected(t),
          ),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _TypeCard({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpace.radius),
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(AppSpace.radius),
          border: Border.all(color: selected ? c.accent : c.hairline, width: selected ? 1.5 : 1),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? c.accent : c.iconBg),
              alignment: Alignment.center,
              child: Icon(icon, size: 26, color: c.iconFg),
            ),
            const SizedBox(height: 12),
            AppText.row(label, color: c.ink),
          ],
        ),
      ),
    );
  }
}
