import React, { useState, useMemo } from "react";
import { View, Text, ScrollView, StyleSheet } from "react-native";
import { Feather, MaterialCommunityIcons } from "@expo/vector-icons";
import { T } from "../theme";
import { Panel, TextInput, Badge, SectionLabel, PrimaryButton } from "../components/ui";
import { TYPE_META, getStatus } from "../data/templates";

export default function HomeScreen({ vehicles, onOpenVehicle, onAddVehicle }) {
  const [query, setQuery] = useState("");

  const filtered = useMemo(() => {
    if (!query.trim()) return vehicles;
    const q = query.toLowerCase();
    return vehicles.filter(
      (v) => v.name.toLowerCase().includes(q) || (v.model || "").toLowerCase().includes(q)
    );
  }, [vehicles, query]);

  return (
    <ScrollView contentContainerStyle={{ padding: 16 }} keyboardShouldPersistTaps="handled">
      <View style={styles.searchBar}>
        <Feather name="search" size={16} color={T.textSecondary} />
        <TextInput
          value={query}
          onChangeText={setQuery}
          placeholder="Search vehicles"
          style={styles.searchInput}
        />
      </View>

      <SectionLabel>Your garage</SectionLabel>

      <View style={{ gap: 10 }}>
        {filtered.map((v) => {
          const iconName = TYPE_META[v.type]?.icon || "car";
          const statuses = v.categories.map((c) => getStatus(v, c)).filter(Boolean);
          const overdue = statuses.filter((s) => s.level === "overdue").length;
          const soon = statuses.filter((s) => s.level === "soon").length;

          let badge;
          if (overdue > 0) badge = <Badge color={T.red} softColor={T.redSoft} icon="alert-triangle" text={`${overdue}`} />;
          else if (soon > 0) badge = <Badge color={T.amber} softColor={T.amberSoft} icon="clock" text={`${soon}`} />;
          else badge = <Badge color={T.green} softColor={T.greenSoft} icon="check" text="OK" />;

          return (
            <Panel key={v.id} onPress={() => onOpenVehicle(v.id)} style={styles.vehicleCard}>
              <View style={styles.vehicleIcon}>
                <MaterialCommunityIcons name={iconName} size={22} color={T.accent} />
              </View>
              <View style={{ flex: 1 }}>
                <Text style={styles.vehicleName}>{v.name}</Text>
                <Text style={styles.vehicleMeta}>
                  {v.model ? `${v.model} · ` : ""}
                  {v.odometer.toLocaleString()} km
                </Text>
              </View>
              {badge}
            </Panel>
          );
        })}

        {filtered.length === 0 && (
          <Text style={{ color: T.textSecondary, fontSize: 13, paddingVertical: 8 }}>
            {vehicles.length === 0 ? "No vehicles yet — add your first one below." : "No matches."}
          </Text>
        )}
      </View>

      <PrimaryButton
        label="Add vehicle"
        icon="plus"
        onPress={onAddVehicle}
        style={{ marginTop: 16, backgroundColor: T.bgSurface, borderWidth: 1, borderColor: T.hairline }}
        textStyle={{ color: T.textSecondary }}
      />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  searchBar: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    backgroundColor: T.bgSurface,
    borderWidth: 1,
    borderColor: T.hairline,
    borderRadius: 12,
    paddingHorizontal: 14,
    marginBottom: 18,
    minHeight: 46,
  },
  searchInput: {
    flex: 1,
    backgroundColor: "transparent",
    borderWidth: 0,
    minHeight: 0,
    paddingVertical: 10,
    paddingHorizontal: 0,
    fontSize: 15,
  },
  vehicleCard: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    padding: 14,
  },
  vehicleIcon: {
    width: 44,
    height: 44,
    borderRadius: 10,
    backgroundColor: T.accentSoft,
    alignItems: "center",
    justifyContent: "center",
  },
  vehicleName: {
    color: T.textPrimary,
    fontWeight: "600",
    fontSize: 15,
  },
  vehicleMeta: {
    color: T.textSecondary,
    fontSize: 12.5,
    marginTop: 2,
  },
});
