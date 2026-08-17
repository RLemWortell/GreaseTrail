import React from "react";
import { View, Text, TextInput as RNTextInput, TouchableOpacity } from "react-native";
import { Feather } from "@expo/vector-icons";
import { C, TYPE, SPACE, DOT } from "../theme";

export function Screen({ children, style }) {
  return <View style={[{ flex: 1, backgroundColor: C.bg, paddingHorizontal: SPACE.side }, style]}>{children}</View>;
}

export function Card({ children, style, onPress }) {
  const Wrapper = onPress ? TouchableOpacity : View;
  return (
    <Wrapper
      onPress={onPress}
      activeOpacity={onPress ? 0.7 : 1}
      style={[{ backgroundColor: C.card, borderRadius: SPACE.radius, overflow: "hidden" }, style]}
    >
      {children}
    </Wrapper>
  );
}

export function Label({ children, style }) {
  return <Text style={[TYPE.label, { color: C.muted }, style]}>{children}</Text>;
}

export function Title({ children, style }) {
  return <Text style={[TYPE.title, { color: C.ink }, style]}>{children}</Text>;
}

export function Dot({ level = "none" }) {
  return <View style={[{ width: 7, height: 7, borderRadius: 3.5 }, DOT[level] || {}]} />;
}

export function IconButton({ icon, onPress, color = C.ink, size = 20 }) {
  return (
    <TouchableOpacity onPress={onPress} hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}>
      <Feather name={icon} size={size} color={color} />
    </TouchableOpacity>
  );
}

export function PlusButton({ onPress }) {
  return (
    <TouchableOpacity
      onPress={onPress}
      activeOpacity={0.7}
      style={{
        width: 36,
        height: 36,
        borderRadius: 10,
        borderWidth: 1,
        borderColor: C.ink,
        alignItems: "center",
        justifyContent: "center",
      }}
    >
      <Feather name="plus" size={18} color={C.ink} />
    </TouchableOpacity>
  );
}

export function Field({ label, value, unit, placeholder, emphasis = false, ...props }) {
  return (
    <View
      style={{
        flexDirection: "row",
        alignItems: "baseline",
        gap: 12,
        paddingVertical: SPACE.fieldY,
        borderBottomWidth: SPACE.hairline,
        borderBottomColor: emphasis ? C.rule : C.hairline,
      }}
    >
      <Text style={[TYPE.meta, { color: C.muted, flexShrink: 0 }]}>{label}</Text>
      <View style={{ flex: 1, flexDirection: "row", justifyContent: "flex-end", alignItems: "baseline", gap: 5 }}>
        <RNTextInput
          value={value}
          placeholder={placeholder}
          placeholderTextColor={C.faint}
          style={[TYPE.row, { color: C.ink, padding: 0, textAlign: "right", minWidth: 40 }]}
          {...props}
        />
        {unit ? <Text style={[TYPE.meta, { color: C.muted }]}>{unit}</Text> : null}
      </View>
    </View>
  );
}

export function OptionList({ options, value, onChange, getKey = (o) => o, getLabel = (o) => o }) {
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
              flexDirection: "row",
              alignItems: "center",
              justifyContent: "space-between",
              paddingVertical: 13,
              minHeight: 48,
              borderBottomWidth: SPACE.hairline,
              borderBottomColor: C.hairline,
            }}
          >
            <Text style={[TYPE.row, { color: C.ink }]}>{getLabel(o)}</Text>
            <View
              style={[
                { width: 8, height: 8, borderRadius: 4 },
                active ? { backgroundColor: C.ink } : { borderWidth: 1, borderColor: C.faint },
              ]}
            />
          </TouchableOpacity>
        );
      })}
    </View>
  );
}

export function Action({ label, onPress, destructive = false }) {
  return (
    <TouchableOpacity
      onPress={onPress}
      activeOpacity={0.6}
      style={{ borderTopWidth: SPACE.hairline, borderTopColor: C.rule, paddingTop: 15, minHeight: 48 }}
    >
      <Text style={[TYPE.body, { color: destructive ? C.accent : C.ink, fontWeight: "500" }]}>{label}</Text>
    </TouchableOpacity>
  );
}

export function SearchField({ value, onChangeText, placeholder = "Search vehicles." }) {
  return (
    <View
      style={{
        flexDirection: "row",
        alignItems: "center",
        gap: 10,
        paddingBottom: 10,
        borderBottomWidth: SPACE.hairline,
        borderBottomColor: C.hairline,
      }}
    >
      <Feather name="search" size={16} color={C.muted} />
      <RNTextInput
        value={value}
        onChangeText={onChangeText}
        placeholder={placeholder}
        placeholderTextColor={C.muted}
        style={[TYPE.body, { flex: 1, color: C.ink, padding: 0 }]}
      />
    </View>
  );
}
