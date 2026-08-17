import React, { useState } from "react";
import { View, Text, ScrollView, TouchableOpacity } from "react-native";
import { C, TYPE, SPACE } from "../theme";
import { Card, Field, Dot, IconButton } from "../components/ui";
import TopBar from "../components/TopBar";
import { getStatus, getDueLabel, formatKm } from "../data/templates";

export default function VehicleScreen({ vehicle, onBack, onOpenCategory, onManage, onUpdateOdo }) {
  const [odoInput, setOdoInput] = useState(String(vehicle.odometer));
  const allLogs = [...vehicle.logs].sort((a, b) => new Date(b.date) - new Date(a.date));

  return (
    <View style={{ flex: 1 }}>
      <View style={{ paddingHorizontal: SPACE.side }}>
        <TopBar
          title={vehicle.name}
          onBack={onBack}
          right={<IconButton icon="settings" onPress={onManage} />}
        />
      </View>
      <ScrollView
        contentContainerStyle={{ paddingHorizontal: SPACE.side, paddingBottom: 32 }}
        keyboardShouldPersistTaps="handled"
        showsVerticalScrollIndicator={false}
      >
        <Text style={[TYPE.label, { color: C.muted, marginTop: 4 }]}>Odometer</Text>
        <Field
          label="Reading"
          value={odoInput}
          unit="km"
          keyboardType="numeric"
          onChangeText={setOdoInput}
          onBlur={() => onUpdateOdo(Number(odoInput) || 0)}
          emphasis
        />

        <View style={{ flexDirection: "row", alignItems: "center", gap: 12, marginTop: 32, marginBottom: 12 }}>
          <Text style={[TYPE.label, { color: C.muted }]}>Categories</Text>
          <View style={{ flex: 1, height: SPACE.hairline, backgroundColor: C.ink, opacity: 0.85 }} />
        </View>

        <Card>
          {vehicle.categories.map((c, i) => {
            const status = getStatus(vehicle, c);
            const level = status?.level || "none";
            return (
              <TouchableOpacity
                key={c.id}
                onPress={() => onOpenCategory(c.id)}
                activeOpacity={0.7}
                style={{
                  flexDirection: "row",
                  alignItems: "center",
                  gap: 12,
                  paddingHorizontal: 16,
                  paddingVertical: SPACE.rowY,
                  borderBottomWidth: i < vehicle.categories.length - 1 ? SPACE.hairline : 0,
                  borderBottomColor: C.hairline,
                  minHeight: 52,
                }}
              >
                <Dot level={level} />
                <Text style={[TYPE.row, { color: C.ink, flex: 1 }]}>{c.name}</Text>
                <Text style={[TYPE.small, { color: C.muted, letterSpacing: 0.6, textTransform: "uppercase" }]}>
                  {status ? getDueLabel(vehicle, c) : ""}
                </Text>
              </TouchableOpacity>
            );
          })}
        </Card>

        <View style={{ flexDirection: "row", alignItems: "center", gap: 12, marginTop: 32, marginBottom: 12 }}>
          <Text style={[TYPE.label, { color: C.muted }]}>History</Text>
          <View style={{ flex: 1, height: SPACE.hairline, backgroundColor: C.ink, opacity: 0.85 }} />
        </View>

        {allLogs.length === 0 ? (
          <Text style={{ color: C.muted, fontSize: 14 }}>Nothing logged yet.</Text>
        ) : (
          <Card>
            {allLogs.map((l, i) => (
              <View
                key={l.id}
                style={{
                  paddingHorizontal: 16,
                  paddingVertical: 14,
                  borderBottomWidth: i < allLogs.length - 1 ? SPACE.hairline : 0,
                  borderBottomColor: C.hairline,
                }}
              >
                <View style={{ flexDirection: "row", justifyContent: "space-between" }}>
                  <Text style={[TYPE.row, { color: C.ink }]}>{l.categoryName}</Text>
                  <Text style={[TYPE.small, { color: C.muted }]}>{l.date}</Text>
                </View>
                <Text style={[TYPE.small, { color: C.muted, marginTop: 4 }]}>
                  {formatKm(l.odometer)} km
                  {Object.entries(l.values)
                    .filter(([, v]) => v)
                    .map(([k, v]) => `  ·  ${k}: ${v}`)
                    .join("")}
                </Text>
              </View>
            ))}
          </Card>
        )}
      </ScrollView>
    </View>
  );
}
