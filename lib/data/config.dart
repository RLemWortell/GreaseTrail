import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart' show BuildContext;

import '../models.dart';
import '../storage.dart' as storage;
import 'export.dart';

class ConfigFieldSpec {
  final String label;
  final String? unit;
  final String type;
  final List<String>? options;

  const ConfigFieldSpec({required this.label, this.unit, this.type = 'number', this.options});

  Map<String, dynamic> toJson() => {'label': label, 'unit': unit, 'type': type, 'options': options};

  factory ConfigFieldSpec.fromJson(Map<String, dynamic> json) => ConfigFieldSpec(
        label: json['label'] as String,
        unit: json['unit'] as String?,
        type: json['type'] as String? ?? 'number',
        options: (json['options'] as List?)?.map((e) => e as String).toList(),
      );

  factory ConfigFieldSpec.fromFieldDef(FieldDef f) => ConfigFieldSpec(label: f.label, unit: f.unit, type: f.type, options: f.options);
}

class ConfigCategorySpec {
  final String name;
  final int? intervalKm;
  final int? intervalMonths;
  final List<ConfigFieldSpec> fields;

  const ConfigCategorySpec({required this.name, this.intervalKm, this.intervalMonths, this.fields = const []});

  Map<String, dynamic> toJson() => {
        'name': name,
        'intervalKm': intervalKm,
        'intervalMonths': intervalMonths,
        'fields': fields.map((f) => f.toJson()).toList(),
      };

  factory ConfigCategorySpec.fromJson(Map<String, dynamic> json) => ConfigCategorySpec(
        name: json['name'] as String,
        intervalKm: json['intervalKm'] as int?,
        intervalMonths: json['intervalMonths'] as int?,
        fields: (json['fields'] as List? ?? []).map((e) => ConfigFieldSpec.fromJson(e as Map<String, dynamic>)).toList(),
      );

  factory ConfigCategorySpec.fromCategory(Category c) => ConfigCategorySpec(
        name: c.name,
        intervalKm: c.intervalKm,
        intervalMonths: c.intervalMonths,
        fields: c.fields.map(ConfigFieldSpec.fromFieldDef).toList(),
      );
}

class ConfigServiceSpec {
  final String name;
  final List<String> items;
  const ConfigServiceSpec({required this.name, this.items = const []});

  Map<String, dynamic> toJson() => {'name': name, 'items': items};

  factory ConfigServiceSpec.fromJson(Map<String, dynamic> json) => ConfigServiceSpec(
        name: json['name'] as String,
        items: (json['items'] as List? ?? []).map((e) => e as String).toList(),
      );
}

class GtConfig {
  final String id;
  final bool builtin;
  final String name;
  final String type;
  final List<ConfigCategorySpec> categories;
  final List<ConfigServiceSpec> services;

  GtConfig({
    required this.name,
    required this.type,
    this.categories = const [],
    this.services = const [],
    this.builtin = false,
    String? id,
  }) : id = id ?? uid();

  Map<String, dynamic> toJson() => {
        'app': 'GreaseTrail',
        'kind': 'config',
        'version': 1,
        'id': id,
        'builtin': builtin,
        'name': name,
        'type': type,
        'categories': categories.map((c) => c.toJson()).toList(),
        'services': services.map((s) => s.toJson()).toList(),
      };

  factory GtConfig.fromJson(Map<String, dynamic> json) => GtConfig(
        id: json['id'] as String? ?? uid(),
        builtin: json['builtin'] as bool? ?? false,
        name: json['name'] as String,
        type: json['type'] as String,
        categories: (json['categories'] as List? ?? []).map((e) => ConfigCategorySpec.fromJson(e as Map<String, dynamic>)).toList(),
        services: (json['services'] as List? ?? []).map((e) => ConfigServiceSpec.fromJson(e as Map<String, dynamic>)).toList(),
      );
}

Future<List<GtConfig>> loadConfigs() async {
  final raw = await storage.loadConfigsRaw();
  return raw.map(GtConfig.fromJson).toList();
}

Future<void> saveConfigs(List<GtConfig> configs) async {
  await storage.saveConfigsRaw(configs.map((c) => c.toJson()).toList());
}

List<GtConfig> builtinConfigs() {
  return typeMeta.keys.map((type) {
    return GtConfig(
      id: 'builtin-$type',
      builtin: true,
      name: typeMeta[type]?.label ?? type,
      type: type,
      categories: templatesFor(type).map(ConfigCategorySpec.fromCategory).toList(),
      services: (servicePackageTemplates[type] ?? const [])
          .map((p) => ConfigServiceSpec(name: p.name, items: List.of(p.items)))
          .toList(),
    );
  }).toList();
}

GtConfig configFromVehicle(Vehicle vehicle, [String? name]) {
  final categories = vehicle.categories.map(ConfigCategorySpec.fromCategory).toList();
  final services = getServiceRecords(vehicle).map((s) {
    final items = <String>[];
    for (final id in s.categoryIds) {
      final match = vehicle.categories.where((c) => c.id == id).firstOrNull;
      if (match != null) items.add(match.name);
    }
    return ConfigServiceSpec(name: s.name, items: items);
  }).toList();
  return GtConfig(name: name ?? '${vehicle.name} setup', type: vehicle.type, categories: categories, services: services);
}

Vehicle vehicleFromConfig(GtConfig config, String name, String model, double odo) {
  final categories = config.categories
      .map((c) => Category(
            name: c.name,
            intervalKm: c.intervalKm,
            intervalMonths: c.intervalMonths,
            fields: c.fields.map((f) => FieldDef(label: f.label, unit: f.unit, type: f.type, options: f.options)).toList(),
          ))
      .toList();
  final vehicle = Vehicle(type: config.type, name: name, model: model, odometer: odo, categories: categories, photos: const []);
  final packs = config.services;
  final services = packs.isNotEmpty
      ? packs.map((s) {
          final ids = <String>[];
          for (final itemName in s.items) {
            final match = categories.where((c) => c.name == itemName).firstOrNull;
            if (match != null) ids.add(match.id);
          }
          return ServicePackage(name: s.name, categoryIds: ids);
        }).toList()
      : defaultServices(vehicle);
  return vehicle.copyWith(services: services);
}

GtConfig duplicateConfig(GtConfig config) {
  return GtConfig(
    builtin: false,
    name: '${config.name} copy',
    type: config.type,
    categories: config.categories,
    services: config.services,
  );
}

class ConfigParseException implements Exception {
  final String message;
  ConfigParseException(this.message);
  @override
  String toString() => message;
}

GtConfig parseConfig(String raw) {
  final data = jsonDecode(raw) as Map<String, dynamic>;
  if (data['app'] != 'GreaseTrail') {
    throw ConfigParseException('Not a GreaseTrail file.');
  }
  if (data['kind'] != 'config') {
    throw ConfigParseException('This file is a data backup, not a config.');
  }
  final categories = data['categories'];
  final type = data['type'];
  if (categories is! List || type == null) {
    throw ConfigParseException('Config is missing type or categories.');
  }
  return GtConfig(
    builtin: false,
    name: (data['name'] as String?) ?? '${typeMeta[type]?.label ?? type} setup',
    type: type as String,
    categories: categories.map((e) => ConfigCategorySpec.fromJson(e as Map<String, dynamic>)).toList(),
    services: ((data['services'] as List?) ?? []).map((e) => ConfigServiceSpec.fromJson(e as Map<String, dynamic>)).toList(),
  );
}

Future<void> exportConfig(GtConfig config, BuildContext context) async {
  final payload = {
    'app': 'GreaseTrail',
    'kind': 'config',
    'version': 1,
    'name': config.name,
    'type': config.type,
    'categories': config.categories.map((c) => c.toJson()).toList(),
    'services': config.services.map((s) => s.toJson()).toList(),
  };
  await shareJsonFile(
    'greasetrail-config-${slug(config.name)}.json',
    const JsonEncoder.withIndent('  ').convert(payload),
    'Export config',
    context,
  );
}

Future<GtConfig?> importConfigFile() async {
  final result = await FilePicker.platform.pickFiles(type: FileType.any);
  if (result == null || result.files.isEmpty) return null;
  final path = result.files.first.path;
  if (path == null) return null;
  final raw = await File(path).readAsString();
  return parseConfig(raw);
}
