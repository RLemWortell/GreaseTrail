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

export function formatKm(n) {
  return Math.round(Math.abs(n))
    .toString()
    .replace(/\B(?=(\d{3})+(?!\d))/g, " ");
}

export function formatHeaderDate(d = new Date()) {
  const day = d.getDate();
  const mon = d.toLocaleString("en-GB", { month: "short" }).toUpperCase();
  return `${day} ${mon} ${d.getFullYear()}`;
}

function lastLog(vehicle, category) {
  return vehicle.logs
    .filter((l) => l.categoryId === category.id)
    .sort((a, b) => new Date(b.date) - new Date(a.date))[0];
}

export function getDueLabel(vehicle, category) {
  const last = lastLog(vehicle, category);
  if (!last) return "NEVER";

  let kmRatio = 0;
  let monthRatio = 0;
  let kmDelta = null;
  let dayDelta = null;

  if (category.intervalKm) {
    kmDelta = vehicle.odometer - last.odometer - category.intervalKm;
    kmRatio = (vehicle.odometer - last.odometer) / category.intervalKm;
  }
  if (category.intervalMonths) {
    const intervalDays = category.intervalMonths * 30.44;
    const daysSince = (Date.now() - new Date(last.date).getTime()) / 86400000;
    dayDelta = daysSince - intervalDays;
    monthRatio = daysSince / intervalDays;
  }

  const useDays = monthRatio >= kmRatio && dayDelta != null;
  if (useDays) return dayDelta >= 0 ? `+${Math.round(dayDelta)} DAYS` : `${Math.round(-dayDelta)} DAYS`;
  if (kmDelta != null) return kmDelta >= 0 ? `+${formatKm(kmDelta)} KM` : `${formatKm(-kmDelta)} KM`;
  return "";
}

export function getAttentionItems(vehicle) {
  return vehicle.categories
    .map((c) => {
      const status = getStatus(vehicle, c);
      if (!status || status.level === "ok") return null;
      return {
        vehicleId: vehicle.id,
        vehicleName: vehicle.name,
        categoryId: c.id,
        name: c.name,
        level: status.level,
        label: getDueLabel(vehicle, c),
        ratio: status.ratio,
        never: !status.last,
      };
    })
    .filter(Boolean)
    .sort((a, b) => {
      const rank = (item) => {
        if (item.level === "overdue" && !item.never) return 0;
        if (item.level === "overdue") return 1;
        return 2;
      };
      if (rank(a) !== rank(b)) return rank(a) - rank(b);
      return b.ratio - a.ratio;
    });
}

export function seedDemoData() {
  const v = seedVehicle("motorcycle", "Suzuki V-Strom", "DL650", 34210);
  const byName = (name) => v.categories.find((c) => c.name === name);
  const tire = byName("Tire pressure");
  const oil = byName("Oil change");
  const chain = byName("Chain tension");
  const brakes = byName("Brake pads");
  const coolant = byName("Coolant");

  v.logs = [
    {
      id: uid(),
      categoryId: chain.id,
      categoryName: "Chain tension",
      date: daysAgo(45),
      odometer: 33800,
      values: { Tension: "28" },
      note: "",
    },
    {
      id: uid(),
      categoryId: oil.id,
      categoryName: "Oil change",
      date: daysAgo(120),
      odometer: 28600,
      values: { Type: "With filter", "Amount added": "3.2" },
      note: "10W-40 fully synthetic",
    },
    {
      id: uid(),
      categoryId: tire.id,
      categoryName: "Tire pressure",
      date: daysAgo(48),
      odometer: 33980,
      values: { Front: "2.3", Rear: "2.5" },
      note: "",
    },
    {
      id: uid(),
      categoryId: brakes.id,
      categoryName: "Brake pads",
      date: daysAgo(80),
      odometer: 32000,
      values: { Front: "4.2", Rear: "5.0" },
      note: "",
    },
    {
      id: uid(),
      categoryId: coolant.id,
      categoryName: "Coolant",
      date: daysAgo(40),
      odometer: 34000,
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
