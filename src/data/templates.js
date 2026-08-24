export const uid = () => Math.random().toString(36).slice(2, 9);

export function field(label, unit, type = "number", options = null) {
  return { id: uid(), label, unit, type, options };
}

export const FIELD_TYPES = [
  { key: "number", label: "Number" },
  { key: "text", label: "Text" },
  { key: "checkbox", label: "Checkbox" },
];

// icon: MaterialCommunityIcons glyph name
export const TYPE_META = {
  motorcycle: { label: "Motorcycle", icon: "motorbike" },
  car: { label: "Car", icon: "car" },
  bicycle: { label: "Bicycle", icon: "bike" },
  scooter: { label: "Scooter / Moped", icon: "moped" },
};

export const SERVICE_PACKAGES = {
  motorcycle: [
    { id: "minor", name: "Minor service", items: ["Oil change", "Chain tension", "Tire pressure"] },
    {
      id: "major",
      name: "Major service",
      items: ["Oil change", "Chain tension", "Tire pressure", "Brake pads", "Coolant", "Battery", "Scott oiler"],
    },
  ],
  car: [
    { id: "minor", name: "Minor service", items: ["Oil change", "Tire pressure", "Wiper blades"] },
    {
      id: "major",
      name: "Major service",
      items: ["Oil change", "Tire pressure", "Tire tread", "Brake pads", "Coolant", "Wiper blades"],
    },
  ],
  bicycle: [
    { id: "minor", name: "Minor service", items: ["Chain lube", "Tire pressure"] },
    {
      id: "major",
      name: "Major service",
      items: ["Chain lube", "Chain wear", "Tire pressure", "Brake pads", "Gear cable tension"],
    },
  ],
  scooter: [
    { id: "minor", name: "Minor service", items: ["Oil change", "Tire pressure"] },
    {
      id: "major",
      name: "Major service",
      items: ["Oil change", "Tire pressure", "Variator / belt", "Spark plug"],
    },
  ],
};

export function defaultServices(vehicle) {
  return (SERVICE_PACKAGES[vehicle.type] || []).map((pack) => ({
    id: pack.id,
    name: pack.name,
    categoryIds: pack.items
      .map((name) => vehicle.categories.find((c) => c.name === name)?.id)
      .filter(Boolean),
  }));
}

export function getServiceRecords(vehicle) {
  if (Array.isArray(vehicle.services)) return vehicle.services;
  return defaultServices(vehicle);
}

export function getServicePackages(vehicle) {
  return getServiceRecords(vehicle).map((pack) => ({
    ...pack,
    categories: (pack.categoryIds || [])
      .map((id) => vehicle.categories.find((c) => c.id === id))
      .filter(Boolean),
  }));
}

export function upsertService(vehicle, pack) {
  const current = getServiceRecords(vehicle);
  const exists = current.some((s) => s.id === pack.id);
  return {
    ...vehicle,
    services: exists ? current.map((s) => (s.id === pack.id ? pack : s)) : [...current, pack],
  };
}

export function removeService(vehicle, id) {
  return {
    ...vehicle,
    services: getServiceRecords(vehicle).filter((s) => s.id !== id),
  };
}

export function emptyFieldValues(category, checkboxDefault = false) {
  return Object.fromEntries(
    (category.fields || []).map((f) => [f.label, f.type === "checkbox" ? checkboxDefault : ""])
  );
}

export const TEMPLATES = {
  motorcycle: [
    { name: "Chain tension", fields: [field("Tension", "mm")], intervalKm: 1000, intervalMonths: null },
    {
      name: "Oil change",
      fields: [
        field("Type", null, "select", ["Full change", "With filter", "Topped up"]),
        field("Amount added", "L"),
      ],
      intervalKm: 6000,
      intervalMonths: 12,
    },
    { name: "Scott oiler", fields: [field("Setting", null, "text")], intervalKm: null, intervalMonths: null },
    {
      name: "Tire pressure",
      fields: [field("Front", "bar"), field("Rear", "bar")],
      intervalKm: null,
      intervalMonths: 1,
    },
    {
      name: "Brake pads",
      fields: [field("Front", "mm"), field("Rear", "mm")],
      intervalKm: 5000,
      intervalMonths: null,
    },
    { name: "Coolant", fields: [field("Topped up", "L")], intervalKm: null, intervalMonths: 12 },
    { name: "Battery", fields: [field("Voltage", "V")], intervalKm: null, intervalMonths: 6 },
  ],
  car: [
    {
      name: "Oil change",
      fields: [
        field("Type", null, "select", ["Full change", "With filter", "Topped up"]),
        field("Amount added", "L"),
      ],
      intervalKm: 15000,
      intervalMonths: 12,
    },
    {
      name: "Tire pressure",
      fields: [
        field("Front left", "bar"),
        field("Front right", "bar"),
        field("Rear left", "bar"),
        field("Rear right", "bar"),
      ],
      intervalKm: null,
      intervalMonths: 1,
    },
    {
      name: "Tire tread",
      fields: [field("Front", "mm"), field("Rear", "mm")],
      intervalKm: null,
      intervalMonths: 6,
    },
    {
      name: "Brake pads",
      fields: [field("Front", "mm"), field("Rear", "mm")],
      intervalKm: 20000,
      intervalMonths: null,
    },
    { name: "Coolant", fields: [field("Topped up", "L")], intervalKm: null, intervalMonths: 24 },
    {
      name: "Wiper blades",
      fields: [field("Front", null, "checkbox"), field("Rear", null, "checkbox")],
      intervalKm: null,
      intervalMonths: 12,
    },
  ],
  bicycle: [
    { name: "Chain lube", fields: [], intervalKm: 300, intervalMonths: null },
    { name: "Chain wear", fields: [field("Wear", "%")], intervalKm: null, intervalMonths: 6 },
    {
      name: "Tire pressure",
      fields: [field("Front", "bar"), field("Rear", "bar")],
      intervalKm: null,
      intervalMonths: null,
    },
    { name: "Brake pads", fields: [field("Front", "mm"), field("Rear", "mm")], intervalKm: 2000, intervalMonths: null },
    { name: "Gear cable tension", fields: [field("Notes", null, "text")], intervalKm: null, intervalMonths: 12 },
  ],
  scooter: [
    {
      name: "Oil change",
      fields: [
        field("Type", null, "select", ["Full change", "With filter", "Topped up"]),
        field("Amount added", "L"),
      ],
      intervalKm: 3000,
      intervalMonths: 12,
    },
    { name: "Variator / belt", fields: [field("Condition", null, "text")], intervalKm: 8000, intervalMonths: null },
    { name: "Tire pressure", fields: [field("Front", "bar"), field("Rear", "bar")], intervalKm: null, intervalMonths: 1 },
    { name: "Spark plug", fields: [field("Notes", null, "text")], intervalKm: 6000, intervalMonths: null },
  ],
};

const daysAgo = (n) => new Date(Date.now() - n * 86400000).toISOString().slice(0, 10);

export function seedVehicle(type, name, model, odo) {
  const vehicle = {
    id: uid(),
    type,
    name,
    model,
    odometer: odo,
    photos: [],
    categories: TEMPLATES[type].map((c) => ({ ...c, id: uid(), fields: c.fields.map((f) => ({ ...f })) })),
    logs: [],
  };
  vehicle.services = defaultServices(vehicle);
  return vehicle;
}

export function seedDemoData() {
  const v = seedVehicle("motorcycle", "Suzuki V-Strom", "DL650", 34210);
  const cat = (name) => v.categories.find((c) => c.name === name);
  v.logs = [
    {
      id: uid(),
      categoryId: cat("Chain tension").id,
      categoryName: "Chain tension",
      date: daysAgo(45),
      odometer: 33800,
      values: { Tension: "28" },
      note: "",
    },
    {
      id: uid(),
      categoryId: cat("Oil change").id,
      categoryName: "Oil change",
      date: daysAgo(120),
      odometer: 28600,
      values: { Type: "With filter", "Amount added": "3.2" },
      note: "10W-40 fully synthetic",
    },
    {
      id: uid(),
      categoryId: cat("Tire pressure").id,
      categoryName: "Tire pressure",
      date: daysAgo(48),
      odometer: 33100,
      values: { Front: "2.3", Rear: "2.5" },
      note: "",
    },
    {
      id: uid(),
      categoryId: cat("Brake pads").id,
      categoryName: "Brake pads",
      date: daysAgo(30),
      odometer: 32000,
      values: { Front: "4.2", Rear: "3.8" },
      note: "",
    },
    {
      id: uid(),
      categoryId: cat("Coolant").id,
      categoryName: "Coolant",
      date: daysAgo(60),
      odometer: 32800,
      values: { "Topped up": "0.2" },
      note: "",
    },
  ];
  return [v];
}

// Due-status: null if no interval configured, otherwise ok / soon / overdue
export function getStatus(vehicle, category) {
  if (!category.intervalKm && !category.intervalMonths) return null;
  const logs = vehicle.logs
    .filter((l) => l.categoryId === category.id)
    .sort((a, b) => new Date(b.date) - new Date(a.date));
  const last = logs[0];
  let kmRatio = 0;
  let monthRatio = 0;
  if (category.intervalKm) {
    const lastOdo = last ? last.odometer : 0;
    kmRatio = (vehicle.odometer - lastOdo) / category.intervalKm;
  }
  if (category.intervalMonths) {
    const lastDate = last ? new Date(last.date) : new Date(0);
    const monthsSince = (Date.now() - lastDate.getTime()) / (1000 * 60 * 60 * 24 * 30.44);
    monthRatio = monthsSince / category.intervalMonths;
  }
  const ratio = Math.max(kmRatio, monthRatio);
  if (ratio >= 1) return { level: "overdue", ratio, last };
  if (ratio >= 0.9) return { level: "soon", ratio, last };
  return { level: "ok", ratio, last };
}

export const STATUS_LABEL = { overdue: "Overdue", soon: "Due soon", ok: "On track" };

export function attentionLabel(vehicle, category) {
  const status = getStatus(vehicle, category);
  if (!status) return null;
  const last = status.last;
  if (!last) return "NEVER";

  const kmRatio = category.intervalKm ? (vehicle.odometer - last.odometer) / category.intervalKm : 0;
  const monthRatio = category.intervalMonths
    ? (Date.now() - new Date(last.date).getTime()) / (1000 * 60 * 60 * 24 * 30.44) / category.intervalMonths
    : 0;

  if (kmRatio >= monthRatio && category.intervalKm) {
    const delta = Math.round(vehicle.odometer - last.odometer - category.intervalKm);
    return `${Math.abs(delta)} KM`;
  }
  if (category.intervalMonths) {
    const daysSince = (Date.now() - new Date(last.date).getTime()) / 86400000;
    const delta = Math.round(daysSince - category.intervalMonths * 30.44);
    return delta >= 0 ? `+${delta} DAYS` : `${Math.abs(delta)} DAYS`;
  }
  return STATUS_LABEL[status.level];
}

export function getAttentionItems(vehicle) {
  return vehicle.categories
    .map((cat) => {
      const status = getStatus(vehicle, cat);
      if (!status || status.level === "ok") return null;
      return {
        id: cat.id,
        name: cat.name,
        level: status.level,
        label: attentionLabel(vehicle, cat),
      };
    })
    .filter(Boolean);
}

export function countAttention(vehicle) {
  const items = getAttentionItems(vehicle);
  return {
    overdue: items.filter((i) => i.level === "overdue").length,
    soon: items.filter((i) => i.level === "soon").length,
  };
}
