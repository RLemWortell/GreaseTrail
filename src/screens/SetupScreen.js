import React from "react";
import { View, Text, ScrollView, TouchableOpacity } from "react-native";
import { Feather } from "@expo/vector-icons";
import { C, TYPE, SPACE } from "../theme";
import { Card, Action } from "../components/ui";
import { TYPE_META, formatHeaderDate } from "../data/templates";

export default function SetupScreen({ vehicles, onAddVehicle, onManageVehicle }) {
  return (
    <View style={{ flex: 1 }}>
      <View style={{ paddingHorizontal: SPACE.side, paddingTop: 6, paddingBottom: 8 }}>
        <Text style={[TYPE.date, { color: C.muted }]}>{formatHeaderDate()}</Text>
        <Text style={[TYPE.title, { color: C.ink, marginTop: 10 }]}>SETUP</Text>
      </View>
      <ScrollView
        style={{ flex: 1 }}
        contentContainerStyle={{ paddingHorizontal: SPACE.side, paddingTop: 18, paddingBottom: 28 }}
        showsVerticalScrollIndicator={false}
      >
        <View style={{ flexDirection: "row", alignItems: "center", gap: 12, marginBottom: 14 }}>
          <Text style={[TYPE.label, { color: C.muted }]}>Vehicles</Text>
          <View style={{ flex: 1, height: SPACE.hairline, backgroundColor: C.ink, opacity: 0.85 }} />
        </View>

        {vehicles.length === 0 ? (
          <Text style={{ color: C.muted, fontSize: 14, marginBottom: 20 }}>No vehicles yet.</Text>
        ) : (
          <Card style={{ marginBottom: 24 }}>
            {vehicles.map((v, i) => (
              <TouchableOpacity
                key={v.id}
                onPress={() => onManageVehicle(v.id)}
                activeOpacity={0.7}
                style={{
                  flexDirection: "row",
                  alignItems: "center",
                  gap: 12,
                  paddingHorizontal: 16,
                  paddingVertical: SPACE.rowY,
                  borderBottomWidth: i < vehicles.length - 1 ? SPACE.hairline : 0,
                  borderBottomColor: C.hairline,
                  minHeight: 56,
                }}
              >
                <View style={{ flex: 1 }}>
                  <Text style={[TYPE.row, { color: C.ink }]}>{v.name}</Text>
                  <Text style={[TYPE.small, { color: C.muted, marginTop: 2 }]}>
                    {TYPE_META[v.type]?.label || v.type}
                    {v.model ? `  ·  ${v.model}` : ""}
                  </Text>
                </View>
                <Feather name="chevron-right" size={18} color={C.muted} />
              </TouchableOpacity>
            ))}
          </Card>
        )}

        <Action label="Add vehicle" onPress={onAddVehicle} />
      </ScrollView>
    </View>
  );
}
