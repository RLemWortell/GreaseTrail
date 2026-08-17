import React, { useState, useMemo } from "react";
import { View, Text, ScrollView, StyleSheet, TouchableOpacity } from "react-native";
import { Feather, MaterialCommunityIcons } from "@expo/vector-icons";
import { C, TYPE, SPACE } from "../theme";
import { Card, SearchField, PlusButton, Dot } from "../components/ui";
import { TYPE_META, getStatus, getAttentionItems, formatKm, formatHeaderDate } from "../data/templates";

export default function HomeScreen({ vehicles, onOpenVehicle, onAddVehicle, onOpenCategory }) {
  const [query, setQuery] = useState("");

  const filtered = useMemo(() => {
    if (!query.trim()) return vehicles;
    const q = query.toLowerCase();
    return vehicles.filter(
      (v) => v.name.toLowerCase().includes(q) || (v.model || "").toLowerCase().includes(q)
    );
  }, [vehicles, query]);

  const attention = useMemo(() => filtered.flatMap(getAttentionItems), [filtered]);

  return (
    <View style={{ flex: 1 }}>
      <View style={styles.header}>
        <View style={styles.headerRow}>
          <Text style={[TYPE.date, { color: C.muted }]}>{formatHeaderDate()}</Text>
          <PlusButton onPress={onAddVehicle} />
        </View>
        <Text style={[TYPE.title, { color: C.ink, marginTop: 10 }]}>GARAGE</Text>
        <View style={{ marginTop: 18 }}>
          <SearchField value={query} onChangeText={setQuery} />
        </View>
      </View>

      <ScrollView
        style={{ flex: 1 }}
        contentContainerStyle={styles.scroll}
        keyboardShouldPersistTaps="handled"
        showsVerticalScrollIndicator={false}
      >
        <View style={{ gap: 12 }}>
          {filtered.map((v) => (
            <VehicleCard key={v.id} vehicle={v} onPress={() => onOpenVehicle(v.id)} />
          ))}
          {filtered.length === 0 && (
            <Text style={{ color: C.muted, fontSize: 14, paddingVertical: 8 }}>
              {vehicles.length === 0 ? "No vehicles yet." : "No matches."}
            </Text>
          )}
        </View>

        {attention.length > 0 && (
          <View style={{ marginTop: 32 }}>
            <View style={styles.sectionHead}>
              <Text style={[TYPE.label, { color: C.muted }]}>Needs attention</Text>
              <View style={styles.sectionRule} />
            </View>
            <Card style={{ marginTop: 14 }}>
              {attention.map((item, i) => (
                <TouchableOpacity
                  key={`${item.vehicleId}-${item.categoryId}`}
                  onPress={() => onOpenCategory(item.vehicleId, item.categoryId)}
                  activeOpacity={0.7}
                  style={[styles.attnRow, i < attention.length - 1 && styles.attnRowBorder]}
                >
                  <View style={styles.attnInner}>
                    <Dot level={item.level} />
                    <Text style={[TYPE.row, { color: C.ink, flex: 1 }]}>{item.name}</Text>
                    <Text style={[TYPE.small, { color: C.muted, letterSpacing: 0.6, textTransform: "uppercase" }]}>
                      {item.label}
                    </Text>
                  </View>
                </TouchableOpacity>
              ))}
            </Card>
          </View>
        )}
      </ScrollView>
    </View>
  );
}

function VehicleCard({ vehicle, onPress }) {
  const iconName = TYPE_META[vehicle.type]?.icon || "car";
  const typeLabel = TYPE_META[vehicle.type]?.label || vehicle.type;
  const statuses = vehicle.categories.map((c) => getStatus(vehicle, c)).filter(Boolean);
  const overdue = statuses.filter((s) => s.level === "overdue").length;
  const soon = statuses.filter((s) => s.level === "soon").length;

  return (
    <Card onPress={onPress}>
      <View style={styles.vehicleHead}>
        <View style={styles.vehicleIcon}>
          <MaterialCommunityIcons name={iconName} size={20} color={C.iconFg} />
        </View>
        <View style={{ flex: 1 }}>
          <Text style={[TYPE.name, { color: C.ink }]}>{vehicle.name}</Text>
          <Text style={[TYPE.meta, { color: C.muted, marginTop: 3, letterSpacing: 0.6 }]}>
            {vehicle.model ? `${vehicle.model}  ·  ` : ""}
            {typeLabel}
          </Text>
        </View>
        <Feather name="chevron-right" size={18} color={C.muted} />
      </View>

      <View style={styles.vehicleBody}>
        <View>
          <Text style={[TYPE.label, { color: C.muted, letterSpacing: 1.2 }]}>Odometer</Text>
          <Text style={[TYPE.odometer, { color: C.ink, marginTop: 4 }]}>{formatKm(vehicle.odometer)} km</Text>
        </View>
        <View style={{ alignItems: "flex-end", gap: 8, paddingTop: 6 }}>
          {overdue > 0 && (
            <View style={styles.statusLine}>
              <View style={[styles.statusDot, { backgroundColor: C.accent }]} />
              <Text style={[styles.statusText, { color: C.accent }]}>
                {overdue} overdue
              </Text>
            </View>
          )}
          {soon > 0 && (
            <View style={styles.statusLine}>
              <View style={[styles.statusDot, { backgroundColor: C.soon }]} />
              <Text style={[styles.statusText, { color: C.soon }]}>{soon} due soon</Text>
            </View>
          )}
        </View>
      </View>
    </Card>
  );
}

const styles = StyleSheet.create({
  header: {
    paddingHorizontal: SPACE.side,
    paddingTop: 6,
    paddingBottom: 8,
  },
  headerRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
  scroll: {
    paddingHorizontal: SPACE.side,
    paddingTop: 18,
    paddingBottom: 28,
  },
  vehicleHead: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    paddingHorizontal: 16,
    paddingVertical: 14,
    borderBottomWidth: SPACE.hairline,
    borderBottomColor: C.hairline,
  },
  vehicleIcon: {
    width: 40,
    height: 40,
    borderRadius: 10,
    backgroundColor: C.iconBg,
    alignItems: "center",
    justifyContent: "center",
  },
  vehicleBody: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-start",
    paddingHorizontal: 16,
    paddingVertical: 16,
  },
  statusLine: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
  },
  statusDot: {
    width: 7,
    height: 7,
    borderRadius: 3.5,
  },
  statusText: {
    fontSize: 11,
    fontWeight: "600",
    letterSpacing: 1.1,
    textTransform: "uppercase",
  },
  sectionHead: {
    gap: 8,
  },
  sectionRule: {
    height: SPACE.hairline,
    backgroundColor: C.ink,
    opacity: 0.85,
  },
  attnRow: {
    paddingHorizontal: 16,
  },
  attnRowBorder: {
    borderBottomWidth: SPACE.hairline,
    borderBottomColor: C.hairline,
  },
  attnInner: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    paddingVertical: SPACE.rowY,
    minHeight: 52,
  },
});
