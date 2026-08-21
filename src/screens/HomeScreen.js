import React, { useState, useMemo } from "react";
import { View, Text, ScrollView, TouchableOpacity } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { ScreenHeader, SearchBar, Card, CardRow, SectionHeader, TypeIcon, useC } from "../components/ui";
import { TYPE, SPACE } from "../theme";
import { TYPE_META, countAttention, getAttentionItems } from "../data/templates";
import { formatOdo } from "../format";

export default function HomeScreen({ vehicles, onOpenVehicle, onAddVehicle, onOpenCategory }) {
  const c = useC();
  const [query, setQuery] = useState("");

  const filtered = useMemo(() => {
    if (!query.trim()) return vehicles;
    const q = query.toLowerCase();
    return vehicles.filter(
      (v) => v.name.toLowerCase().includes(q) || (v.model || "").toLowerCase().includes(q)
    );
  }, [vehicles, query]);

  const attention = useMemo(
    () =>
      filtered.flatMap((v) =>
        getAttentionItems(v).map((item) => ({ ...item, vehicleId: v.id, vehicleName: v.name }))
      ),
    [filtered]
  );

  return (
    <View style={{ flex: 1, backgroundColor: c.bg }}>
      <ScreenHeader title="Garage" onRightPress={onAddVehicle} rightIcon="add" />
      <View style={{ paddingHorizontal: SPACE.side }}>
        <SearchBar value={query} onChangeText={setQuery} placeholder="Search vehicles" />
      </View>

      <ScrollView
        contentContainerStyle={{ paddingHorizontal: SPACE.side, paddingTop: 20, paddingBottom: 40 }}
        keyboardShouldPersistTaps="handled"
      >
        {filtered.map((v) => (
          <VehicleCard key={v.id} vehicle={v} onPress={() => onOpenVehicle(v.id)} />
        ))}

        {filtered.length === 0 && (
          <Text style={[TYPE.small, { color: c.muted, paddingVertical: SPACE.rowY }]}>
            {vehicles.length === 0 ? "No vehicles yet — tap + to add one." : "No matches."}
          </Text>
        )}

        {attention.length > 0 && (
          <View style={{ marginTop: SPACE.block }}>
            <SectionHeader>Needs attention</SectionHeader>
            <Card>
              {attention.map((item, i) => (
                <CardRow
                  key={`${item.vehicleId}-${item.id}`}
                  onPress={() => onOpenCategory(item.vehicleId, item.id)}
                  dot="overdue"
                  left={vehicles.length > 1 ? `${item.vehicleName} · ${item.name}` : item.name}
                  right={item.label}
                  divider={i < attention.length - 1}
                />
              ))}
            </Card>
          </View>
        )}
      </ScrollView>
    </View>
  );
}

function VehicleCard({ vehicle, onPress }) {
  const c = useC();
  const counts = countAttention(vehicle);
  const typeLabel = TYPE_META[vehicle.type]?.label || vehicle.type;

  return (
    <TouchableOpacity onPress={onPress} activeOpacity={0.7} style={{ marginBottom: 12 }}>
      <Card>
        <View
          style={{
            flexDirection: "row",
            alignItems: "center",
            gap: 12,
            paddingHorizontal: SPACE.cardPad,
            paddingTop: 16,
            paddingBottom: 14,
          }}
        >
          <TypeIcon type={vehicle.type} photo={vehicle.photos?.[0]} />
          <View style={{ flex: 1 }}>
            <Text style={[TYPE.title, { color: c.ink }]}>{vehicle.name}</Text>
            <Text style={[TYPE.label, { color: c.muted, marginTop: 2 }]}>
              {vehicle.model ? `${vehicle.model}  ·  ${typeLabel}` : typeLabel}
            </Text>
          </View>
          <Ionicons name="chevron-forward" size={16} color={c.faint} />
        </View>

        <View style={{ height: 1, backgroundColor: c.hairline, marginHorizontal: SPACE.cardPad }} />

        <View
          style={{
            flexDirection: "row",
            alignItems: "flex-end",
            justifyContent: "space-between",
            paddingHorizontal: SPACE.cardPad,
            paddingTop: 14,
            paddingBottom: 16,
          }}
        >
          <View>
            <Text style={[TYPE.label, { color: c.muted, marginBottom: 4 }]}>Odometer</Text>
            <View style={{ flexDirection: "row", alignItems: "baseline", gap: 6 }}>
              <Text style={[TYPE.odometer, { color: c.ink }]}>{formatOdo(vehicle.odometer)}</Text>
              <Text style={[TYPE.body, { color: c.muted }]}>km</Text>
            </View>
          </View>
          {(counts.overdue > 0 || counts.soon > 0) && (
            <View style={{ paddingBottom: 6, gap: 6, alignItems: "flex-end" }}>
              {counts.overdue > 0 && (
                <Text style={[TYPE.meta, { color: c.accent }]}>·  {counts.overdue} overdue</Text>
              )}
              {counts.soon > 0 && (
                <Text style={[TYPE.meta, { color: c.soon }]}>·  {counts.soon} due soon</Text>
              )}
            </View>
          )}
        </View>
      </Card>
    </TouchableOpacity>
  );
}
