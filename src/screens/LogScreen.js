import React, { useMemo } from "react";
import { View, Text, ScrollView } from "react-native";
import { ScreenHeader, Card, CardRow, useC } from "../components/ui";
import { TYPE, SPACE } from "../theme";
import { formatDate, formatOdo, formatLogLine } from "../format";
import { PhotoThumbs } from "../components/Photos";

export default function LogScreen({ vehicles, onOpenVehicle }) {
  const c = useC();

  const entries = useMemo(
    () =>
      vehicles
        .flatMap((v) =>
          v.logs.map((l) => ({
            ...l,
            vehicle: v,
            vehicleId: v.id,
            vehicleName: v.name,
          }))
        )
        .sort((a, b) => new Date(b.date) - new Date(a.date)),
    [vehicles]
  );

  return (
    <View style={{ flex: 1, backgroundColor: c.bg }}>
      <ScreenHeader title="Log" />
      <ScrollView contentContainerStyle={{ paddingHorizontal: SPACE.side, paddingTop: 12, paddingBottom: 40 }}>
        {entries.length === 0 ? (
          <Text style={[TYPE.small, { color: c.muted, paddingVertical: SPACE.rowY }]}>
            Nothing logged yet — open a vehicle and tap a category to add the first entry.
          </Text>
        ) : (
          <Card>
            {entries.map((l, i) => (
              <CardRow
                key={l.id}
                onPress={() => onOpenVehicle(l.vehicleId)}
                dot="hidden"
                left={
                  <View>
                    <Text style={[TYPE.row, { color: c.ink }]}>{l.categoryName}</Text>
                    <Text style={[TYPE.small, { color: c.muted, marginTop: 2 }]}>
                      {l.service ? `${l.service}  ·  ` : ""}
                      {l.vehicleName}  ·  {formatOdo(l.odometer)} km
                      {formatLogLine(l.vehicle, l) ? `  ·  ${formatLogLine(l.vehicle, l)}` : ""}
                      {l.note ? `  ·  ${l.note}` : ""}
                    </Text>
                    <PhotoThumbs uris={l.photos} />
                  </View>
                }
                right={formatDate(l.date)}
                divider={i < entries.length - 1}
              />
            ))}
          </Card>
        )}
      </ScrollView>
    </View>
  );
}
