import React from "react";
import { View, Text, TextInput as RNTextInput, TouchableOpacity, useColorScheme } from "react-native";
import { LIGHT, DARK, TYPE, SPACE, DOT } from "../theme";

export function useC() {
  return useColorScheme() === "dark" ? DARK : LIGHT;
}

// Screen shell: fixed side padding, flat background.
export function Screen({ children, style }) {
  const c = useC();
  return <View style={[{ flex: 1, backgroundColor: c.bg, paddingHorizontal: SPACE.side }, style]}>{children}</View>;
}

// Small uppercase section label.
export function Label({ children }) {
  const c = useC();
  return <Text style={[TYPE.label, { color: c.muted, marginBottom: 2 }]}>{children}</Text>;
}

// Screen title.
export function Title({ children }) {
  const c = useC();
  return <Text style={[TYPE.title, { color: c.ink }]}>{children}</Text>;
}

// The workhorse: one hairline row. Left label/name, right value, optional dot and press.
export function Row({ left, right, dot = "none", onPress, emphasis = false, top = false }) {
  const c = useC();
  const Wrapper = onPress ? TouchableOpacity : View;
  return (
    <Wrapper
      onPress={onPress}
      activeOpacity={0.6}
      style={{
        flexDirection: "row",
        alignItems: "center",
        gap: 12,
        paddingVertical: SPACE.rowY,
        borderBottomWidth: SPACE.hairline,
        borderBottomColor: emphasis ? c.rule : c.hairline,
        borderTopWidth: top ? SPACE.hairline : 0,
        borderTopColor: c.rule,
        minHeight: 48,
      }}
    >
      {dot !== "hidden" && <Dot level={dot} />}
      <View style={{ flex: 1 }}>{typeof left === "string" ? <Text style={[TYPE.row, { color: c.ink }]}>{left}</Text> : left}</View>
      {typeof right === "string" ? <Text style={[TYPE.small, { color: c.muted }]}>{right}</Text> : right}
    </Wrapper>
  );
}

// 7px status dot. level: overdue | soon | ok | none
export function Dot({ level = "none" }) {
  const c = useC();
  return <View style={[{ width: 7, height: 7, borderRadius: 3.5 }, DOT[level] ? DOT[level](c) : {}]} />;
}

// Underlined field: label left, value right. No box, no radius.
export function Field({ label, value, unit, placeholder, emphasis = false, ...props }) {
  const c = useC();
  return (
    <View style={{
      flexDirection: "row", alignItems: "baseline", gap: 12,
      paddingVertical: SPACE.fieldY,
      borderBottomWidth: SPACE.hairline,
      borderBottomColor: emphasis ? c.rule : c.hairline,
    }}>
      <Text style={[TYPE.meta, { color: c.muted, flexShrink: 0 }]}>{label}</Text>
      <View style={{ flex: 1, flexDirection: "row", justifyContent: "flex-end", alignItems: "baseline", gap: 5 }}>
        <RNTextInput
          value={value}
          placeholder={placeholder}
          placeholderTextColor={c.faint}
          style={[TYPE.row, { color: c.ink, padding: 0, textAlign: "right", minWidth: 40 }]}
          {...props}
        />
        {unit ? <Text style={[TYPE.meta, { color: c.muted }]}>{unit}</Text> : null}
      </View>
    </View>
  );
}

// Radio list replacing ChipRow: one row per option, dot on the right.
export function OptionList({ options, value, onChange, getKey = (o) => o, getLabel = (o) => o }) {
  const c = useC();
  return (
    <View>
      {options.map((o) => {
        const active = getKey(o) === value;
        return (
          <TouchableOpacity
            key={getKey(o)}
            onPress={() => onChange(getKey(o))}
            activeOpacity={0.6}
            style={{
              flexDirection: "row", alignItems: "center", justifyContent: "space-between",
              paddingVertical: 13, minHeight: 48,
              borderBottomWidth: SPACE.hairline, borderBottomColor: c.hairline,
            }}
          >
            <Text style={[TYPE.row, { color: c.ink }]}>{getLabel(o)}</Text>
            <View style={[
              { width: 8, height: 8, borderRadius: 4 },
              active ? { backgroundColor: c.ink } : { borderWidth: 1, borderColor: c.dotOff },
            ]} />
          </TouchableOpacity>
        );
      })}
    </View>
  );
}

// Primary action: a hairline-topped text row, pinned to the bottom of the screen.
export function Action({ label, onPress, destructive = false }) {
  const c = useC();
  return (
    <TouchableOpacity
      onPress={onPress}
      activeOpacity={0.6}
      style={{ borderTopWidth: SPACE.hairline, borderTopColor: c.rule, paddingTop: 15, minHeight: 48 }}
    >
      <Text style={[TYPE.body, { color: destructive ? c.alert : c.ink, fontWeight: "500" }]}>{label}</Text>
    </TouchableOpacity>
  );
}
