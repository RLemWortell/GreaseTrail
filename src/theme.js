// GreaseTrail — Minimal theme. Hairlines, no cards, one alert colour.
// Two schemes with identical keys; pick with useColorScheme() in App.js.

export const LIGHT = {
  bg: "#FCFCFB",
  ink: "#1A1A18",       // primary text, active dots, emphasis rules
  muted: "#9A9A95",     // labels, secondary values
  faint: "#C2C2BC",     // placeholders, disabled
  hairline: "#E8E8E4",  // row dividers
  rule: "#1A1A18",      // section / action rules
  dotOff: "#D6D6D0",    // outline dot border (on track)
  photo: "#F1F1EE",     // image placeholder fill
  alert: "#D8452F",     // overdue, destructive
};

export const DARK = {
  bg: "#0F0F0E",
  ink: "#F2F2EF",
  muted: "#77776F",
  faint: "#4A4A45",
  hairline: "#262624",
  rule: "#F2F2EF",
  dotOff: "#3B3B37",
  photo: "#1C1C1A",
  alert: "#FF6A4D",     // half a step lighter than LIGHT.alert so it does not glare
};

export const TYPE = {
  odometer: { fontSize: 44, fontWeight: "300", letterSpacing: -2.4, fontVariant: ["tabular-nums"] },
  title:    { fontSize: 26, fontWeight: "500", letterSpacing: -0.7 },
  category: { fontSize: 18, fontWeight: "500" },
  row:      { fontSize: 16, fontWeight: "400" },
  body:     { fontSize: 15, fontWeight: "400" },
  meta:     { fontSize: 13, fontWeight: "400" },
  small:    { fontSize: 12.5, fontWeight: "400" },
  label:    { fontSize: 12, fontWeight: "400", letterSpacing: 0.6, textTransform: "uppercase" },
};

export const SPACE = {
  side: 28,       // screen side padding
  rowY: 15,       // vertical padding inside a hairline row
  fieldY: 14,
  block: 30,      // gap between blocks
  hairline: 1,
};

// Status -> dot treatment. null interval = no dot at all.
export const DOT = {
  overdue: (c) => ({ backgroundColor: c.alert }),
  soon:    (c) => ({ backgroundColor: c.ink }),
  ok:      (c) => ({ borderWidth: 1, borderColor: c.dotOff }),
  none:    () => ({}),
};
