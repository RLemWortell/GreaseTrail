import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/ui.dart';

class _Entry {
  final LogEntry log;
  final String vehicleId;
  final String vehicleName;
  _Entry(this.log, this.vehicleId, this.vehicleName);
}

class LogScreen extends StatelessWidget {
  final List<Vehicle> vehicles;
  final ValueChanged<String> onOpenVehicle;

  const LogScreen({super.key, required this.vehicles, required this.onOpenVehicle});

  @override
  Widget build(BuildContext context) {
    final entries = vehicles.expand((v) => v.logs.map((l) => _Entry(l, v.id, v.name))).toList()
      ..sort((a, b) => DateTime.parse(b.log.date).compareTo(DateTime.parse(a.log.date)));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpace.side, 6, AppSpace.side, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.date(formatHeaderDate(), color: AppColors.muted),
              Padding(padding: const EdgeInsets.only(top: 10), child: AppText.title('LOG', color: AppColors.ink)),
            ],
          ),
        ),
        Expanded(
          child: entries.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpace.side),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text('Nothing logged yet.', style: TextStyle(color: AppColors.muted, fontSize: 14)),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpace.side, 18, AppSpace.side, 28),
                  children: [
                    AppCard(
                      children: [
                        for (var i = 0; i < entries.length; i++)
                          InkWell(
                            onTap: () => onOpenVehicle(entries[i].vehicleId),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: AppSpace.rowY),
                              decoration: BoxDecoration(
                                border: i < entries.length - 1
                                    ? const Border(bottom: BorderSide(color: AppColors.hairline, width: AppSpace.hairline))
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: AppText.row(entries[i].log.categoryName, color: AppColors.ink)),
                                      const SizedBox(width: 12),
                                      AppText.small(entries[i].log.date, color: AppColors.muted),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: AppText.small(
                                      '${entries[i].vehicleName}  ·  ${formatKm(entries[i].log.odometer)} km',
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
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
