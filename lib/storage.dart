import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

const _kVehiclesKey = 'greasetrail:vehicles:v1';
const _kConfigsKey = 'greasetrail:configs:v1';

Future<List<Vehicle>?> loadVehicles() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kVehiclesKey);
    if (raw == null) return null;
    final list = jsonDecode(raw) as List;
    return list.map((e) => Vehicle.fromJson(e as Map<String, dynamic>)).toList();
  } catch (e) {
    debugPrintWarning('GreaseTrail: failed to load vehicles: $e');
    return null;
  }
}

Future<void> saveVehicles(List<Vehicle> vehicles) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kVehiclesKey, jsonEncode(vehicles.map((v) => v.toJson()).toList()));
  } catch (e) {
    debugPrintWarning('GreaseTrail: failed to save vehicles: $e');
  }
}

Future<List<Map<String, dynamic>>> loadConfigsRaw() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kConfigsKey);
    if (raw == null) return [];
    final parsed = jsonDecode(raw);
    if (parsed is! List) return [];
    return parsed.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
  } catch (e) {
    debugPrintWarning('GreaseTrail: failed to load configs: $e');
    return [];
  }
}

Future<void> saveConfigsRaw(List<Map<String, dynamic>> configs) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kConfigsKey, jsonEncode(configs));
  } catch (e) {
    debugPrintWarning('GreaseTrail: failed to save configs: $e');
  }
}

void debugPrintWarning(String message) {
  // ignore: avoid_print
  print(message);
}
