import 'models.dart';

const _months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

String formatOdo(num n) {
  final v = n.round();
  final digits = v.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String formatDate(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return '${d.day} ${_months[d.month - 1]} ${d.year}';
}

String formatDateHeader([DateTime? d]) {
  final date = d ?? DateTime.now();
  return '${date.day} ${_months[date.month - 1]} ${date.year}';
}

bool isChecked(Object? v) => v == true || v == 'true' || v == 'yes' || v == 'done';

List<FieldDef> fieldsForLog(Vehicle? vehicle, LogEntry? log) {
  if (vehicle == null || log == null) return const [];
  final byId = vehicle.categories.where((c) => c.id == log.categoryId);
  final cat = byId.isNotEmpty ? byId.first : vehicle.categories.where((c) => c.name == log.categoryName).firstOrNull;
  return cat?.fields ?? const [];
}

String formatLogValues(Map<String, Object?>? values, List<FieldDef> fields) {
  if (values == null) return '';
  final byLabel = {for (final f in fields) f.label: f};
  return values.entries
      .where((e) => e.value != null && e.value != '' && e.value != false)
      .map((e) {
        if (isChecked(e.value)) return '${e.key} ✓';
        final unit = byLabel[e.key]?.unit;
        return unit != null ? '${e.key}: ${e.value} $unit' : '${e.key}: ${e.value}';
      })
      .join('  ·  ');
}

String formatLogLine(Vehicle? vehicle, LogEntry? log) {
  return formatLogValues(log?.values, fieldsForLog(vehicle, log));
}
