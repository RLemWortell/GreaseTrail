import 'package:flutter/material.dart';

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

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';

  List<Vehicle> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.vehicles;
    return widget.vehicles.where((v) => v.name.toLowerCase().contains(q) || v.model.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final attention = filtered.expand(getAttentionItems).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.side, 6, AppSpace.side, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.date(formatHeaderDate(), color: AppColors.muted),
                  PlusButton(onPressed: widget.onAddVehicle),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: AppText.title('GARAGE', color: AppColors.ink),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: VehicleSearchField(value: _query, onChanged: (v) => setState(() => _query = v)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.side, 18, AppSpace.side, 28),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              for (var i = 0; i < filtered.length; i++) ...[
                _VehicleCard(vehicle: filtered[i], onTap: () => widget.onOpenVehicle(filtered[i].id)),
                if (i < filtered.length - 1) const SizedBox(height: 12),
              ],
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    widget.vehicles.isEmpty ? 'No vehicles yet.' : 'No matches.',
                    style: const TextStyle(color: AppColors.muted, fontSize: 14),
                  ),
                ),
              if (attention.isNotEmpty) ...[
                const SizedBox(height: 32),
                Row(
                  children: [
                    AppText.label('Needs attention', color: AppColors.muted),
                    const SizedBox(width: 8),
                    Expanded(child: Container(height: AppSpace.hairline, color: AppColors.ink.withValues(alpha: 0.85))),
                  ],
                ),
                AppCard(
                  margin: const EdgeInsets.only(top: 14),
                  children: [
                    for (var i = 0; i < attention.length; i++)
                      InkWell(
                        onTap: () => widget.onOpenCategory(attention[i].vehicleId, attention[i].categoryId),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: i < attention.length - 1
                                ? const Border(bottom: BorderSide(color: AppColors.hairline, width: AppSpace.hairline))
                                : null,
                          ),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 52),
                            padding: const EdgeInsets.symmetric(vertical: AppSpace.rowY),
                            child: Row(
                              children: [
                                StatusDot(level: attention[i].level),
                                const SizedBox(width: 12),
                                Expanded(child: AppText.row(attention[i].name, color: AppColors.ink)),
                                AppText.small(attention[i].label, color: AppColors.muted, letterSpacing: 0.6, upper: true),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const _VehicleCard({required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final meta = typeMeta[vehicle.type];
    final statuses = vehicle.categories.map((c) => getStatus(vehicle, c)).whereType<CategoryStatus>().toList();
    final overdue = statuses.where((s) => s.level == DueLevel.overdue).length;
    final soon = statuses.where((s) => s.level == DueLevel.soon).length;

    return AppCard(
      onTap: onTap,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.hairline, width: AppSpace.hairline)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.iconBg, borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Icon(meta?.icon ?? Icons.directions_car, size: 20, color: AppColors.iconFg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.name(vehicle.name, color: AppColors.ink),
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: AppText.meta(
                        vehicle.model.isNotEmpty ? '${vehicle.model}  ·  ${meta?.label ?? vehicle.type}' : (meta?.label ?? vehicle.type),
                        color: AppColors.muted,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.label('Odometer', color: AppColors.muted),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: AppText.odometer('${formatKm(vehicle.odometer)} km', color: AppColors.ink),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (overdue > 0) _StatusLine(color: AppColors.accent, text: '$overdue overdue'),
                    if (overdue > 0 && soon > 0) const SizedBox(height: 8),
                    if (soon > 0) _StatusLine(color: AppColors.soon, text: '$soon due soon'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusLine extends StatelessWidget {
  final Color color;
  final String text;
  const _StatusLine({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.1, color: color),
        ),
      ],
    );
  }
}
