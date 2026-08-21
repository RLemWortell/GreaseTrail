import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui.dart';

class AddVehicleScreen extends StatefulWidget {
  final VoidCallback onBack;
  final ValueChanged<Vehicle> onSave;

  const AddVehicleScreen({super.key, required this.onBack, required this.onSave});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  String _type = 'motorcycle';
  String _name = '';
  String _model = '';
  String _odo = '';

  @override
  Widget build(BuildContext context) {
    final types = typeMeta.keys.toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.side),
          child: TopBar(title: 'Add vehicle', onBack: widget.onBack),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.side, 0, AppSpace.side, 32),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              OptionList<String>(
                options: types,
                value: _type,
                onChanged: (t) => setState(() => _type = t),
                getLabel: (t) => typeMeta[t]!.label,
              ),
              AppField(label: 'Name', value: _name, placeholder: 'Suzuki V-Strom', onChanged: (v) => setState(() => _name = v)),
              AppField(label: 'Model', value: _model, placeholder: 'DL650', onChanged: (v) => setState(() => _model = v)),
              AppField(
                label: 'Odometer',
                value: _odo,
                placeholder: '0',
                unit: 'km',
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => _odo = v),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 28),
                child: ActionRow(
                  label: 'Create vehicle',
                  onPressed: () {
                    if (_name.trim().isEmpty) return;
                    widget.onSave(seedVehicle(_type, _name.trim(), _model.trim(), double.tryParse(_odo) ?? 0));
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
