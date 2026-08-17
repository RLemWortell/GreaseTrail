import React from "react";
import { View, Text, TouchableOpacity } from "react-native";
import { MaterialCommunityIcons } from "@expo/vector-icons";
import { C, TYPE, SPACE } from "../theme";
import { IconButton } from "./ui";

export default function TopBar({ title, onBack, right }) {
  return (
    <View
      style={{
        flexDirection: "row",
        alignItems: "center",
        justifyContent: "space-between",
        paddingTop: 8,
        paddingBottom: 14,
        minHeight: 48,
      }}
    >
      <View style={{ minWidth: 36 }}>{onBack ? <IconButton icon="chevron-left" onPress={onBack} /> : null}</View>
      {title ? (
        <Text style={[TYPE.name, { color: C.ink, flex: 1, textAlign: "center" }]} numberOfLines={1}>
          {title}
        </Text>
      ) : (
        <View style={{ flex: 1 }} />
      )}
      <View style={{ minWidth: 36, alignItems: "flex-end" }}>{right}</View>
    </View>
  );
}

export function TabBar({ tab, onChange }) {
  const items = [
    { key: "garage", label: "GARAGE", icon: "home-outline" },
    { key: "log", label: "LOG", icon: "text-box-outline" },
    { key: "setup", label: "SETUP", icon: "cog-outline" },
  ];

  return (
    <View
      style={{
        flexDirection: "row",
        borderTopWidth: SPACE.hairline,
        borderTopColor: C.hairline,
        paddingTop: 10,
        paddingBottom: 4,
        backgroundColor: C.bg,
      }}
    >
      {items.map((item) => {
        const active = tab === item.key;
        const color = active ? C.accent : C.tabOff;
        return (
          <TouchableOpacity
            key={item.key}
            onPress={() => onChange(item.key)}
            activeOpacity={0.7}
            style={{ flex: 1, alignItems: "center", gap: 4, paddingVertical: 4 }}
          >
            <MaterialCommunityIcons name={item.icon} size={22} color={color} />
            <Text style={{ fontSize: 10, fontWeight: "600", letterSpacing: 1.2, color }}>{item.label}</Text>
          </TouchableOpacity>
        );
      })}
    </View>
  );
}
