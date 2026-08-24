// GreaseTrail — warm shop-ledger look. Cream field, white cards, terracotta for what's due.

export const LIGHT = {
  bg: "#F5F5F0",
  surface: "#E8E6E0",
  card: "#FFFFFF",
  ink: "#1A1A1A",
  muted: "#8A8A84",
  faint: "#B4B4AE",
  hairline: "#E4E2DC",
  border: "#D0CEC8",
  accent: "#9E5E3D",
  soon: "#8A7A70",
  alert: "#9E5E3D",
  iconBg: "#1A1A1A",
  iconFg: "#FFFFFF",
  photo: "#EDEBE6",
  dotOff: "#D6D4CE",
};

export const DARK = {
  bg: "#161614",
  surface: "#1C1C19",
  card: "#242422",
  ink: "#F0EFEA",
  muted: "#8A8A82",
  faint: "#5C5C56",
  hairline: "#33332E",
  border: "#3A3A35",
  accent: "#C17A56",
  soon: "#A09086",
  alert: "#C17A56",
  iconBg: "#1A1A1A",
  iconFg: "#FFFFFF",
  photo: "#2A2A26",
  dotOff: "#4A4A44",
};

export const TYPE = {
  display:  { fontSize: 34, fontWeight: "700", letterSpacing: 0.4, textTransform: "uppercase" },
  odometer: { fontSize: 40, fontWeight: "300", letterSpacing: -1.4, fontVariant: ["tabular-nums"] },
  title:    { fontSize: 16, fontWeight: "700", letterSpacing: 0.3, textTransform: "uppercase" },
  category: { fontSize: 16, fontWeight: "600" },
  row:      { fontSize: 16, fontWeight: "400" },
  body:     { fontSize: 15, fontWeight: "400" },
  meta:     { fontSize: 11, fontWeight: "500", letterSpacing: 0.9, textTransform: "uppercase" },
  small:    { fontSize: 13, fontWeight: "400" },
  label:    { fontSize: 11, fontWeight: "500", letterSpacing: 1.4, textTransform: "uppercase" },
  date:     { fontSize: 11, fontWeight: "500", letterSpacing: 1.1, textTransform: "uppercase" },
  tab:      { fontSize: 10, fontWeight: "600", letterSpacing: 0.9, textTransform: "uppercase" },
};

export const SPACE = {
  side: 20,
  rowY: 14,
  fieldY: 14,
  block: 28,
  cardPad: 16,
  radius: 16,
  hairline: 1,
};

export const DOT = {
  overdue: (c) => ({ backgroundColor: c.accent }),
  soon:    (c) => ({ backgroundColor: c.soon }),
  ok:      (c) => ({ borderWidth: 1, borderColor: c.dotOff }),
  none:    () => ({ opacity: 0 }),
};
