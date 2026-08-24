import 'package:flutter/material.dart';

import '../data/export.dart';
import '../format.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/photos.dart';
import '../widgets/ui.dart';

class VehicleScreen extends StatefulWidget {
  final Vehicle vehicle;
  final VoidCallback onBack;
  final ValueChanged<String> onOpenCategory;
  final VoidCallback onManage;
  final ValueChanged<double> onUpdateOdo;
  final ValueChanged<String> onOpenService;
  final VoidCallback onAddService;
  final ValueChanged<List<String>> onUpdatePhotos;

  const VehicleScreen({
    super.key,
    required this.vehicle,
    required this.onBack,
    required this.onOpenCategory,
    required this.onManage,
    required this.onUpdateOdo,
    required this.onOpenService,
    required this.onAddService,
    required this.onUpdatePhotos,
  });

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  late TextEditingController _odoController;
  final _odoFocus = FocusNode();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _odoController = TextEditingController(text: widget.vehicle.odometer.round().toString());
    _odoFocus.addListener(() {
      if (!_odoFocus.hasFocus) widget.onUpdateOdo(double.tryParse(_odoController.text) ?? 0);
    });
  }

  @override
  void dispose() {
    _odoController.dispose();
    _odoFocus.dispose();
    super.dispose();
  }

  Future<void> _exportPdf() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await exportPdf([widget.vehicle], context);
    } catch (e) {
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Export failed'),
            content: Text('$e'),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final vehicle = widget.vehicle;
    final allLogs = [...vehicle.logs]..sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
    final label = typeMeta[vehicle.type]?.label ?? vehicle.type;
    final subtitle = vehicle.model.isNotEmpty ? '${vehicle.model}  ·  $label' : label;
    final packages = getServicePackages(vehicle);

    return Container(
      color: c.bg,
      child: Column(
        children: [
          TopBar(title: vehicle.name, subtitle: subtitle, onBack: widget.onBack, rightLabel: 'Edit', onRightPress: widget.onManage),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpace.side, 12, AppSpace.side, 40),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                AppCard(
                  padding: const EdgeInsets.fromLTRB(AppSpace.cardPad, 14, AppSpace.cardPad, 16),
                  children: [
                    AppText.label('Odometer', color: c.muted),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        SizedBox(
                          width: 140,
                          child: TextField(
                            controller: _odoController,
                            focusNode: _odoFocus,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            style: AppTypography.odometer.copyWith(color: c.ink),
                            decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none),
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppText.body('km', color: c.muted),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.block),
                const Label('Photos', margin: EdgeInsets.only(bottom: 10)),
                AppCard(
                  padding: const EdgeInsets.all(AppSpace.cardPad),
                  children: [PhotoStrip(uris: vehicle.photos, editable: true, onChange: widget.onUpdatePhotos)],
                ),
                const SizedBox(height: AppSpace.block),
                const SectionHeader('Service'),
                AppCard(
                  margin: const EdgeInsets.only(top: 14),
                  children: [
                    for (final pack in packages)
                      CardRow(
                        onPress: () => widget.onOpenService(pack.id),
                        chevron: true,
                        left: pack.name,
                        right: '${pack.categories.length} items',
                      ),
                    CardRow(onPress: widget.onAddService, left: AppText.meta('+ Add service', color: c.ink), divider: false),
                  ],
                ),
                const SizedBox(height: AppSpace.block),
                const SectionHeader('Categories'),
                AppCard(
                  margin: const EdgeInsets.only(top: 14),
                  children: [
                    for (var i = 0; i < vehicle.categories.length; i++)
                      CardRow(
                        onPress: () => widget.onOpenCategory(vehicle.categories[i].id),
                        dot: getStatus(vehicle, vehicle.categories[i])?.level == DueLevel.overdue
                            ? null
                            : getStatus(vehicle, vehicle.categories[i])?.level,
                        dotColor: getStatus(vehicle, vehicle.categories[i])?.level == DueLevel.overdue ? (vehicle.color ?? c.accent) : null,
                        chevron: true,
                        divider: i < vehicle.categories.length - 1,
                        left: _CategorySummary(vehicle: vehicle, category: vehicle.categories[i]),
                        right: getStatus(vehicle, vehicle.categories[i]) != null ? attentionLabel(vehicle, vehicle.categories[i]) : null,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpace.block),
                const SectionHeader('History'),
                if (allLogs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpace.rowY),
                    child: Text('Nothing logged yet — tap a category to add the first entry.', style: AppTypography.small.copyWith(color: c.muted)),
                  )
                else
                  AppCard(
                    margin: const EdgeInsets.only(top: 14),
                    children: [
                      for (var i = 0; i < allLogs.length; i++)
                        CardRow(
                          divider: i < allLogs.length - 1,
                          left: _LogSummary(vehicle: vehicle, log: allLogs[i]),
                          right: formatDate(allLogs[i].date),
                        ),
                    ],
                  ),
                const SizedBox(height: AppSpace.block),
                const SectionHeader('Export'),
                AppCard(
                  margin: const EdgeInsets.only(top: 14),
                  children: [
                    CardRow(onPress: _exportPdf, chevron: true, left: 'PDF report', right: _busy ? '…' : null, divider: false),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySummary extends StatelessWidget {
  final Vehicle vehicle;
  final Category category;
  const _CategorySummary({required this.vehicle, required this.category});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final status = getStatus(vehicle, category);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.row(category.name, color: c.ink),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: AppText.small(
            status?.last != null
                ? 'Last  ·  ${formatDate(status!.last!.date)}  ·  ${formatOdo(status.last!.odometer)} km'
                : 'No entries yet',
            color: c.muted,
          ),
        ),
      ],
    );
  }
}

class _LogSummary extends StatelessWidget {
  final Vehicle vehicle;
  final LogEntry log;
  const _LogSummary({required this.vehicle, required this.log});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final line = formatLogLine(vehicle, log);
    final subtitle = [
      if (log.service != null) log.service,
      '${formatOdo(log.odometer)} km',
      if (line.isNotEmpty) line,
      if (log.note.isNotEmpty) log.note,
    ].join('  ·  ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.row(log.categoryName, color: c.ink),
        Padding(padding: const EdgeInsets.only(top: 2), child: AppText.small(subtitle, color: c.muted)),
        PhotoThumbs(uris: log.photos),
      ],
    );
  }
}
