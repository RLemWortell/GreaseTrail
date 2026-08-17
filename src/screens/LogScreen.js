import React, { useMemo } from "react";
import { View, Text, ScrollView, TouchableOpacity } from "react-native";
import { C, TYPE, SPACE } from "../theme";
import { Card } from "../components/ui";
import { formatKm, formatHeaderDate } from "../data/templates";

export default function LogScreen({ vehicles, onOpenVehicle }) {
  const entries = useMemo(() => {
    const all = vehicles.flatMap((v) =>
      v.logs.map((l) => ({ ...l, vehicleId: v.id, vehicleName: v.name }))
    );
    return all.sort((a, b) => new Date(b.date) - new Date(a.date));
  }, [vehicles]);

  return (
    <View style={{ flex: 1 }}>
      <View style={{ paddingHorizontal: SPACE.side, paddingTop: 6, paddingBottom: 8 }}>
        <Text style={[TYPE.date, { color: C.muted }]}>{formatHeaderDate()}</Text>
        <Text style={[TYPE.title, { color: C.ink, marginTop: 10 }]}>LOG</Text>
      </View>
      <ScrollView
        style={{ flex: 1 }}
        contentContainerStyle={{ paddingHorizontal: SPACE.side, paddingTop: 18, paddingBottom: 28 }}
        showsVerticalScrollIndicator={false}
      >
        {entries.length === 0 ? (
          <Text style={{ color: C.muted, fontSize: 14 }}>Nothing logged yet.</Text>
        ) : (
          <Card>
            {entries.map((l, i) => (
              <TouchableOpacity
                key={l.id}
                onPress={() => onOpenVehicle(l.vehicleId)}
                activeOpacity={0.7}
                style={{
                  paddingHorizontal: 16,
                  paddingVertical: SPACE.rowY,
                  borderBottomWidth: i < entries.length - 1 ? SPACE.hairline : 0,
                  borderBottomColor: C.hairline,
                }}
              >
                <View style={{ flexDirection: "row", justifyContent: "space-between", gap: 12 }}>
                  <Text style={[TYPE.row, { color: C.ink, flex: 1 }]}>{l.categoryName}</Text>
                  <Text style={[TYPE.small, { color: C.muted }]}>{l.date}</Text>
                </View>
                <Text style={[TYPE.small, { color: C.muted, marginTop: 4 }]}>
                  {l.vehicleName}  ·  {formatKm(l.odometer)} km
                </Text>
              </TouchableOpacity>
            ))}
          </Card>
        )}
      </ScrollView>
    </View>
  );
}
