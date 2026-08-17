import React from "react";
import {
  View,
  Text,
  TextInput as RNTextInput,
  TouchableOpacity,
  StyleSheet,
} from "react-native";
import { Feather } from "@expo/vector-icons";
import { T } from "../theme";

export function Panel({ children, style, onPress }) {
  const Wrapper = onPress ? TouchableOpacity : View;
  return (
    <Wrapper
      onPress={onPress}
      activeOpacity={onPress ? 0.7 : 1}
      style={[styles.panel, style]}
    >
      {children}
    </Wrapper>
  );
}

export function PrimaryButton({ label, onPress, icon, style, textStyle, disabled }) {
  return (
    <TouchableOpacity
      onPress={onPress}
      activeOpacity={0.8}
      disabled={disabled}
      style={[styles.primaryButton, disabled && { opacity: 0.5 }, style]}
    >
      {icon ? <Feather name={icon} size={16} color={textStyle?.color || "#fff"} style={{ marginRight: 6 }} /> : null}
      <Text style={[styles.primaryButtonText, textStyle]}>{label}</Text>
    </TouchableOpacity>
  );
}

export function IconButton({ icon, onPress, color = T.textPrimary, size = 19 }) {
  return (
    <TouchableOpacity onPress={onPress} style={styles.iconButton} hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}>
      <Feather name={icon} size={size} color={color} />
    </TouchableOpacity>
  );
}

export function FieldLabel({ children }) {
  return <Text style={styles.label}>{children}</Text>;
}

export function TextInput({ style, ...props }) {
  return (
    <RNTextInput
      placeholderTextColor={T.textTertiary}
      style={[styles.input, style]}
      {...props}
    />
  );
}

// Horizontal row of pressable chips — used for vehicle type and select-type fields
export function ChipRow({ options, value, onChange, getLabel = (o) => o, getKey = (o) => o }) {
  return (
    <View style={{ flexDirection: "row", flexWrap: "wrap", gap: 8 }}>
      {options.map((opt) => {
        const active = getKey(opt) === value;
        return (
          <TouchableOpacity
            key={getKey(opt)}
            onPress={() => onChange(getKey(opt))}
            activeOpacity={0.7}
            style={[styles.chip, active && styles.chipActive]}
          >
            <Text style={[styles.chipText, active && styles.chipTextActive]}>{getLabel(opt)}</Text>
          </TouchableOpacity>
        );
      })}
    </View>
  );
}

export function Badge({ color, softColor, icon, text }) {
  return (
    <View style={[styles.badge, { backgroundColor: softColor }]}>
      <Feather name={icon} size={11} color={color} style={{ marginRight: 4 }} />
      <Text style={[styles.badgeText, { color }]}>{text}</Text>
    </View>
  );
}

export function SectionLabel({ children }) {
  return <Text style={styles.sectionLabel}>{children}</Text>;
}

const styles = StyleSheet.create({
  panel: {
    backgroundColor: T.bgSurface,
    borderWidth: 1,
    borderColor: T.hairline,
    borderRadius: 14,
  },
  primaryButton: {
    backgroundColor: T.accent,
    borderRadius: 12,
    paddingVertical: 14,
    paddingHorizontal: 16,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    minHeight: 48,
  },
  primaryButtonText: {
    color: "#fff",
    fontWeight: "600",
    fontSize: 15,
  },
  iconButton: {
    width: 38,
    height: 38,
    borderRadius: 10,
    alignItems: "center",
    justifyContent: "center",
  },
  label: {
    color: T.textSecondary,
    fontSize: 12.5,
    marginBottom: 7,
    fontWeight: "500",
  },
  input: {
    width: "100%",
    backgroundColor: T.bgSurfaceRaised,
    borderWidth: 1,
    borderColor: T.hairline,
    borderRadius: 10,
    paddingVertical: 12,
    paddingHorizontal: 13,
    color: T.textPrimary,
    fontSize: 15,
    minHeight: 46,
  },
  chip: {
    paddingVertical: 10,
    paddingHorizontal: 12,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: T.hairline,
    backgroundColor: T.bgSurfaceRaised,
  },
  chipActive: {
    borderColor: T.accent,
    backgroundColor: T.accentSoft,
  },
  chipText: {
    color: T.textSecondary,
    fontSize: 12.5,
    fontWeight: "600",
  },
  chipTextActive: {
    color: T.accent,
  },
  badge: {
    flexDirection: "row",
    alignItems: "center",
    borderRadius: 6,
    paddingVertical: 4,
    paddingHorizontal: 8,
  },
  badgeText: {
    fontSize: 12,
    fontWeight: "600",
  },
  sectionLabel: {
    color: T.textSecondary,
    fontSize: 12,
    fontWeight: "600",
    letterSpacing: 0.5,
    marginBottom: 10,
    textTransform: "uppercase",
  },
});
