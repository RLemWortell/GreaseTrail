import 'package:flutter/material.dart';

import '../format.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/ui.dart';

class HomeScreen extends StatefulWidget {
  final List<Vehicle> vehicles;
  final ValueChanged<String> onOpenVehicle;
  final VoidCallback onAddVehicle;
  final void Function(String vehicleId, String categoryId) onOpenCategory;

  const HomeScreen({
    super.key,
    required this.vehicles,
    required this.onOpenVehicle,
    required this.onAddVehicle,
    required this.onOpenCategory,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _AttentionRow {
  final AttentionItem item;
  final String vehicleId;
  final String vehicleName;
  final Color? vehicleColor;
  _AttentionRow(this.item, this.vehicleId, this.vehicleName, this.vehicleColor);
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';

  List<Vehicle> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.vehicles;
    return widget.vehicles.where((v) => v.name.toLowerCase().contains(q) || v.model.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final filtered = _filtered;
    final attention = filtered.expand((v) => getAttentionItems(v).map((item) => _AttentionRow(item, v.id, v.name, v.color))).toList();

    return Container(
      color: c.bg,
      child: Column(
        children: [
          ScreenHeader(title: 'Garage', onRightPress: widget.onAddVehicle, rightIcon: Icons.add),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.side),
            child: AppSearchBar(value: _query, onChanged: (v) => setState(() => _query = v), placeholder: 'Search vehicles'),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpace.side, 20, AppSpace.side, 40),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                for (final v in filtered) _VehicleCard(vehicle: v, onTap: () => widget.onOpenVehicle(v.id)),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpace.rowY),
                    child: Text(
                      widget.vehicles.isEmpty ? 'No vehicles yet — tap + to add one.' : 'No matches.',
                      style: AppTypography.small.copyWith(color: c.muted),
                    ),
                  ),
                if (attention.isNotEmpty) ...[
                  SizedBox(height: AppSpace.block),
                  const SectionHeader('Needs attention'),
                  AppCard(
                    margin: const EdgeInsets.only(top: 14),
                    children: [
                      for (var i = 0; i < attention.length; i++)
                        CardRow(
                          onPress: () => widget.onOpenCategory(attention[i].vehicleId, attention[i].item.id),
                          dotColor: attention[i].item.level == DueLevel.overdue ? (attention[i].vehicleColor ?? c.accent) : c.soon,
                          left: filtered.length > 1 ? '${attention[i].vehicleName} · ${attention[i].item.name}' : attention[i].item.name,
                          right: attention[i].item.label,
                          divider: i < attention.length - 1,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const _VehicleCard({required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final counts = countAttention(vehicle);
    final label = typeMeta[vehicle.type]?.label ?? vehicle.type;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpace.radius),
        child: AppCard(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.cardPad, 16, AppSpace.cardPad, 14),
              child: Row(
                children: [
                  TypeIcon(type: vehicle.type, photo: vehicle.photos.isNotEmpty ? vehicle.photos.first : null, color: vehicle.color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.title(vehicle.name, color: c.ink),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: AppText.label(vehicle.model.isNotEmpty ? '${vehicle.model}  ·  $label' : label, color: c.muted),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 16, color: c.faint),
                ],
              ),
            ),
            Container(height: AppSpace.hairline, color: c.hairline, margin: const EdgeInsets.symmetric(horizontal: AppSpace.cardPad)),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpace.cardPad, 14, AppSpace.cardPad, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(padding: const EdgeInsets.only(bottom: 4), child: AppText.label('Odometer', color: c.muted)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          AppText.odometer(formatOdo(vehicle.odometer), color: c.ink),
                          const SizedBox(width: 6),
                          AppText.body('km', color: c.muted),
                        ],
                      ),
                    ],
                  ),
                  if (counts.overdue > 0 || counts.soon > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (counts.overdue > 0) AppText.meta('·  ${counts.overdue} overdue', color: vehicle.color ?? c.accent),
                          if (counts.overdue > 0 && counts.soon > 0) const SizedBox(height: 6),
                          if (counts.soon > 0) AppText.meta('·  ${counts.soon} due soon', color: c.soon),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
