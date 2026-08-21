import 'package:flutter/material.dart';

import '../data/config.dart';
import '../data/export.dart';
import '../format.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/ui.dart';

class SetupScreen extends StatefulWidget {
  final List<Vehicle> vehicles;
  final List<GtConfig> configs;
  final ValueChanged<List<GtConfig>> onConfigsChange;
  final ValueChanged<String> onManage;
  final VoidCallback onAddVehicle;
  final ValueChanged<GtConfig> onCreateFromConfig;

  const SetupScreen({
    super.key,
    required this.vehicles,
    required this.configs,
    required this.onConfigsChange,
    required this.onManage,
    required this.onAddVehicle,
    required this.onCreateFromConfig,
  });

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  String? _busy;
  String? _openId;
  bool _pdfPick = false;

  Future<void> _notify(String title, String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  Future<void> _runExport(String kind, Future<void> Function(List<Vehicle>, BuildContext) fn) async {
    if (_busy != null) return;
    if (widget.vehicles.isEmpty) {
      await _notify('Export', 'Add a vehicle first.');
      return;
    }
    setState(() => _busy = kind);
    try {
      await fn(widget.vehicles, context);
    } catch (e) {
      await _notify('Export failed', '$e');
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  void _duplicate(GtConfig cfg) {
    final copy = duplicateConfig(cfg);
    widget.onConfigsChange([...widget.configs, copy]);
    setState(() => _openId = copy.id);
  }

  Future<void> _remove(GtConfig cfg) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove "${cfg.name}"?'),
        content: const Text('Vehicles already created from it stay as they are.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Remove', style: TextStyle(color: AppColors.of(ctx).alert))),
        ],
      ),
    );
    if (confirmed == true) {
      widget.onConfigsChange(widget.configs.where((x) => x.id != cfg.id).toList());
      setState(() => _openId = null);
    }
  }

  Future<void> _importFile() async {
    try {
      final cfg = await importConfigFile();
      if (cfg == null) return;
      widget.onConfigsChange([...widget.configs, cfg]);
      setState(() => _openId = cfg.id);
    } catch (e) {
      await _notify('Import failed', '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final all = [...builtinConfigs(), ...widget.configs];
    final open = all.where((cfg) => cfg.id == _openId).firstOrNull;

    return Container(
      color: c.bg,
      child: Column(
        children: [
          ScreenHeader(title: 'Setup', onRightPress: widget.onAddVehicle, rightIcon: Icons.add),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(AppSpace.side, 12, AppSpace.side, 40),
              children: [
                const SectionHeader('Vehicles'),
                if (widget.vehicles.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpace.rowY),
                    child: Text('No vehicles yet — tap + to add one.', style: AppTypography.small.copyWith(color: c.muted)),
                  )
                else
                  AppCard(
                    margin: const EdgeInsets.only(top: 14),
                    children: [
                      for (var i = 0; i < widget.vehicles.length; i++)
                        CardRow(
                          onPress: () => widget.onManage(widget.vehicles[i].id),
                          chevron: true,
                          divider: i < widget.vehicles.length - 1,
                          left: Row(
                            children: [
                              TypeIcon(
                                type: widget.vehicles[i].type,
                                size: 32,
                                photo: widget.vehicles[i].photos.isNotEmpty ? widget.vehicles[i].photos.first : null,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText.title(widget.vehicles[i].name, color: c.ink),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: AppText.small(
                                      '${widget.vehicles[i].model.isNotEmpty ? '${widget.vehicles[i].model}  ·  ' : ''}'
                                      '${typeMeta[widget.vehicles[i].type]?.label ?? widget.vehicles[i].type}  ·  '
                                      '${formatOdo(widget.vehicles[i].odometer)} km',
                                      color: c.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: AppSpace.block),
                const SectionHeader('Configs'),
                if (open != null) ...[
                  AppCard(
                    margin: const EdgeInsets.only(top: 14),
                    children: [
                      CardRow(onPress: () => setState(() => _openId = null), left: open.name, right: 'Close'),
                      CardRow(left: 'Type', right: typeMeta[open.type]?.label ?? open.type),
                      CardRow(left: 'Categories', right: '${open.categories.length}', divider: open.categories.isNotEmpty),
                      for (var i = 0; i < open.categories.length; i++)
                        CardRow(
                          left: open.categories[i].name,
                          right: open.categories[i].intervalKm != null
                              ? '${open.categories[i].intervalKm} km'
                              : open.categories[i].intervalMonths != null
                                  ? '${open.categories[i].intervalMonths} mo'
                                  : '',
                          divider: i < open.categories.length - 1,
                        ),
                    ],
                  ),
                  AppCard(
                    margin: const EdgeInsets.only(top: 12),
                    children: [
                      CardRow(onPress: () => widget.onCreateFromConfig(open), chevron: true, left: 'Create vehicle'),
                      CardRow(onPress: () => _duplicate(open), chevron: true, left: 'Duplicate'),
                      CardRow(
                        onPress: () => exportConfig(open, context).catchError((e) => _notify('Export failed', '$e')),
                        chevron: true,
                        left: 'Export',
                        divider: !open.builtin,
                      ),
                      if (!open.builtin) CardRow(onPress: () => _remove(open), left: 'Delete', divider: false),
                    ],
                  ),
                ] else ...[
                  AppCard(
                    margin: const EdgeInsets.only(top: 14),
                    children: [
                      for (var i = 0; i < all.length; i++)
                        CardRow(
                          onPress: () => setState(() => _openId = all[i].id),
                          chevron: true,
                          divider: i < all.length - 1,
                          left: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText.row(all[i].name, color: c.ink),
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: AppText.small(
                                  '${typeMeta[all[i].type]?.label ?? all[i].type}  ·  ${all[i].categories.length} categories'
                                  '${all[i].builtin ? '  ·  default' : ''}',
                                  color: c.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  AppCard(
                    margin: const EdgeInsets.only(top: 12),
                    children: [CardRow(onPress: _importFile, chevron: true, left: 'Import file', divider: false)],
                  ),
                ],
                const SizedBox(height: AppSpace.block),
                const SectionHeader('Export data'),
                AppCard(
                  margin: const EdgeInsets.only(top: 14),
                  children: [
                    CardRow(onPress: () => _runExport('json', exportJson), chevron: true, left: 'JSON backup', right: _busy == 'json' ? '…' : 'Full data'),
                    CardRow(onPress: () => _runExport('csv', exportCsv), chevron: true, left: 'CSV log', right: _busy == 'csv' ? '…' : 'Spreadsheet'),
                    CardRow(
                      onPress: () => setState(() => _pdfPick = !_pdfPick),
                      chevron: true,
                      left: 'PDF report',
                      right: _pdfPick ? 'Close' : 'Choose',
                      divider: false,
                    ),
                  ],
                ),
                if (_pdfPick)
                  AppCard(
                    margin: const EdgeInsets.only(top: 12),
                    children: [
                      CardRow(
                        onPress: () => _runExport('pdf-all', exportPdf),
                        chevron: true,
                        left: 'All vehicles',
                        right: _busy == 'pdf-all' ? '…' : null,
                        divider: widget.vehicles.isNotEmpty,
                      ),
                      for (var i = 0; i < widget.vehicles.length; i++)
                        CardRow(
                          onPress: () => _runExport('pdf-${widget.vehicles[i].id}', (vs, ctx) => exportPdf([widget.vehicles[i]], ctx)),
                          chevron: true,
                          left: widget.vehicles[i].name,
                          right: _busy == 'pdf-${widget.vehicles[i].id}' ? '…' : null,
                          divider: i < widget.vehicles.length - 1,
                        ),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Configs are the checklist setup only. Data export includes logs and odometer.',
                    style: AppTypography.small.copyWith(color: c.muted, height: 1.3),
                  ),
                ),
                const SizedBox(height: AppSpace.block),
                const SectionHeader('About'),
                AppCard(margin: const EdgeInsets.only(top: 14), children: const [CardRow(left: 'GreaseTrail', right: '1.0', divider: false)]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
