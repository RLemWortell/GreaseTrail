import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/ui.dart';

class SetupScreen extends StatelessWidget {
  final List<Vehicle> vehicles;
  final VoidCallback onAddVehicle;
  final ValueChanged<String> onManageVehicle;

  const SetupScreen({super.key, required this.vehicles, required this.onAddVehicle, required this.onManageVehicle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.side, 6, AppSpace.side, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.date(formatHeaderDate(), color: AppColors.muted),
              Padding(padding: const EdgeInsets.only(top: 10), child: AppText.title('SETUP', color: AppColors.ink)),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpace.side, 18, AppSpace.side, 28),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    AppText.label('Vehicles', color: AppColors.muted),
                    const SizedBox(width: 12),
                    Expanded(child: Container(height: AppSpace.hairline, color: AppColors.ink.withValues(alpha: 0.85))),
                  ],
                ),
              ),
              if (vehicles.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text('No vehicles yet.', style: TextStyle(color: AppColors.muted, fontSize: 14)),
                )
              else
                AppCard(
                  margin: const EdgeInsets.only(bottom: 24),
                  children: [
                    for (var i = 0; i < vehicles.length; i++)
                      InkWell(
                        onTap: () => onManageVehicle(vehicles[i].id),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 56),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: AppSpace.rowY),
                          decoration: BoxDecoration(
                            border: i < vehicles.length - 1
                                ? const Border(bottom: BorderSide(color: AppColors.hairline, width: AppSpace.hairline))
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AppText.row(vehicles[i].name, color: AppColors.ink),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: AppText.small(
                                        vehicles[i].model.isNotEmpty
                                            ? '${typeMeta[vehicles[i].type]?.label ?? vehicles[i].type}  ·  ${vehicles[i].model}'
                                            : (typeMeta[vehicles[i].type]?.label ?? vehicles[i].type),
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ActionRow(label: 'Add vehicle', onPressed: onAddVehicle),
            ],
          ),
        ),
      ],
    );
  }
}
