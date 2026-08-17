import React, { useState } from "react";
import { View, Text, ScrollView, StyleSheet } from "react-native";
import { T } from "../theme";
import { Panel, TextInput, FieldLabel, Badge, SectionLabel } from "../components/ui";
import { IconButton } from "../components/ui";
import { getStatus, STATUS_LABEL } from "../data/templates";
import TopBar from "../components/TopBar";

const STATUS_COLOR = { overdue: T.red, soon: T.amber, ok: T.green };
const STATUS_SOFT = { overdue: T.redSoft, soon: T.amberSoft, ok: T.greenSoft };
const STATUS_ICON = { overdue: "alert-triangle", soon: "clock", ok: "check" };

export default function VehicleScreen({ vehicle, onBack, onOpenCategory, onManage, onUpdateOdo }) {
  const [odoInput, setOdoInput] = useState(String(vehicle.odometer));
  const allLogs = [...vehicle.logs].sort((a, b) => new Date(b.date) - new Date(a.date));

  return (
    <View>
      <TopBar
        title={vehicle.name}
        onBack={onBack}
        right={<IconButton icon="settings" onPress={onManage} />}
      />
      <ScrollView contentContainerStyle={{ padding: 16 }} keyboardShouldPersistTaps="handled">
        <Panel style={{ padding: 14, marginBottom: 16 }}>
          <FieldLabel>Current reading (km)</FieldLabel>
          <TextInput
            value={odoInput}
            onChangeText={setOdoInput}
            keyboardType="numeric"
            onBlur={() => onUpdateOdo(Number(odoInput) || 0)}
          />
        </Panel>

        <SectionLabel>Maintenance categories</SectionLabel>
        <View style={{ gap: 10, marginBottom: 22 }}>
          {vehicle.categories.map((c) => {
            const status = getStatus(vehicle, c);
            return (
              <Panel key={c.id} onPress={() => onOpenCategory(c.id)} style={styles.categoryRow}>
                <View style={{ flex: 1 }}>
                  <Text style={styles.categoryName}>{c.name}</Text>
                  <Text style={styles.categoryMeta}>
                    {status?.last
                      ? `Last: ${status.last.date} · ${status.last.odometer.toLocaleString()} km`
                      : "No entries yet"}
                  </Text>
                </View>
                {status && (
                  <Badge
                    color={STATUS_COLOR[status.level]}
                    softColor={STATUS_SOFT[status.level]}
                    icon={STATUS_ICON[status.level]}
                    text={STATUS_LABEL[status.level]}
                  />
                )}
              </Panel>
            );
          })}
        </View>

        <SectionLabel>Log history</SectionLabel>
        <View style={{ gap: 8 }}>
          {allLogs.length === 0 && (
            <Text style={{ color: T.textSecondary, fontSize: 13, paddingVertical: 8 }}>
              Nothing logged yet — tap a category above to add the first entry.
            </Text>
          )}
          {allLogs.map((l) => (
            <Panel key={l.id} style={{ padding: 12 }}>
              <View style={{ flexDirection: "row", justifyContent: "space-between" }}>
                <Text style={styles.logTitle}>{l.categoryName}</Text>
                <Text style={styles.logDate}>{l.date}</Text>
              </View>
              <Text style={styles.logMeta}>
                {l.odometer.toLocaleString()} km
                {Object.entries(l.values)
                  .filter(([, v]) => v)
                  .map(([k, v]) => ` · ${k}: ${v}`)
                  .join("")}
              </Text>
              {!!l.note && <Text style={styles.logNote}>{l.note}</Text>}
            </Panel>
          ))}
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  categoryRow: {
    flexDirection: "row",
    alignItems: "center",
    padding: 14,
    gap: 10,
  },
  categoryName: {
    color: T.textPrimary,
    fontWeight: "600",
    fontSize: 14.5,
  },
  categoryMeta: {
    color: T.textSecondary,
    fontSize: 12,
    marginTop: 2,
  },
  logTitle: {
    color: T.textPrimary,
    fontWeight: "600",
    fontSize: 13.5,
  },
  logDate: {
    color: T.textSecondary,
    fontSize: 12,
  },
  logMeta: {
    color: T.textSecondary,
    fontSize: 12,
    marginTop: 4,
  },
  logNote: {
    color: T.textSecondary,
    fontSize: 12,
    marginTop: 4,
    fontStyle: "italic",
  },
});
