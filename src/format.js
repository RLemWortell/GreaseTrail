const MONTHS = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];

export function formatOdo(n) {
  const v = Math.round(Number(n) || 0);
  return v.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ");
}

export function formatDate(iso) {
  if (!iso) return "";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return iso;
  return `${d.getDate()} ${MONTHS[d.getMonth()]} ${d.getFullYear()}`;
}

export function formatDateHeader(d = new Date()) {
  return `${d.getDate()} ${MONTHS[d.getMonth()]} ${d.getFullYear()}`;
}

export function isChecked(v) {
  return v === true || v === "true" || v === "yes" || v === "done";
}

export function fieldsForLog(vehicle, log) {
  if (!vehicle || !log) return [];
  const cats = vehicle.categories || [];
  const cat =
    cats.find((c) => c.id === log.categoryId) || cats.find((c) => c.name === log.categoryName);
  return cat?.fields || [];
}

export function formatLogValues(values, fields) {
  if (!values) return "";
  const byLabel = new Map((fields || []).map((f) => [f.label, f]));
  return Object.entries(values)
    .filter(([, v]) => v != null && v !== "" && v !== false)
    .map(([k, v]) => {
      if (isChecked(v)) return `${k} ✓`;
      const unit = byLabel.get(k)?.unit;
      return unit ? `${k}: ${v} ${unit}` : `${k}: ${v}`;
    })
    .join("  ·  ");
}

export function formatLogLine(vehicle, log) {
  return formatLogValues(log?.values, fieldsForLog(vehicle, log));
}
