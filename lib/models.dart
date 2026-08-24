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
  final String type; // number | text | checkbox | select
  final List<String>? options;

  FieldDef({required this.label, this.unit, this.type = 'number', this.options, String? id}) : id = id ?? uid();

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

class FieldTypeOption {
  final String key;
  final String label;
  const FieldTypeOption(this.key, this.label);
}

const fieldTypeOptions = [
  FieldTypeOption('number', 'Number'),
  FieldTypeOption('text', 'Text'),
  FieldTypeOption('checkbox', 'Checkbox'),
];

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

  Category copyWith({
    String? name,
    List<FieldDef>? fields,
    int? intervalKm,
    bool clearIntervalKm = false,
    int? intervalMonths,
    bool clearIntervalMonths = false,
  }) {
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

/// A named, ordered group of category ids logged together as one service visit.
class ServicePackage {
  final String id;
  final String name;
  final List<String> categoryIds;

  ServicePackage({required this.name, required this.categoryIds, String? id}) : id = id ?? uid();

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'categoryIds': categoryIds};

  factory ServicePackage.fromJson(Map<String, dynamic> json) => ServicePackage(
        id: json['id'] as String,
        name: json['name'] as String,
        categoryIds: (json['categoryIds'] as List? ?? []).map((e) => e as String).toList(),
      );
}

/// A service package with its category ids resolved to the vehicle's live categories.
class ResolvedServicePackage {
  final String id;
  final String name;
  final List<String> categoryIds;
  final List<Category> categories;

  ResolvedServicePackage({required this.id, required this.name, required this.categoryIds, required this.categories});
}

class LogEntry {
  final String id;
  final String categoryId;
  final String categoryName;
  final String date; // yyyy-MM-dd
  final double odometer;
  final Map<String, Object?> values;
  final String note;
  final String? service;
  final List<String> photos;

  LogEntry({
    required this.categoryId,
    required this.categoryName,
    required this.date,
    required this.odometer,
    required this.values,
    this.note = '',
    this.service,
    List<String>? photos,
    String? id,
  })  : id = id ?? uid(),
        photos = photos ?? const [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'date': date,
        'odometer': odometer,
        'values': values,
        'note': note,
        'service': service,
        'photos': photos,
      };

  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
        id: json['id'] as String,
        categoryId: json['categoryId'] as String,
        categoryName: json['categoryName'] as String,
        date: json['date'] as String,
        odometer: (json['odometer'] as num).toDouble(),
        values: (json['values'] as Map? ?? {}).map((k, v) => MapEntry(k as String, v as Object?)),
        note: json['note'] as String? ?? '',
        service: json['service'] as String?,
        photos: (json['photos'] as List? ?? []).map((e) => e as String).toList(),
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
  final List<String> photos;
  // null = not yet computed/persisted for this vehicle (older data); fall back to
  // defaultServices(vehicle). An explicit empty list means the user removed them all.
  final List<ServicePackage>? services;
  // null = use the app-wide accent color.
  final int? colorValue;

  Vehicle({
    required this.type,
    required this.name,
    this.model = '',
    this.odometer = 0,
    List<Category>? categories,
    List<LogEntry>? logs,
    List<String>? photos,
    this.services,
    this.colorValue,
    String? id,
  })  : id = id ?? uid(),
        categories = categories ?? const [],
        logs = logs ?? const [],
        photos = photos ?? const [];

  Color? get color => colorValue != null ? Color(colorValue!) : null;

  Vehicle copyWith({
    double? odometer,
    List<Category>? categories,
    List<LogEntry>? logs,
    List<String>? photos,
    List<ServicePackage>? services,
    int? colorValue,
    bool clearColor = false,
  }) =>
      Vehicle(
        id: id,
        type: type,
        name: name,
        model: model,
        odometer: odometer ?? this.odometer,
        categories: categories ?? this.categories,
        logs: logs ?? this.logs,
        photos: photos ?? this.photos,
        services: services ?? this.services,
        colorValue: clearColor ? null : (colorValue ?? this.colorValue),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'model': model,
        'odometer': odometer,
        'categories': categories.map((c) => c.toJson()).toList(),
        'logs': logs.map((l) => l.toJson()).toList(),
        'photos': photos,
        'services': services?.map((s) => s.toJson()).toList(),
        'colorValue': colorValue,
      };

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json['id'] as String,
        type: json['type'] as String,
        name: json['name'] as String,
        model: json['model'] as String? ?? '',
        odometer: (json['odometer'] as num).toDouble(),
        categories: (json['categories'] as List? ?? []).map((e) => Category.fromJson(e as Map<String, dynamic>)).toList(),
        logs: (json['logs'] as List? ?? []).map((e) => LogEntry.fromJson(e as Map<String, dynamic>)).toList(),
        photos: (json['photos'] as List? ?? []).map((e) => e as String).toList(),
        services: (json['services'] as List?)?.map((e) => ServicePackage.fromJson(e as Map<String, dynamic>)).toList(),
        colorValue: json['colorValue'] as int?,
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

/// Category templates per vehicle type. Each call returns fresh Category/FieldDef
/// instances (with fresh ids) so vehicles never share mutable template state.
List<Category> templatesFor(String type) {
  switch (type) {
    case 'motorcycle':
      return [
        Category(name: 'Chain tension', fields: [FieldDef(label: 'Tension', unit: 'mm')], intervalKm: 1000),
        Category(
          name: 'Oil change',
          fields: [
            FieldDef(label: 'Type', type: 'select', options: const ['Full change', 'With filter', 'Topped up']),
            FieldDef(label: 'Amount added', unit: 'L'),
          ],
          intervalKm: 6000,
          intervalMonths: 12,
        ),
        Category(name: 'Scott oiler', fields: [FieldDef(label: 'Setting', type: 'text')]),
        Category(
          name: 'Tire pressure',
          fields: [FieldDef(label: 'Front', unit: 'bar'), FieldDef(label: 'Rear', unit: 'bar')],
          intervalMonths: 1,
        ),
        Category(
          name: 'Brake pads',
          fields: [FieldDef(label: 'Front', unit: 'mm'), FieldDef(label: 'Rear', unit: 'mm')],
          intervalKm: 5000,
        ),
        Category(name: 'Coolant', fields: [FieldDef(label: 'Topped up', unit: 'L')], intervalMonths: 12),
        Category(name: 'Battery', fields: [FieldDef(label: 'Voltage', unit: 'V')], intervalMonths: 6),
      ];
    case 'car':
      return [
        Category(
          name: 'Oil change',
          fields: [
            FieldDef(label: 'Type', type: 'select', options: const ['Full change', 'With filter', 'Topped up']),
            FieldDef(label: 'Amount added', unit: 'L'),
          ],
          intervalKm: 15000,
          intervalMonths: 12,
        ),
        Category(
          name: 'Tire pressure',
          fields: [
            FieldDef(label: 'Front left', unit: 'bar'),
            FieldDef(label: 'Front right', unit: 'bar'),
            FieldDef(label: 'Rear left', unit: 'bar'),
            FieldDef(label: 'Rear right', unit: 'bar'),
          ],
          intervalMonths: 1,
        ),
        Category(
          name: 'Tire tread',
          fields: [FieldDef(label: 'Front', unit: 'mm'), FieldDef(label: 'Rear', unit: 'mm')],
          intervalMonths: 6,
        ),
        Category(
          name: 'Brake pads',
          fields: [FieldDef(label: 'Front', unit: 'mm'), FieldDef(label: 'Rear', unit: 'mm')],
          intervalKm: 20000,
        ),
        Category(name: 'Coolant', fields: [FieldDef(label: 'Topped up', unit: 'L')], intervalMonths: 24),
        Category(
          name: 'Wiper blades',
          fields: [FieldDef(label: 'Front', type: 'checkbox'), FieldDef(label: 'Rear', type: 'checkbox')],
          intervalMonths: 12,
        ),
      ];
    case 'bicycle':
      return [
        Category(name: 'Chain lube', fields: const [], intervalKm: 300),
        Category(name: 'Chain wear', fields: [FieldDef(label: 'Wear', unit: '%')], intervalMonths: 6),
        Category(
          name: 'Tire pressure',
          fields: [FieldDef(label: 'Front', unit: 'bar'), FieldDef(label: 'Rear', unit: 'bar')],
        ),
        Category(
          name: 'Brake pads',
          fields: [FieldDef(label: 'Front', unit: 'mm'), FieldDef(label: 'Rear', unit: 'mm')],
          intervalKm: 2000,
        ),
        Category(name: 'Gear cable tension', fields: [FieldDef(label: 'Notes', type: 'text')], intervalMonths: 12),
      ];
    case 'scooter':
      return [
        Category(
          name: 'Oil change',
          fields: [
            FieldDef(label: 'Type', type: 'select', options: const ['Full change', 'With filter', 'Topped up']),
            FieldDef(label: 'Amount added', unit: 'L'),
          ],
          intervalKm: 3000,
          intervalMonths: 12,
        ),
        Category(name: 'Variator / belt', fields: [FieldDef(label: 'Condition', type: 'text')], intervalKm: 8000),
        Category(
          name: 'Tire pressure',
          fields: [FieldDef(label: 'Front', unit: 'bar'), FieldDef(label: 'Rear', unit: 'bar')],
          intervalMonths: 1,
        ),
        Category(name: 'Spark plug', fields: [FieldDef(label: 'Notes', type: 'text')], intervalKm: 6000),
      ];
    default:
      return const [];
  }
}

class ServiceTemplate {
  final String id;
  final String name;
  final List<String> items;
  const ServiceTemplate(this.id, this.name, this.items);
}

const Map<String, List<ServiceTemplate>> servicePackageTemplates = {
  'motorcycle': [
    ServiceTemplate('minor', 'Minor service', ['Oil change', 'Chain tension', 'Tire pressure']),
    ServiceTemplate('major', 'Major service',
        ['Oil change', 'Chain tension', 'Tire pressure', 'Brake pads', 'Coolant', 'Battery', 'Scott oiler']),
  ],
  'car': [
    ServiceTemplate('minor', 'Minor service', ['Oil change', 'Tire pressure', 'Wiper blades']),
    ServiceTemplate(
        'major', 'Major service', ['Oil change', 'Tire pressure', 'Tire tread', 'Brake pads', 'Coolant', 'Wiper blades']),
  ],
  'bicycle': [
    ServiceTemplate('minor', 'Minor service', ['Chain lube', 'Tire pressure']),
    ServiceTemplate('major', 'Major service', ['Chain lube', 'Chain wear', 'Tire pressure', 'Brake pads', 'Gear cable tension']),
  ],
  'scooter': [
    ServiceTemplate('minor', 'Minor service', ['Oil change', 'Tire pressure']),
    ServiceTemplate('major', 'Major service', ['Oil change', 'Tire pressure', 'Variator / belt', 'Spark plug']),
  ],
};

List<ServicePackage> defaultServices(Vehicle vehicle) {
  final templates = servicePackageTemplates[vehicle.type] ?? const [];
  return templates.map((pack) {
    final ids = <String>[];
    for (final itemName in pack.items) {
      final match = vehicle.categories.where((c) => c.name == itemName).firstOrNull;
      if (match != null) ids.add(match.id);
    }
    return ServicePackage(id: pack.id, name: pack.name, categoryIds: ids);
  }).toList();
}

List<ServicePackage> getServiceRecords(Vehicle vehicle) => vehicle.services ?? defaultServices(vehicle);

List<ResolvedServicePackage> getServicePackages(Vehicle vehicle) {
  return getServiceRecords(vehicle).map((pack) {
    final cats = <Category>[];
    for (final id in pack.categoryIds) {
      final match = vehicle.categories.where((c) => c.id == id).firstOrNull;
      if (match != null) cats.add(match);
    }
    return ResolvedServicePackage(id: pack.id, name: pack.name, categoryIds: pack.categoryIds, categories: cats);
  }).toList();
}

Vehicle upsertService(Vehicle vehicle, ServicePackage pack) {
  final current = getServiceRecords(vehicle);
  final exists = current.any((s) => s.id == pack.id);
  final next = exists ? current.map((s) => s.id == pack.id ? pack : s).toList() : [...current, pack];
  return vehicle.copyWith(services: next);
}

Vehicle removeService(Vehicle vehicle, String id) {
  final current = getServiceRecords(vehicle);
  return vehicle.copyWith(services: current.where((s) => s.id != id).toList());
}

Map<String, Object?> emptyFieldValues(Category category, [bool checkboxDefault = false]) =>
    {for (final f in category.fields) f.label: f.type == 'checkbox' ? checkboxDefault : ''};

Vehicle seedVehicle(String type, String name, String model, double odo) {
  final base = Vehicle(type: type, name: name, model: model, odometer: odo, categories: templatesFor(type), photos: const []);
  return base.copyWith(services: defaultServices(base));
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
      odometer: 33100,
      values: {'Front': '2.3', 'Rear': '2.5'},
    ),
    LogEntry(
      categoryId: brakes.id,
      categoryName: 'Brake pads',
      date: daysAgo(30),
      odometer: 32000,
      values: {'Front': '4.2', 'Rear': '3.8'},
    ),
    LogEntry(
      categoryId: coolant.id,
      categoryName: 'Coolant',
      date: daysAgo(60),
      odometer: 32800,
      values: {'Topped up': '0.2'},
    ),
  ];

  return [v.copyWith(logs: logs)];
}

/// Due-status: null if no interval configured, otherwise ok / soon / overdue.
class CategoryStatus {
  final DueLevel level;
  final double ratio;
  final LogEntry? last;
  CategoryStatus(this.level, this.ratio, this.last);
}

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

String? attentionLabel(Vehicle vehicle, Category category) {
  final status = getStatus(vehicle, category);
  if (status == null) return null;
  final last = status.last;
  if (last == null) return 'NEVER';

  final kmRatio = category.intervalKm != null ? (vehicle.odometer - last.odometer) / category.intervalKm! : 0.0;
  final monthRatio = category.intervalMonths != null
      ? (DateTime.now().difference(DateTime.parse(last.date)).inMilliseconds / 86400000) / 30.44 / category.intervalMonths!
      : 0.0;

  if (kmRatio >= monthRatio && category.intervalKm != null) {
    final delta = (vehicle.odometer - last.odometer - category.intervalKm!).round();
    return '${delta.abs()} KM';
  }
  if (category.intervalMonths != null) {
    final daysSince = DateTime.now().difference(DateTime.parse(last.date)).inMilliseconds / 86400000;
    final delta = (daysSince - category.intervalMonths! * 30.44).round();
    return delta >= 0 ? '+$delta DAYS' : '${delta.abs()} DAYS';
  }
  return statusLabel[status.level];
}

class AttentionItem {
  final String id;
  final String name;
  final DueLevel level;
  final String label;
  AttentionItem({required this.id, required this.name, required this.level, required this.label});
}

List<AttentionItem> getAttentionItems(Vehicle vehicle) {
  final items = <AttentionItem>[];
  for (final cat in vehicle.categories) {
    final status = getStatus(vehicle, cat);
    if (status == null || status.level == DueLevel.ok) continue;
    items.add(AttentionItem(id: cat.id, name: cat.name, level: status.level, label: attentionLabel(vehicle, cat) ?? ''));
  }
  return items;
}

class AttentionCounts {
  final int overdue;
  final int soon;
  AttentionCounts(this.overdue, this.soon);
}

AttentionCounts countAttention(Vehicle vehicle) {
  final items = getAttentionItems(vehicle);
  return AttentionCounts(
    items.where((i) => i.level == DueLevel.overdue).length,
    items.where((i) => i.level == DueLevel.soon).length,
  );
}
