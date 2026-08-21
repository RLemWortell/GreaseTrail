import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../format.dart';
import '../models.dart';

String _stamp() => todayIso();

String _csvCell(Object? value) {
  final s = value?.toString() ?? '';
  if (RegExp(r'["\n\r,]').hasMatch(s)) return '"${s.replaceAll('"', '""')}"';
  return s;
}

String _typeLabel(String type) => typeMeta[type]?.label ?? type;

String slug(String? name) {
  final base = (name ?? 'export')
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  final trimmed = base.length > 40 ? base.substring(0, 40) : base;
  return trimmed.isEmpty ? 'export' : trimmed;
}

class _LogWithVehicle {
  final LogEntry log;
  final Vehicle vehicle;
  _LogWithVehicle(this.log, this.vehicle);
}

List<_LogWithVehicle> _allLogs(List<Vehicle> vehicles) {
  final all = vehicles.expand((v) => v.logs.map((l) => _LogWithVehicle(l, v))).toList();
  all.sort((a, b) => DateTime.parse(b.log.date).compareTo(DateTime.parse(a.log.date)));
  return all;
}

String buildJson(List<Vehicle> vehicles) {
  return const JsonEncoder.withIndent('  ').convert({
    'app': 'GreaseTrail',
    'version': 1,
    'exportedAt': DateTime.now().toIso8601String(),
    'vehicles': vehicles.map((v) => v.toJson()).toList(),
  });
}

String buildCsv(List<Vehicle> vehicles) {
  final header = ['Vehicle', 'Type', 'Model', 'Date', 'Odometer_km', 'Category', 'Service', 'Values', 'Note'];
  final rows = _allLogs(vehicles).map((e) {
    final l = e.log;
    final v = e.vehicle;
    return [
      v.name,
      _typeLabel(v.type),
      v.model,
      l.date,
      l.odometer,
      l.categoryName,
      l.service ?? '',
      formatLogLine(v, l),
      l.note,
    ].map(_csvCell).join(',');
  });
  return [header.join(','), ...rows].join('\n');
}

pw.Document buildPdfDocument(List<Vehicle> vehicles) {
  final doc = pw.Document();
  final single = vehicles.length == 1;
  final title = single ? vehicles.first.name : 'GreaseTrail';
  final sub = single
      ? [
          formatDate(todayIso()),
          vehicles.first.model,
          _typeLabel(vehicles.first.type),
          '${formatOdo(vehicles.first.odometer)} km',
        ].where((s) => s.isNotEmpty).join('  ·  ')
      : '${formatDate(todayIso())}  ·  ${vehicles.length} vehicles';

  doc.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text(title.toUpperCase(), style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5)),
        pw.SizedBox(height: 4),
        pw.Text(sub, style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF8A8A84))),
        pw.SizedBox(height: 20),
        if (vehicles.isEmpty) pw.Text('No vehicles.', style: const pw.TextStyle(color: PdfColor.fromInt(0xFF8A8A84))),
        for (final v in vehicles) ...[
          if (!single) ...[
            pw.SizedBox(height: 14),
            pw.Text(v.name.toUpperCase(), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text(
              [v.model, _typeLabel(v.type), '${formatOdo(v.odometer)} km'].where((s) => s.isNotEmpty).join('  ·  '),
              style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF8A8A84)),
            ),
            pw.SizedBox(height: 8),
          ],
          if (v.logs.isEmpty)
            pw.Text('No log entries.', style: const pw.TextStyle(color: PdfColor.fromInt(0xFF8A8A84)))
          else
            pw.Table(
              border: const pw.TableBorder(horizontalInside: pw.BorderSide(color: PdfColor.fromInt(0xFFE4E2DC))),
              columnWidths: const {
                0: pw.FlexColumnWidth(2),
                1: pw.FlexColumnWidth(1.4),
                2: pw.FlexColumnWidth(2.4),
                3: pw.FlexColumnWidth(4),
              },
              children: [
                pw.TableRow(children: [
                  for (final h in ['Date', 'km', 'Category', 'Details'])
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Text(h.toUpperCase(),
                          style: pw.TextStyle(
                              fontSize: 8, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF8A8A84))),
                    ),
                ]),
                for (final l in [...v.logs]..sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date))))
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text(formatDate(l.date), style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text(formatOdo(l.odometer), style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text(l.categoryName, style: const pw.TextStyle(fontSize: 9))),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (l.service != null) pw.Text(l.service!, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                          if (formatLogLine(v, l).isNotEmpty) pw.Text(formatLogLine(v, l), style: const pw.TextStyle(fontSize: 9)),
                          if (l.note.isNotEmpty)
                            pw.Text(l.note, style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF8A8A84))),
                          if (l.service == null && formatLogLine(v, l).isEmpty && l.note.isEmpty)
                            pw.Text('—', style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ]),
              ],
            ),
        ],
      ],
    ),
  );
  return doc;
}

Future<File> _writeCache(String name, List<int> bytes) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$name');
  await file.writeAsBytes(bytes);
  return file;
}

Future<void> _shareFile(File file, {required String mimeType, String? subject}) async {
  await Share.shareXFiles([XFile(file.path, mimeType: mimeType)], subject: subject);
}

Future<void> exportJson(List<Vehicle> vehicles) async {
  final file = await _writeCache('greasetrail-${_stamp()}.json', utf8.encode(buildJson(vehicles)));
  await _shareFile(file, mimeType: 'application/json', subject: 'Export JSON');
}

Future<void> exportCsv(List<Vehicle> vehicles) async {
  final file = await _writeCache('greasetrail-${_stamp()}.csv', utf8.encode(buildCsv(vehicles)));
  await _shareFile(file, mimeType: 'text/csv', subject: 'Export CSV');
}

Future<void> exportPdf(List<Vehicle> vehicles) async {
  final label = vehicles.length == 1 ? slug(vehicles.first.name) : 'all';
  final bytes = await buildPdfDocument(vehicles).save();
  final file = await _writeCache('greasetrail-$label-${_stamp()}.pdf', bytes);
  await _shareFile(file, mimeType: 'application/pdf', subject: 'Export PDF');
}

Future<void> shareJsonFile(String filename, String contents, String subject) async {
  final file = await _writeCache(filename, utf8.encode(contents));
  await _shareFile(file, mimeType: 'application/json', subject: subject);
}
