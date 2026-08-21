import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui.dart';

class VehicleScreen extends StatefulWidget {
  final Vehicle vehicle;
  final VoidCallback onBack;
  final ValueChanged<String> onOpenCategory;
  final VoidCallback onManage;
  final ValueChanged<double> onUpdateOdo;

  const VehicleScreen({
    super.key,
    required this.vehicle,
    required this.onBack,
    required this.onOpenCategory,
    required this.onManage,
    required this.onUpdateOdo,
  });

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  late String _odoInput;

  @override
  void initState() {
    super.initState();
    _odoInput = widget.vehicle.odometer.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.vehicle;
    final allLogs = [...vehicle.logs]..sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.side),
          child: TopBar(
            title: vehicle.name,
            onBack: widget.onBack,
            right: TopBarIconButton(icon: Icons.settings_outlined, onPressed: widget.onManage),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.side, 0, AppSpace.side, 32),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Padding(padding: const EdgeInsets.only(top: 4), child: AppText.label('Odometer', color: AppColors.muted)),
              AppField(
                label: 'Reading',
                value: _odoInput,
                unit: 'km',
                keyboardType: TextInputType.number,
                emphasis: true,
                onChanged: (v) => _odoInput = v,
                onBlur: () => widget.onUpdateOdo(double.tryParse(_odoInput) ?? 0),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32, bottom: 12),
                child: Row(
                  children: [
                    AppText.label('Categories', color: AppColors.muted),
                    const SizedBox(width: 12),
                    Expanded(child: Container(height: AppSpace.hairline, color: AppColors.ink.withValues(alpha: 0.85))),
                  ],
                ),
              ),
              AppCard(
                children: [
                  for (var i = 0; i < vehicle.categories.length; i++)
                    InkWell(
                      onTap: () => widget.onOpenCategory(vehicle.categories[i].id),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 52),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: AppSpace.rowY),
                        decoration: BoxDecoration(
                          border: i < vehicle.categories.length - 1
                              ? const Border(bottom: BorderSide(color: AppColors.hairline, width: AppSpace.hairline))
                              : null,
                        ),
                        child: Row(
                          children: [
                            StatusDot(level: (getStatus(vehicle, vehicle.categories[i])?.level) ?? DueLevel.none),
                            const SizedBox(width: 12),
                            Expanded(child: AppText.row(vehicle.categories[i].name, color: AppColors.ink)),
                            AppText.small(
                              getStatus(vehicle, vehicle.categories[i]) != null ? getDueLabel(vehicle, vehicle.categories[i]) : '',
                              color: AppColors.muted,
                              letterSpacing: 0.6,
                              upper: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32, bottom: 12),
                child: Row(
                  children: [
                    AppText.label('History', color: AppColors.muted),
                    const SizedBox(width: 12),
                    Expanded(child: Container(height: AppSpace.hairline, color: AppColors.ink.withValues(alpha: 0.85))),
                  ],
                ),
              ),
              if (allLogs.isEmpty)
                const Text('Nothing logged yet.', style: TextStyle(color: AppColors.muted, fontSize: 14))
              else
                AppCard(
                  children: [
                    for (var i = 0; i < allLogs.length; i++)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: i < allLogs.length - 1
                              ? const Border(bottom: BorderSide(color: AppColors.hairline, width: AppSpace.hairline))
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText.row(allLogs[i].categoryName, color: AppColors.ink),
                                AppText.small(allLogs[i].date, color: AppColors.muted),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: AppText.small(
                                '${formatKm(allLogs[i].odometer)} km'
                                '${allLogs[i].values.entries.where((e) => e.value.isNotEmpty).map((e) => '  ·  ${e.key}: ${e.value}').join()}',
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
