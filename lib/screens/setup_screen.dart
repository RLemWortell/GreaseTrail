import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/config.dart';
import '../data/export.dart';
import '../data/rdw.dart';
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
  final ValueChanged<String> onOpenConfig;
  final Color? accent;
  final ValueChanged<Color?> onAccentChange;
  final bool? rdwSetting;
  final ValueChanged<bool?> onRdwSettingChange;

  const SetupScreen({
    super.key,
    required this.vehicles,
    required this.configs,
    required this.onConfigsChange,
    required this.onManage,
    required this.onAddVehicle,
    required this.onCreateFromConfig,
    required this.onOpenConfig,
    required this.accent,
    required this.onAccentChange,
    required this.rdwSetting,
    required this.onRdwSettingChange,
  });

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  String? _busy;
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

  Future<void> _openKoFi() async {
    final uri = Uri.parse('https://ko-fi.com/lemairetech');
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        await _notify('Could not open link', 'Try visiting ko-fi.com/lemairetech in your browser instead.');
      }
    } catch (e) {
      await _notify('Could not open link', '$e');
    }
  }

  Future<void> _importFile() async {
    try {
      final cfg = await importConfigFile();
      if (cfg == null) return;
      widget.onConfigsChange([...widget.configs, cfg]);
      widget.onOpenConfig(cfg.id);
    } catch (e) {
      await _notify('Import failed', '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final all = [...builtinConfigs(), ...widget.configs];

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
                    child: Text(
                      'No vehicles yet — tap + to add one.',
                      style: AppTypography.small.copyWith(color: c.muted),
                    ),
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
                                color: widget.vehicles[i].color,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
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
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: AppSpace.block),
                const SectionHeader('Configs'),
                AppCard(
                  margin: const EdgeInsets.only(top: 14),
                  children: [
                    for (var i = 0; i < all.length; i++)
                      CardRow(
                        onPress: () => widget.onOpenConfig(all[i].id),
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
                const SizedBox(height: AppSpace.block),
                const SectionHeader('Export data'),
                AppCard(
                  margin: const EdgeInsets.only(top: 14),
                  children: [
                    CardRow(
                      onPress: () => _runExport('json', exportJson),
                      chevron: true,
                      left: 'JSON backup',
                      right: _busy == 'json' ? '…' : 'Full data',
                    ),
                    CardRow(
                      onPress: () => _runExport('csv', exportCsv),
                      chevron: true,
                      left: 'CSV log',
                      right: _busy == 'csv' ? '…' : 'Spreadsheet',
                    ),
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
                          onPress: () => _runExport(
                            'pdf-${widget.vehicles[i].id}',
                            (vs, ctx) => exportPdf([widget.vehicles[i]], ctx),
                          ),
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
                const SectionHeader('Appearance'),
                AppCard(
                  margin: const EdgeInsets.only(top: 14),
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(AppSpace.cardPad, 12, AppSpace.cardPad, 0),
                      child: Label('Accent color'),
                    ),
                    ColorSwatchPicker(
                      colors: accentSwatches,
                      value: widget.accent ?? accentSwatches.first,
                      onSelected: (color) => widget.onAccentChange(color == accentSwatches.first ? null : color),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Vehicles can override this with their own color — see a vehicle\'s Manage screen.',
                    style: AppTypography.small.copyWith(color: c.muted, height: 1.3),
                  ),
                ),
                const SizedBox(height: AppSpace.block),
                const SectionHeader('RDW lookup'),
                AppCard(
                  margin: const EdgeInsets.only(top: 14),
                  children: [
                    OptionList<bool?>(
                      options: const [null, true, false],
                      value: widget.rdwSetting,
                      onChanged: widget.onRdwSettingChange,
                      getLabel: (v) => switch (v) {
                        null => 'Automatic',
                        true => 'Always on',
                        false => 'Off',
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Shows a license plate lookup when adding a car, motorcycle, or scooter. '
                    "Automatic uses your device's region setting; ${isDutchLocale() ? 'currently on' : 'currently off'}.",
                    style: AppTypography.small.copyWith(color: c.muted, height: 1.3),
                  ),
                ),
                const SizedBox(height: AppSpace.block),
                const SectionHeader('About'),
                AppCard(
                  margin: const EdgeInsets.only(top: 14),
                  children: [
                    const CardRow(left: 'GreaseTrail', right: '1.2.0'),
                    CardRow(
                      onPress: _openKoFi,
                      chevron: true,
                      left: 'Support the developer',
                      right: 'Ko-fi',
                      divider: false,
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
}
