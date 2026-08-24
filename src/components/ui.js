import React from "react";
import {
  View,
  Text,
  TextInput as RNTextInput,
  TouchableOpacity,
  useColorScheme,
  StyleSheet,
  Image,
} from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { Ionicons, MaterialCommunityIcons } from "@expo/vector-icons";
import { LIGHT, DARK, TYPE, SPACE, DOT } from "../theme";
import { formatDateHeader } from "../format";

export function useC() {
  return useColorScheme() === "dark" ? DARK : LIGHT;
}

export function Screen({ children, style }) {
  const c = useC();
  return (
    <View style={[{ flex: 1, backgroundColor: c.bg, paddingHorizontal: SPACE.side }, style]}>
      {children}
    </View>
  );
}

export function Label({ children, style }) {
  const c = useC();
  return <Text style={[TYPE.label, { color: c.muted }, style]}>{children}</Text>;
}

export function Title({ children }) {
  const c = useC();
  return <Text style={[TYPE.display, { color: c.ink }]}>{children}</Text>;
}

export function Card({ children, style }) {
  const c = useC();
  return (
    <View style={[{ backgroundColor: c.card, borderRadius: SPACE.radius, overflow: "hidden" }, style]}>
      {children}
    </View>
  );
}

export function Divider({ inset = true }) {
  const c = useC();
  return (
    <View
      style={{
        height: StyleSheet.hairlineWidth,
        backgroundColor: c.hairline,
        marginHorizontal: inset ? SPACE.cardPad : 0,
      }}
    />
  );
}

export function SectionHeader({ children }) {
  const c = useC();
  return (
    <View style={{ marginBottom: 12 }}>
      <Text style={[TYPE.label, { color: c.muted, marginBottom: 8 }]}>{children}</Text>
      <View style={{ height: StyleSheet.hairlineWidth, backgroundColor: c.hairline }} />
    </View>
  );
}

export function SquareButton({ onPress, icon = "add" }) {
  const c = useC();
  return (
    <TouchableOpacity
      onPress={onPress}
      activeOpacity={0.6}
      hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
      style={{
        width: 36,
        height: 36,
        borderRadius: 8,
        borderWidth: 1,
        borderColor: c.border,
        alignItems: "center",
        justifyContent: "center",
      }}
    >
      <Ionicons name={icon} size={20} color={c.ink} />
    </TouchableOpacity>
  );
}

export function ScreenHeader({ title, onBack, onRightPress, rightIcon = "add", rightLabel, subtitle }) {
  const c = useC();
  return (
    <View style={{ paddingHorizontal: SPACE.side, paddingTop: 4, paddingBottom: 8 }}>
      <View style={{ flexDirection: "row", alignItems: "center", justifyContent: "space-between", minHeight: 36 }}>
        {onBack ? (
          <TouchableOpacity onPress={onBack} hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}>
            <Ionicons name="chevron-back" size={24} color={c.ink} />
          </TouchableOpacity>
        ) : (
          <Text style={[TYPE.date, { color: c.muted }]}>{formatDateHeader()}</Text>
        )}
        {onRightPress && rightIcon ? (
          <SquareButton icon={rightIcon} onPress={onRightPress} />
        ) : onRightPress && rightLabel ? (
          <TouchableOpacity onPress={onRightPress} hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}>
            <Text style={[TYPE.label, { color: c.ink }]}>{rightLabel}</Text>
          </TouchableOpacity>
        ) : (
          <View style={{ width: 36 }} />
        )}
      </View>
      <Text style={[TYPE.display, { color: c.ink, marginTop: 6 }]}>{title}</Text>
      {subtitle ? (
        <Text style={[TYPE.label, { color: c.muted, marginTop: 4 }]}>{subtitle}</Text>
      ) : null}
    </View>
  );
}

export function SearchBar({ value, onChangeText, placeholder }) {
  const c = useC();
  return (
    <View>
      <View style={{ flexDirection: "row", alignItems: "center", gap: 8, paddingVertical: 12 }}>
        <Ionicons name="search" size={15} color={c.faint} />
        <RNTextInput
          value={value}
          onChangeText={onChangeText}
          placeholder={placeholder}
          placeholderTextColor={c.faint}
          style={[TYPE.body, { flex: 1, color: c.ink, padding: 0 }]}
        />
      </View>
      <View style={{ height: StyleSheet.hairlineWidth, backgroundColor: c.hairline }} />
    </View>
  );
}

export function TypeIcon({ type, size = 36, photo }) {
  const c = useC();
  const names = { motorcycle: "motorbike", car: "car", bicycle: "bike", scooter: "moped" };
  if (photo) {
    return (
      <Image
        source={{ uri: photo }}
        style={{ width: size, height: size, borderRadius: 8, backgroundColor: c.photo }}
      />
    );
  }
  return (
    <View
      style={{
        width: size,
        height: size,
        borderRadius: 8,
        backgroundColor: c.iconBg,
        alignItems: "center",
        justifyContent: "center",
      }}
    >
      <MaterialCommunityIcons name={names[type] || "car"} size={Math.round(size * 0.55)} color={c.iconFg} />
    </View>
  );
}

export function CardRow({ left, right, dot = "hidden", onPress, divider = true, chevron = false }) {
  const c = useC();
  const Wrapper = onPress ? TouchableOpacity : View;
  return (
    <>
      <Wrapper
        onPress={onPress}
        activeOpacity={0.6}
        style={{
          flexDirection: "row",
          alignItems: "center",
          gap: 12,
          paddingHorizontal: SPACE.cardPad,
          paddingVertical: SPACE.rowY,
          minHeight: 48,
        }}
      >
        {dot !== "hidden" && <Dot level={dot} />}
        <View style={{ flex: 1 }}>{typeof left === "string" ? <Text style={[TYPE.row, { color: c.ink }]}>{left}</Text> : left}</View>
        {typeof right === "string" ? <Text style={[TYPE.meta, { color: c.muted }]}>{right}</Text> : right}
        {chevron ? <Ionicons name="chevron-forward" size={16} color={c.faint} /> : null}
      </Wrapper>
      {divider ? <Divider /> : null}
    </>
  );
}

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
        borderBottomColor: emphasis ? c.ink : c.hairline,
        borderTopWidth: top ? SPACE.hairline : 0,
        borderTopColor: c.ink,
        minHeight: 48,
      }}
    >
      {dot !== "hidden" && <Dot level={dot} />}
      <View style={{ flex: 1 }}>{typeof left === "string" ? <Text style={[TYPE.row, { color: c.ink }]}>{left}</Text> : left}</View>
      {typeof right === "string" ? <Text style={[TYPE.small, { color: c.muted }]}>{right}</Text> : right}
    </Wrapper>
  );
}

export function Dot({ level = "none" }) {
  const c = useC();
  return <View style={[{ width: 7, height: 7, borderRadius: 3.5 }, DOT[level] ? DOT[level](c) : {}]} />;
}

export function CheckRow({ label, checked, onToggle, last = false }) {
  const c = useC();
  return (
    <>
      <TouchableOpacity
        onPress={onToggle}
        activeOpacity={0.6}
        style={{
          flexDirection: "row",
          alignItems: "center",
          justifyContent: "space-between",
          paddingHorizontal: SPACE.cardPad,
          paddingVertical: SPACE.rowY,
          minHeight: 48,
        }}
      >
        <Text style={[TYPE.row, { color: c.ink }]}>{label}</Text>
        <View
          style={{
            width: 22,
            height: 22,
            borderRadius: 6,
            borderWidth: checked ? 0 : 1,
            borderColor: c.border,
            backgroundColor: checked ? c.accent : "transparent",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          {checked ? <Ionicons name="checkmark" size={14} color={c.iconFg} /> : null}
        </View>
      </TouchableOpacity>
      {!last ? <Divider /> : null}
    </>
  );
}

export function Field({ label, value, unit, placeholder, last = false, ...props }) {
  const c = useC();
  return (
    <>
      <View
        style={{
          flexDirection: "row",
          alignItems: "baseline",
          gap: 12,
          paddingHorizontal: SPACE.cardPad,
          paddingVertical: SPACE.fieldY,
        }}
      >
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
      {!last ? <Divider /> : null}
    </>
  );
}

export function OptionList({ options, value, onChange, getKey = (o) => o, getLabel = (o) => o }) {
  const c = useC();
  return (
    <View>
      {options.map((o, i) => {
        const active = getKey(o) === value;
        const last = i === options.length - 1;
        return (
          <View key={getKey(o)}>
            <TouchableOpacity
              onPress={() => onChange(getKey(o))}
              activeOpacity={0.6}
              style={{
                flexDirection: "row",
                alignItems: "center",
                justifyContent: "space-between",
                paddingHorizontal: SPACE.cardPad,
                paddingVertical: 13,
                minHeight: 48,
              }}
            >
              <Text style={[TYPE.row, { color: c.ink }]}>{getLabel(o)}</Text>
              <View
                style={[
                  { width: 8, height: 8, borderRadius: 4 },
                  active ? { backgroundColor: c.accent } : { borderWidth: 1, borderColor: c.dotOff },
                ]}
              />
            </TouchableOpacity>
            {!last ? <Divider /> : null}
          </View>
        );
      })}
    </View>
  );
}

export function Action({ label, onPress, destructive = false }) {
  const c = useC();
  return (
    <TouchableOpacity onPress={onPress} activeOpacity={0.6} style={{ paddingVertical: 16 }}>
      <Text
        style={[
          TYPE.label,
          { color: destructive ? c.alert : c.accent, fontWeight: "600", letterSpacing: 1.6 },
        ]}
      >
        {label}
      </Text>
    </TouchableOpacity>
  );
}

const TABS = [
  { key: "home", label: "Garage", icon: "home-outline", iconOn: "home" },
  { key: "log", label: "Log", icon: "document-text-outline", iconOn: "document-text" },
  { key: "setup", label: "Setup", icon: "settings-outline", iconOn: "settings" },
];

export function TabBar({ tab, onChange }) {
  const c = useC();
  const insets = useSafeAreaInsets();
  return (
    <View
      style={{
        flexDirection: "row",
        backgroundColor: c.surface,
        paddingTop: 10,
        paddingBottom: Math.max(insets.bottom, 10),
      }}
    >
      {TABS.map((t) => {
        const active = tab === t.key;
        const color = active ? c.accent : c.muted;
        return (
          <TouchableOpacity
            key={t.key}
            onPress={() => onChange(t.key)}
            activeOpacity={0.7}
            style={{ flex: 1, alignItems: "center", gap: 4 }}
          >
            <Ionicons name={active ? t.iconOn : t.icon} size={22} color={color} />
            <Text style={[TYPE.tab, { color }]}>{t.label}</Text>
          </TouchableOpacity>
        );
      })}
    </View>
  );
}
