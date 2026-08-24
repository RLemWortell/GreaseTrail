import React, { useState } from "react";
import { View, Text, ScrollView, TextInput, Alert } from "react-native";
import { Card, CardRow, SectionHeader, Label, useC } from "../components/ui";
import { TYPE, SPACE } from "../theme";
import { TYPE_META, getStatus, attentionLabel, getServicePackages } from "../data/templates";
import { formatDate, formatOdo, formatLogLine } from "../format";
import { exportPdf } from "../data/export";
import TopBar from "../components/TopBar";
import { PhotoStrip, PhotoThumbs } from "../components/Photos";

export default function VehicleScreen({
  vehicle,
  onBack,
  onOpenCategory,
  onManage,
  onUpdateOdo,
  onOpenService,
  onAddService,
  onUpdate,
}) {
  const c = useC();
  const [odoInput, setOdoInput] = useState(String(vehicle.odometer));
  const [busy, setBusy] = useState(false);
  const allLogs = [...vehicle.logs].sort((a, b) => new Date(b.date) - new Date(a.date));
  const typeLabel = TYPE_META[vehicle.type]?.label || vehicle.type;
  const subtitle = vehicle.model ? `${vehicle.model}  ·  ${typeLabel}` : typeLabel;
  const packages = getServicePackages(vehicle);

  return (
    <View style={{ flex: 1, backgroundColor: c.bg }}>
      <TopBar title={vehicle.name} subtitle={subtitle} onBack={onBack} rightLabel="Edit" onRightPress={onManage} />
      <ScrollView
        contentContainerStyle={{ paddingHorizontal: SPACE.side, paddingTop: 12, paddingBottom: 40 }}
        keyboardShouldPersistTaps="handled"
      >
        <Card style={{ paddingHorizontal: SPACE.cardPad, paddingTop: 14, paddingBottom: 16 }}>
          <Text style={[TYPE.label, { color: c.muted, marginBottom: 4 }]}>Odometer</Text>
          <View style={{ flexDirection: "row", alignItems: "baseline", gap: 8 }}>
            <TextInputOdometer
              value={odoInput}
              onChangeText={setOdoInput}
              onBlur={() => onUpdateOdo(Number(odoInput) || 0)}
              color={c.ink}
            />
            <Text style={[TYPE.body, { color: c.muted }]}>km</Text>
          </View>
        </Card>

        <View style={{ marginTop: SPACE.block }}>
          <Label style={{ marginBottom: 10 }}>Photos</Label>
          <Card style={{ padding: SPACE.cardPad }}>
            <PhotoStrip
              uris={vehicle.photos || []}
              editable
              onChange={(photos) => onUpdate({ photos })}
            />
          </Card>
        </View>

        <View style={{ marginTop: SPACE.block }}>
          <SectionHeader>Service</SectionHeader>
          <Card>
            {packages.map((pack) => (
              <CardRow
                key={pack.id}
                onPress={() => onOpenService(pack.id)}
                chevron
                dot="hidden"
                left={pack.name}
                right={`${pack.categories.length} items`}
                divider
              />
            ))}
            <CardRow
              onPress={onAddService}
              dot="hidden"
              left={<Text style={[TYPE.meta, { color: c.ink }]}>+ Add service</Text>}
              divider={false}
            />
          </Card>
        </View>

        <View style={{ marginTop: SPACE.block }}>
          <SectionHeader>Categories</SectionHeader>
          <Card>
            {vehicle.categories.map((cat, i) => {
              const status = getStatus(vehicle, cat);
              const right = status ? attentionLabel(vehicle, cat) : null;
              return (
                <CardRow
                  key={cat.id}
                  onPress={() => onOpenCategory(cat.id)}
                  dot={status ? status.level : "hidden"}
                  left={
                    <View>
                      <Text style={[TYPE.row, { color: c.ink }]}>{cat.name}</Text>
                      <Text style={[TYPE.small, { color: c.muted, marginTop: 2 }]}>
                        {status?.last
                          ? `Last  ·  ${formatDate(status.last.date)}  ·  ${formatOdo(status.last.odometer)} km`
                          : "No entries yet"}
                      </Text>
                    </View>
                  }
                  right={right}
                  chevron
                  divider={i < vehicle.categories.length - 1}
                />
              );
            })}
          </Card>
        </View>

        <View style={{ marginTop: SPACE.block }}>
          <SectionHeader>History</SectionHeader>
          {allLogs.length === 0 ? (
            <Text style={[TYPE.small, { color: c.muted, paddingVertical: SPACE.rowY }]}>
              Nothing logged yet — tap a category to add the first entry.
            </Text>
          ) : (
            <Card>
              {allLogs.map((l, i) => (
                <CardRow
                  key={l.id}
                  dot="hidden"
                  left={
                    <View>
                      <Text style={[TYPE.row, { color: c.ink }]}>{l.categoryName}</Text>
                      <Text style={[TYPE.small, { color: c.muted, marginTop: 2 }]}>
                        {l.service ? `${l.service}  ·  ` : ""}
                        {formatOdo(l.odometer)} km
                        {formatLogLine(vehicle, l) ? `  ·  ${formatLogLine(vehicle, l)}` : ""}
                        {l.note ? `  ·  ${l.note}` : ""}
                      </Text>
                      <PhotoThumbs uris={l.photos} />
                    </View>
                  }
                  right={formatDate(l.date)}
                  divider={i < allLogs.length - 1}
                />
              ))}
            </Card>
          )}
        </View>

        <View style={{ marginTop: SPACE.block }}>
          <SectionHeader>Export</SectionHeader>
          <Card>
            <CardRow
              onPress={async () => {
                if (busy) return;
                setBusy(true);
                try {
                  await exportPdf([vehicle]);
                } catch (e) {
                  Alert.alert("Export failed", e?.message || String(e));
                } finally {
                  setBusy(false);
                }
              }}
              chevron
              dot="hidden"
              left="PDF report"
              right={busy ? "…" : undefined}
              divider={false}
            />
          </Card>
        </View>
      </ScrollView>
    </View>
  );
}

function TextInputOdometer({ value, onChangeText, onBlur, color }) {
  return (
    <TextInput
      value={value}
      onChangeText={onChangeText}
      onBlur={onBlur}
      keyboardType="numeric"
      style={[TYPE.odometer, { color, padding: 0, minWidth: 120 }]}
    />
  );
}
