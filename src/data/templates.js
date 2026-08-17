export const uid = () => Math.random().toString(36).slice(2, 9);

export function field(label, unit, type = "number", options = null) {
  return { id: uid(), label, unit, type, options };
}

// icon: MaterialCommunityIcons glyph name
export const TYPE_META = {
  motorcycle: { label: "Motorcycle", icon: "motorbike" },
  car: { label: "Car", icon: "car" },
  bicycle: { label: "Bicycle", icon: "bike" },
  scooter: { label: "Scooter / Moped", icon: "moped" },
};

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
    { name: "Wiper blades", fields: [], intervalKm: null, intervalMonths: 12 },
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
  return {
    id: uid(),
    type,
    name,
    model,
    odometer: odo,
    categories: TEMPLATES[type].map((c) => ({ ...c, id: uid(), fields: c.fields.map((f) => ({ ...f })) })),
    logs: [],
  };
}

export function seedDemoData() {
  const v = seedVehicle("motorcycle", "Suzuki V-Strom", "DL650", 34210);
  v.logs = [
    {
      id: uid(),
      categoryId: v.categories[0].id,
      categoryName: "Chain tension",
      date: daysAgo(45),
      odometer: 33800,
      values: { Tension: "28" },
      note: "",
    },
    {
      id: uid(),
      categoryId: v.categories[1].id,
      categoryName: "Oil change",
      date: daysAgo(120),
      odometer: 30500,
      values: { Type: "With filter", "Amount added": "3.2" },
      note: "10W-40 fully synthetic",
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
