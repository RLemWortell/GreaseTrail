import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart' as http;

/// True when the device's region is the Netherlands — used to gate the
/// kenteken lookup UI, since RDW open data only knows Dutch plates.
bool isDutchLocale() => PlatformDispatcher.instance.locale.countryCode == 'NL';

class RdwVehicleInfo {
  final String? brand;
  final String? model;
  final String? fuelType; // 'fuel' | 'electric' | 'hybrid'
  const RdwVehicleInfo({this.brand, this.model, this.fuelType});
}

class RdwLookupException implements Exception {
  final String message;
  const RdwLookupException(this.message);
  @override
  String toString() => message;
}

String _normalizePlate(String plate) => plate.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

/// Looks up a Dutch license plate via the free RDW open-data API (no API key
/// required). Returns null if the plate isn't found; throws
/// [RdwLookupException] on network/parsing failure so the caller can show a
/// message instead of hanging or silently failing.
Future<RdwVehicleInfo?> lookupKenteken(String plate) async {
  final kenteken = _normalizePlate(plate);
  if (kenteken.isEmpty) return null;

  try {
    final responses = await Future.wait([
      http.get(Uri.https('opendata.rdw.nl', '/resource/m9d7-ebf2.json', {'kenteken': kenteken})),
      http.get(Uri.https('opendata.rdw.nl', '/resource/8ys7-d773.json', {'kenteken': kenteken})),
    ]).timeout(const Duration(seconds: 10));

    final basicRes = responses[0];
    final fuelRes = responses[1];
    if (basicRes.statusCode != 200 || fuelRes.statusCode != 200) {
      throw RdwLookupException('RDW is currently unavailable (${basicRes.statusCode}).');
    }

    final basicList = jsonDecode(basicRes.body) as List;
    if (basicList.isEmpty) return null;
    final basic = basicList.first as Map<String, dynamic>;

    final fuelList = jsonDecode(fuelRes.body) as List;
    final fuelDescriptions = fuelList
        .whereType<Map<String, dynamic>>()
        .map((e) => e['brandstof_omschrijving'] as String?)
        .whereType<String>()
        .toSet();

    final hasElectric = fuelDescriptions.contains('Elektriciteit');
    final hasCombustion = fuelDescriptions.any((f) => f != 'Elektriciteit');
    final fuelType = fuelDescriptions.isEmpty ? null : (hasElectric && hasCombustion ? 'hybrid' : (hasElectric ? 'electric' : 'fuel'));

    return RdwVehicleInfo(
      brand: basic['merk'] as String?,
      model: basic['handelsbenaming'] as String?,
      fuelType: fuelType,
    );
  } on RdwLookupException {
    rethrow;
  } catch (e) {
    throw RdwLookupException('Could not look up this plate: $e');
  }
}
