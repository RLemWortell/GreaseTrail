import 'dart:math';

import 'package:flutter/material.dart';

import 'theme.dart';

final _rand = Random();
const _uidChars = 'abcdefghijklmnopqrstuvwxyz0123456789';

String uid() => List.generate(7, (_) => _uidChars[_rand.nextInt(_uidChars.length)]).join();

String _isoDate(DateTime d) => d.toIso8601String().substring(0, 10);

String todayIso() => _isoDate(DateTime.now());

class FieldDef {
  final String id;
  final String label;
  final String? unit;
  final String type; // number | text | select
  final List<String>? options;

  FieldDef({required this.label, this.unit, this.type = 'number', this.options, String? id}) : id = id ?? uid();

  FieldDef copyWith() => FieldDef(id: id, label: label, unit: unit, type: type, options: options);

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'unit': unit,
        'type': type,
        'options': options,
      };

  factory FieldDef.fromJson(Map<String, dynamic> json) => FieldDef(
        id: json['id'] as String,
        label: json['label'] as String,
        unit: json['unit'] as String?,
        type: json['type'] as String? ?? 'number',
        options: (json['options'] as List?)?.map((e) => e as String).toList(),
      );
}

class Category {
  final String id;
  final String name;
  final List<FieldDef> fields;
  final int? intervalKm;
  final int? intervalMonths;

  Category({
    required this.name,
    List<FieldDef>? fields,
    this.intervalKm,
    this.intervalMonths,
    String? id,
  })  : id = id ?? uid(),
        fields = fields ?? const [];

  Category copyWith({String? name, List<FieldDef>? fields, int? intervalKm, bool clearIntervalKm = false, int? intervalMonths, bool clearIntervalMonths = false}) {
    return Category(
      id: id,
      name: name ?? this.name,
      fields: fields ?? this.fields,
      intervalKm: clearIntervalKm ? null : (intervalKm ?? this.intervalKm),
      intervalMonths: clearIntervalMonths ? null : (intervalMonths ?? this.intervalMonths),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'fields': fields.map((f) => f.toJson()).toList(),
        'intervalKm': intervalKm,
        'intervalMonths': intervalMonths,
      };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        fields: (json['fields'] as List? ?? []).map((e) => FieldDef.fromJson(e as Map<String, dynamic>)).toList(),
        intervalKm: json['intervalKm'] as int?,
        intervalMonths: json['intervalMonths'] as int?,
      );
}

class LogEntry {
  final String id;
  final String categoryId;
  final String categoryName;
  final String date; // yyyy-MM-dd
  final double odometer;
  final Map<String, String> values;
  final String note;

  LogEntry({
    required this.categoryId,
    required this.categoryName,
    required this.date,
    required this.odometer,
    required this.values,
    this.note = '',
    String? id,
  }) : id = id ?? uid();

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'date': date,
        'odometer': odometer,
        'values': values,
        'note': note,
      };

  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
        id: json['id'] as String,
        categoryId: json['categoryId'] as String,
        categoryName: json['categoryName'] as String,
        date: json['date'] as String,
        odometer: (json['odometer'] as num).toDouble(),
        values: (json['values'] as Map).map((k, v) => MapEntry(k as String, v as String)),
        note: json['note'] as String? ?? '',
      );
}

class Vehicle {
  final String id;
  final String type;
  final String name;
  final String model;
  final double odometer;
  final List<Category> categories;
  final List<LogEntry> logs;

  Vehicle({
    required this.type,
    required this.name,
    this.model = '',
    this.odometer = 0,
    List<Category>? categories,
    List<LogEntry>? logs,
    String? id,
  })  : id = id ?? uid(),
        categories = categories ?? const [],
        logs = logs ?? const [];

  Vehicle copyWith({double? odometer, List<Category>? categories, List<LogEntry>? logs}) => Vehicle(
        id: id,
        type: type,
        name: name,
        model: model,
        odometer: odometer ?? this.odometer,
        categories: categories ?? this.categories,
        logs: logs ?? this.logs,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'model': model,
        'odometer': odometer,
        'categories': categories.map((c) => c.toJson()).toList(),
        'logs': logs.map((l) => l.toJson()).toList(),
      };

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json['id'] as String,
        type: json['type'] as String,
        name: json['name'] as String,
        model: json['model'] as String? ?? '',
        odometer: (json['odometer'] as num).toDouble(),
        categories: (json['categories'] as List? ?? []).map((e) => Category.fromJson(e as Map<String, dynamic>)).toList(),
        logs: (json['logs'] as List? ?? []).map((e) => LogEntry.fromJson(e as Map<String, dynamic>)).toList(),
      );
}

class VehicleTypeMeta {
  final String label;
  final IconData icon;
  const VehicleTypeMeta(this.label, this.icon);
}

const Map<String, VehicleTypeMeta> typeMeta = {
  'motorcycle': VehicleTypeMeta('Motorcycle', Icons.motorcycle),
  'car': VehicleTypeMeta('Car', Icons.directions_car),
  'bicycle': VehicleTypeMeta('Bicycle', Icons.pedal_bike),
  'scooter': VehicleTypeMeta('Scooter / Moped', Icons.moped),
};

List<FieldDef> _fields(List<FieldDef> fields) => fields;

/// Category templates per vehicle type. Each call returns fresh Category/FieldDef
/// instances (with fresh ids) so vehicles never share mutable template state.
List<Category> templatesFor(String type) {
  switch (type) {
    case 'motorcycle':
      return [
        Category(name: 'Chain tension', fields: _fields([FieldDef(label: 'Tension', unit: 'mm')]), intervalKm: 1000),
        Category(
          name: 'Oil change',
          fields: _fields([
            FieldDef(label: 'Type', type: 'select', options: const ['Full change', 'With filter', 'Topped up']),
            FieldDef(label: 'Amount added', unit: 'L'),
          ]),
          intervalKm: 6000,
          intervalMonths: 12,
        ),
        Category(name: 'Scott oiler', fields: _fields([FieldDef(label: 'Setting', type: 'text')])),
        Category(
          name: 'Tire pressure',
          fields: _fields([FieldDef(label: 'Front', unit: 'bar'), FieldDef(label: 'Rear', unit: 'bar')]),
          intervalMonths: 1,
        ),
        Category(
          name: 'Brake pads',
          fields: _fields([FieldDef(label: 'Front', unit: 'mm'), FieldDef(label: 'Rear', unit: 'mm')]),
          intervalKm: 5000,
        ),
        Category(name: 'Coolant', fields: _fields([FieldDef(label: 'Topped up', unit: 'L')]), intervalMonths: 12),
        Category(name: 'Battery', fields: _fields([FieldDef(label: 'Voltage', unit: 'V')]), intervalMonths: 6),
      ];
    case 'car':
      return [
        Category(
          name: 'Oil change',
          fields: _fields([
            FieldDef(label: 'Type', type: 'select', options: const ['Full change', 'With filter', 'Topped up']),
            FieldDef(label: 'Amount added', unit: 'L'),
          ]),
          intervalKm: 15000,
          intervalMonths: 12,
        ),
        Category(
          name: 'Tire pressure',
          fields: _fields([
            FieldDef(label: 'Front left', unit: 'bar'),
            FieldDef(label: 'Front right', unit: 'bar'),
            FieldDef(label: 'Rear left', unit: 'bar'),
            FieldDef(label: 'Rear right', unit: 'bar'),
          ]),
          intervalMonths: 1,
        ),
        Category(
          name: 'Tire tread',
          fields: _fields([FieldDef(label: 'Front', unit: 'mm'), FieldDef(label: 'Rear', unit: 'mm')]),
          intervalMonths: 6,
        ),
        Category(
          name: 'Brake pads',
          fields: _fields([FieldDef(label: 'Front', unit: 'mm'), FieldDef(label: 'Rear', unit: 'mm')]),
          intervalKm: 20000,
        ),
        Category(name: 'Coolant', fields: _fields([FieldDef(label: 'Topped up', unit: 'L')]), intervalMonths: 24),
        Category(name: 'Wiper blades', fields: const [], intervalMonths: 12),
      ];
    case 'bicycle':
      return [
        Category(name: 'Chain lube', fields: const [], intervalKm: 300),
        Category(name: 'Chain wear', fields: _fields([FieldDef(label: 'Wear', unit: '%')]), intervalMonths: 6),
        Category(
          name: 'Tire pressure',
          fields: _fields([FieldDef(label: 'Front', unit: 'bar'), FieldDef(label: 'Rear', unit: 'bar')]),
        ),
        Category(
          name: 'Brake pads',
          fields: _fields([FieldDef(label: 'Front', unit: 'mm'), FieldDef(label: 'Rear', unit: 'mm')]),
          intervalKm: 2000,
        ),
        Category(name: 'Gear cable tension', fields: _fields([FieldDef(label: 'Notes', type: 'text')]), intervalMonths: 12),
      ];
    case 'scooter':
      return [
        Category(
          name: 'Oil change',
          fields: _fields([
            FieldDef(label: 'Type', type: 'select', options: const ['Full change', 'With filter', 'Topped up']),
            FieldDef(label: 'Amount added', unit: 'L'),
          ]),
          intervalKm: 3000,
          intervalMonths: 12,
        ),
        Category(name: 'Variator / belt', fields: _fields([FieldDef(label: 'Condition', type: 'text')]), intervalKm: 8000),
        Category(
          name: 'Tire pressure',
          fields: _fields([FieldDef(label: 'Front', unit: 'bar'), FieldDef(label: 'Rear', unit: 'bar')]),
          intervalMonths: 1,
        ),
        Category(name: 'Spark plug', fields: _fields([FieldDef(label: 'Notes', type: 'text')]), intervalKm: 6000),
      ];
    default:
      return const [];
  }
}

Vehicle seedVehicle(String type, String name, String model, double odo) {
  return Vehicle(type: type, name: name, model: model, odometer: odo, categories: templatesFor(type));
}

String formatKm(num n) {
  final value = n.abs().round();
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

const _monthAbbr = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

String formatHeaderDate([DateTime? d]) {
  final date = d ?? DateTime.now();
  return '${date.day} ${_monthAbbr[date.month - 1]} ${date.year}';
}

LogEntry? _lastLog(Vehicle vehicle, Category category) {
  final logs = vehicle.logs.where((l) => l.categoryId == category.id).toList()
    ..sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
  return logs.isEmpty ? null : logs.first;
}

String getDueLabel(Vehicle vehicle, Category category) {
  final last = _lastLog(vehicle, category);
  if (last == null) return 'NEVER';

  double kmRatio = 0;
  double monthRatio = 0;
  double? kmDelta;
  double? dayDelta;

  if (category.intervalKm != null) {
    kmDelta = vehicle.odometer - last.odometer - category.intervalKm!;
    kmRatio = (vehicle.odometer - last.odometer) / category.intervalKm!;
  }
  if (category.intervalMonths != null) {
    final intervalDays = category.intervalMonths! * 30.44;
    final daysSince = DateTime.now().difference(DateTime.parse(last.date)).inMilliseconds / 86400000;
    dayDelta = daysSince - intervalDays;
    monthRatio = daysSince / intervalDays;
  }

  final useDays = monthRatio >= kmRatio && dayDelta != null;
  if (useDays) {
    return dayDelta >= 0 ? '+${dayDelta.round()} DAYS' : '${(-dayDelta).round()} DAYS';
  }
  if (kmDelta != null) {
    return kmDelta >= 0 ? '+${formatKm(kmDelta)} KM' : '${formatKm(-kmDelta)} KM';
  }
  return '';
}

class CategoryStatus {
  final DueLevel level;
  final double ratio;
  final LogEntry? last;
  CategoryStatus(this.level, this.ratio, this.last);
}

/// Due-status: null if no interval configured, otherwise ok / soon / overdue.
CategoryStatus? getStatus(Vehicle vehicle, Category category) {
  if (category.intervalKm == null && category.intervalMonths == null) return null;
  final logs = vehicle.logs.where((l) => l.categoryId == category.id).toList()
    ..sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
  final last = logs.isEmpty ? null : logs.first;

  double kmRatio = 0;
  double monthRatio = 0;
  if (category.intervalKm != null) {
    final lastOdo = last?.odometer ?? 0;
    kmRatio = (vehicle.odometer - lastOdo) / category.intervalKm!;
  }
  if (category.intervalMonths != null) {
    final lastDate = last != null ? DateTime.parse(last.date) : DateTime.fromMillisecondsSinceEpoch(0);
    final monthsSince = DateTime.now().difference(lastDate).inMilliseconds / (1000 * 60 * 60 * 24 * 30.44);
    monthRatio = monthsSince / category.intervalMonths!;
  }

  final ratio = max(kmRatio, monthRatio);
  if (ratio >= 1) return CategoryStatus(DueLevel.overdue, ratio, last);
  if (ratio >= 0.9) return CategoryStatus(DueLevel.soon, ratio, last);
  return CategoryStatus(DueLevel.ok, ratio, last);
}

const statusLabel = {DueLevel.overdue: 'Overdue', DueLevel.soon: 'Due soon', DueLevel.ok: 'On track'};

class AttentionItem {
  final String vehicleId;
  final String vehicleName;
  final String categoryId;
  final String name;
  final DueLevel level;
  final String label;
  final double ratio;
  final bool never;

  AttentionItem({
    required this.vehicleId,
    required this.vehicleName,
    required this.categoryId,
    required this.name,
    required this.level,
    required this.label,
    required this.ratio,
    required this.never,
  });
}

List<AttentionItem> getAttentionItems(Vehicle vehicle) {
  final items = <AttentionItem>[];
  for (final c in vehicle.categories) {
    final status = getStatus(vehicle, c);
    if (status == null || status.level == DueLevel.ok) continue;
    items.add(AttentionItem(
      vehicleId: vehicle.id,
      vehicleName: vehicle.name,
      categoryId: c.id,
      name: c.name,
      level: status.level,
      label: getDueLabel(vehicle, c),
      ratio: status.ratio,
      never: status.last == null,
    ));
  }
  int rank(AttentionItem item) {
    if (item.level == DueLevel.overdue && !item.never) return 0;
    if (item.level == DueLevel.overdue) return 1;
    return 2;
  }
  items.sort((a, b) {
    final ra = rank(a);
    final rb = rank(b);
    if (ra != rb) return ra - rb;
    return b.ratio.compareTo(a.ratio);
  });
  return items;
}

List<Vehicle> seedDemoData() {
  final v = seedVehicle('motorcycle', 'Suzuki V-Strom', 'DL650', 34210);
  Category byName(String name) => v.categories.firstWhere((c) => c.name == name);
  final tire = byName('Tire pressure');
  final oil = byName('Oil change');
  final chain = byName('Chain tension');
  final brakes = byName('Brake pads');
  final coolant = byName('Coolant');

  String daysAgo(int n) => _isoDate(DateTime.now().subtract(Duration(days: n)));

  final logs = [
    LogEntry(
      categoryId: chain.id,
      categoryName: 'Chain tension',
      date: daysAgo(45),
      odometer: 33800,
      values: {'Tension': '28'},
    ),
    LogEntry(
      categoryId: oil.id,
      categoryName: 'Oil change',
      date: daysAgo(120),
      odometer: 28600,
      values: {'Type': 'With filter', 'Amount added': '3.2'},
      note: '10W-40 fully synthetic',
    ),
    LogEntry(
      categoryId: tire.id,
      categoryName: 'Tire pressure',
      date: daysAgo(48),
      odometer: 33980,
      values: {'Front': '2.3', 'Rear': '2.5'},
    ),
    LogEntry(
      categoryId: brakes.id,
      categoryName: 'Brake pads',
      date: daysAgo(80),
      odometer: 32000,
      values: {'Front': '4.2', 'Rear': '5.0'},
    ),
    LogEntry(
      categoryId: coolant.id,
      categoryName: 'Coolant',
      date: daysAgo(40),
      odometer: 34000,
      values: {'Topped up': '0.2'},
    ),
  ];

  return [v.copyWith(logs: logs)];
}
