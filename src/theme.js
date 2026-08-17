// GreaseTrail — garage layout. Beige ground, white cards, rust alerts.
export const C = {
  bg: "#F5F3EF",
  card: "#FFFFFF",
  ink: "#1A1A1A",
  muted: "#A0A0A0",
  faint: "#C4C0BA",
  hairline: "#E6E3DE",
  rule: "#2C2C2C",
  accent: "#A65D46",
  soon: "#6B6058",
  iconBg: "#1A1A1A",
  iconFg: "#FFFFFF",
  tabOff: "#B3AEA8",
};

export const TYPE = {
  odometer: { fontSize: 36, fontWeight: "300", letterSpacing: -1.6, fontVariant: ["tabular-nums"] },
  title: { fontSize: 34, fontWeight: "700", letterSpacing: -0.6 },
  name: { fontSize: 15, fontWeight: "700", letterSpacing: 0.4, textTransform: "uppercase" },
  row: { fontSize: 16, fontWeight: "400" },
  body: { fontSize: 15, fontWeight: "400" },
  meta: { fontSize: 12, fontWeight: "400", letterSpacing: 0.4, textTransform: "uppercase" },
  small: { fontSize: 12, fontWeight: "400" },
  label: { fontSize: 11, fontWeight: "500", letterSpacing: 1.4, textTransform: "uppercase" },
  date: { fontSize: 11, fontWeight: "500", letterSpacing: 1.6, textTransform: "uppercase" },
};

export const SPACE = {
  side: 22,
  rowY: 16,
  fieldY: 14,
  block: 28,
  hairline: 1,
  radius: 16,
};

export const DOT = {
  overdue: { backgroundColor: C.accent },
  soon: { backgroundColor: C.soon },
  ok: { borderWidth: 1, borderColor: C.faint },
  none: {},
};
