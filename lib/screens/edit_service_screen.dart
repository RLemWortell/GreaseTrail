import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/ui.dart';

class EditServiceScreen extends StatefulWidget {
  final Vehicle vehicle;
  final String? serviceId;
  final VoidCallback onBack;
  final ValueChanged<Vehicle> onUpdateVehicle;

  const EditServiceScreen({super.key, required this.vehicle, this.serviceId, required this.onBack, required this.onUpdateVehicle});

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  ServicePackage? _existing;
  late String _name;
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _existing = widget.serviceId != null
        ? getServiceRecords(widget.vehicle).where((s) => s.id == widget.serviceId).firstOrNull
        : null;
    _name = _existing?.name ?? '';
    _selected = {...(_existing?.categoryIds ?? const [])};
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  void _save() {
    final trimmed = _name.trim();
    if (trimmed.isEmpty) return;
    final categoryIds = widget.vehicle.categories.map((c) => c.id).where(_selected.contains).toList();
    if (categoryIds.isEmpty) return;
    widget.onUpdateVehicle(upsertService(widget.vehicle, ServicePackage(id: _existing?.id, name: trimmed, categoryIds: categoryIds)));
    widget.onBack();
  }

  Future<void> _remove() async {
    final existing = _existing;
    if (existing == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove "${existing.name}"?'),
        content: const Text('This only removes the checklist, not your log history.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Remove', style: TextStyle(color: AppColors.of(ctx).alert))),
        ],
      ),
    );
    if (confirmed == true) {
      widget.onUpdateVehicle(removeService(widget.vehicle, existing.id));
      widget.onBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final categories = widget.vehicle.categories;

    return Container(
      color: c.bg,
      child: Column(
        children: [
          TopBar(title: _existing != null ? 'Edit service' : 'New service', onBack: widget.onBack),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpace.side, 12, AppSpace.side, 40),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                AppCard(children: [
                  AppField(label: 'Name', value: _name, placeholder: 'e.g. Chain weekend', last: true, onChanged: (v) => _name = v),
                ]),
                const SizedBox(height: AppSpace.block),
                const Label('Items', margin: EdgeInsets.only(bottom: 10)),
                if (categories.isEmpty)
                  Text('Add categories first, then pick them here.', style: AppTypography.small.copyWith(color: c.muted))
                else
                  AppCard(children: [
                    for (var i = 0; i < categories.length; i++)
                      CheckRow(
                        label: categories[i].name,
                        checked: _selected.contains(categories[i].id),
                        onToggle: () => _toggle(categories[i].id),
                        last: i == categories.length - 1,
                      ),
                  ]),
                ActionRow(label: 'Save service', onPressed: _save),
                if (_existing != null) ActionRow(label: 'Remove service', onPressed: _remove, destructive: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
