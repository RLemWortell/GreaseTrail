import * as FileSystem from "expo-file-system";
import * as DocumentPicker from "expo-document-picker";
import { uid, TYPE_META, TEMPLATES, SERVICE_PACKAGES, field, defaultServices, getServiceRecords } from "./templates";
import { shareJsonFile } from "./export";

function stripField(f) {
  return {
    label: f.label,
    unit: f.unit ?? null,
    type: f.type || "number",
    options: f.options || null,
  };
}

function stripCategory(c) {
  return {
    name: c.name,
    intervalKm: c.intervalKm ?? null,
    intervalMonths: c.intervalMonths ?? null,
    fields: (c.fields || []).map(stripField),
  };
}

export function builtinConfigs() {
  return Object.keys(TEMPLATES).map((type) => ({
    id: `builtin-${type}`,
    builtin: true,
    name: TYPE_META[type]?.label || type,
    type,
    categories: TEMPLATES[type].map(stripCategory),
    services: (SERVICE_PACKAGES[type] || []).map((p) => ({ name: p.name, items: [...p.items] })),
  }));
}

export function configFromVehicle(vehicle, name) {
  const categories = (vehicle.categories || []).map(stripCategory);
  const services = getServiceRecords(vehicle).map((s) => ({
    name: s.name,
    items: (s.categoryIds || [])
      .map((id) => vehicle.categories.find((c) => c.id === id)?.name)
      .filter(Boolean),
  }));
  return {
    app: "GreaseTrail",
    kind: "config",
    version: 1,
    id: uid(),
    name: name || `${vehicle.name} setup`,
    type: vehicle.type,
    categories,
    services,
  };
}

export function vehicleFromConfig(config, name, model, odo) {
  const categories = (config.categories || []).map((c) => ({
    id: uid(),
    name: c.name,
    intervalKm: c.intervalKm ?? null,
    intervalMonths: c.intervalMonths ?? null,
    fields: (c.fields || []).map((f) => field(f.label, f.unit, f.type || "number", f.options || null)),
  }));
  const vehicle = {
    id: uid(),
    type: config.type || "motorcycle",
    name,
    model: model || "",
    odometer: Number(odo) || 0,
    photos: [],
    categories,
    logs: [],
  };
  const packs = config.services || [];
  vehicle.services = packs.length
    ? packs.map((s) => ({
        id: uid(),
        name: s.name,
        categoryIds: (s.items || [])
          .map((itemName) => categories.find((c) => c.name === itemName)?.id)
          .filter(Boolean),
      }))
    : defaultServices(vehicle);
  return vehicle;
}

export function duplicateConfig(config) {
  return {
    app: "GreaseTrail",
    kind: "config",
    version: 1,
    id: uid(),
    builtin: false,
    name: `${config.name} copy`,
    type: config.type,
    categories: (config.categories || []).map(stripCategory),
    services: (config.services || []).map((s) => ({ name: s.name, items: [...(s.items || [])] })),
  };
}

export function parseConfig(raw) {
  const data = typeof raw === "string" ? JSON.parse(raw) : raw;
  if (!data || data.app !== "GreaseTrail") {
    throw new Error("Not a GreaseTrail file.");
  }
  if (data.kind !== "config") {
    throw new Error("This file is a data backup, not a config.");
  }
  if (!Array.isArray(data.categories) || !data.type) {
    throw new Error("Config is missing type or categories.");
  }
  return {
    app: "GreaseTrail",
    kind: "config",
    version: 1,
    id: uid(),
    builtin: false,
    name: data.name || `${TYPE_META[data.type]?.label || data.type} setup`,
    type: data.type,
    categories: data.categories.map(stripCategory),
    services: (data.services || []).map((s) => ({ name: s.name, items: s.items || [] })),
  };
}

function slug(name) {
  return String(name || "config")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "")
    .slice(0, 40) || "config";
}

export async function exportConfig(config) {
  const payload = {
    app: "GreaseTrail",
    kind: "config",
    version: 1,
    name: config.name,
    type: config.type,
    categories: config.categories,
    services: config.services,
  };
  await shareJsonFile(`greasetrail-config-${slug(config.name)}.json`, JSON.stringify(payload, null, 2), "Export config");
}

export async function importConfigFile() {
  const result = await DocumentPicker.getDocumentAsync({
    type: ["application/json", "text/plain", "*/*"],
    copyToCacheDirectory: true,
  });
  if (result.canceled || result.type === "cancel") return null;
  const uri = result.assets?.[0]?.uri || result.uri;
  if (!uri) return null;
  const raw = await FileSystem.readAsStringAsync(uri);
  return parseConfig(raw);
}
