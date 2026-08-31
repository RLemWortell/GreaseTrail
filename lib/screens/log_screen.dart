import 'package:flutter/material.dart';

import '../format.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/photos.dart';
import '../widgets/ui.dart';

class _Entry {
  final LogEntry log;
  final Vehicle vehicle;
  _Entry(this.log, this.vehicle);
}

class LogScreen extends StatelessWidget {
  final List<Vehicle> vehicles;
  final ValueChanged<String> onOpenVehicle;
  final void Function(String vehicleId, String categoryId, String logId) onOpenLog;
  final void Function(String vehicleId, String logId) onDeleteLog;

  const LogScreen({
    super.key,
    required this.vehicles,
    required this.onOpenVehicle,
    required this.onOpenLog,
    required this.onDeleteLog,
  });

  Future<bool> _confirmDeleteLog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove this entry?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Remove', style: TextStyle(color: AppColors.of(ctx).alert))),
        ],
      ),
    );
    return confirmed == true;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final entries = vehicles.expand((v) => v.logs.map((l) => _Entry(l, v))).toList()
      ..sort((a, b) => DateTime.parse(b.log.date).compareTo(DateTime.parse(a.log.date)));

    return Container(
      color: c.bg,
      child: Column(
        children: [
          const ScreenHeader(title: 'Log'),
          Expanded(
            child: entries.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpace.side, vertical: AppSpace.rowY),
                    child: Text(
                      'Nothing logged yet — open a vehicle and tap a category to add the first entry.',
                      style: AppTypography.small.copyWith(color: c.muted),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpace.side, 12, AppSpace.side, 40),
                    children: [
                      AppCard(
                        children: [
                          for (var i = 0; i < entries.length; i++)
                            Dismissible(
                              key: ValueKey('log-${entries[i].log.id}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                color: c.alert,
                                child: const Icon(Icons.delete_outline, color: Colors.white),
                              ),
                              confirmDismiss: (_) => _confirmDeleteLog(context),
                              onDismissed: (_) => onDeleteLog(entries[i].vehicle.id, entries[i].log.id),
                              child: CardRow(
                                onPress: () => onOpenLog(entries[i].vehicle.id, entries[i].log.categoryId, entries[i].log.id),
                                dotColor: entries[i].vehicle.color ?? c.accent,
                                left: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText.row(entries[i].log.categoryName, color: c.ink),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: AppText.small(_subtitle(entries[i]), color: c.muted),
                                    ),
                                    PhotoThumbs(uris: entries[i].log.photos),
                                  ],
                                ),
                                right: formatDate(entries[i].log.date),
                                divider: i < entries.length - 1,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _subtitle(_Entry e) {
    final l = e.log;
    final line = formatLogLine(e.vehicle, l);
    return [
      if (l.service != null) l.service,
      '${e.vehicle.name}  ·  ${formatOdo(l.odometer)} km',
      if (line.isNotEmpty) line,
      if (l.note.isNotEmpty) l.note,
    ].join('  ·  ');
  }
}
