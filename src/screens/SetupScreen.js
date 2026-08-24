import React, { useState } from "react";
import { View, Text, ScrollView, Alert } from "react-native";
import { ScreenHeader, Card, CardRow, SectionHeader, TypeIcon, useC } from "../components/ui";
import { TYPE, SPACE } from "../theme";
import { TYPE_META } from "../data/templates";
import { formatOdo } from "../format";
import { exportJson, exportCsv, exportPdf } from "../data/export";
import {
  builtinConfigs,
  duplicateConfig,
  exportConfig,
  importConfigFile,
} from "../data/config";

export default function SetupScreen({
  vehicles,
  configs,
  onConfigsChange,
  onManage,
  onAddVehicle,
  onCreateFromConfig,
}) {
  const c = useC();
  const [busy, setBusy] = useState(null);
  const [openId, setOpenId] = useState(null);
  const [pdfPick, setPdfPick] = useState(false);

  const saved = configs || [];
  const all = [...builtinConfigs(), ...saved];
  const open = all.find((cfg) => cfg.id === openId);

  const runExport = async (kind, fn) => {
    if (busy) return;
    if (!vehicles.length) {
      Alert.alert("Export", "Add a vehicle first.");
      return;
    }
    setBusy(kind);
    try {
      await fn(vehicles);
    } catch (e) {
      Alert.alert("Export failed", e?.message || String(e));
    } finally {
      setBusy(null);
    }
  };

  const duplicate = (cfg) => {
    const copy = duplicateConfig(cfg);
    onConfigsChange([...saved, copy]);
    setOpenId(copy.id);
  };

  const remove = (cfg) => {
    Alert.alert(`Remove "${cfg.name}"?`, "Vehicles already created from it stay as they are.", [
      { text: "Cancel", style: "cancel" },
      {
        text: "Remove",
        style: "destructive",
        onPress: () => {
          onConfigsChange(saved.filter((x) => x.id !== cfg.id));
          setOpenId(null);
        },
      },
    ]);
  };

  const importFile = async () => {
    try {
      const cfg = await importConfigFile();
      if (!cfg) return;
      onConfigsChange([...saved, cfg]);
      setOpenId(cfg.id);
    } catch (e) {
      Alert.alert("Import failed", e?.message || String(e));
    }
  };

  return (
    <View style={{ flex: 1, backgroundColor: c.bg }}>
      <ScreenHeader title="Setup" onRightPress={onAddVehicle} rightIcon="add" />
      <ScrollView contentContainerStyle={{ paddingHorizontal: SPACE.side, paddingTop: 12, paddingBottom: 40 }}>
        <SectionHeader>Vehicles</SectionHeader>
        {vehicles.length === 0 ? (
          <Text style={[TYPE.small, { color: c.muted, paddingVertical: SPACE.rowY }]}>
            No vehicles yet — tap + to add one.
          </Text>
        ) : (
          <Card>
            {vehicles.map((v, i) => (
              <CardRow
                key={v.id}
                onPress={() => onManage(v.id)}
                chevron
                dot="hidden"
                left={
                  <View style={{ flexDirection: "row", alignItems: "center", gap: 12 }}>
                    <TypeIcon type={v.type} size={32} photo={v.photos?.[0]} />
                    <View>
                      <Text style={[TYPE.title, { color: c.ink }]}>{v.name}</Text>
                      <Text style={[TYPE.small, { color: c.muted, marginTop: 2 }]}>
                        {v.model ? `${v.model}  ·  ` : ""}
                        {TYPE_META[v.type]?.label || v.type}  ·  {formatOdo(v.odometer)} km
                      </Text>
                    </View>
                  </View>
                }
                divider={i < vehicles.length - 1}
              />
            ))}
          </Card>
        )}

        <View style={{ marginTop: SPACE.block }}>
          <SectionHeader>Configs</SectionHeader>
          {open ? (
            <Card>
              <CardRow
                onPress={() => setOpenId(null)}
                dot="hidden"
                left={open.name}
                right="Close"
              />
              <CardRow
                left="Type"
                right={TYPE_META[open.type]?.label || open.type}
                dot="hidden"
              />
              <CardRow
                left="Categories"
                right={String(open.categories.length)}
                dot="hidden"
                divider={open.categories.length > 0}
              />
              {open.categories.map((cat, i) => (
                <CardRow
                  key={`${cat.name}-${i}`}
                  left={cat.name}
                  right={
                    cat.intervalKm
                      ? `${cat.intervalKm} km`
                      : cat.intervalMonths
                        ? `${cat.intervalMonths} mo`
                        : ""
                  }
                  dot="hidden"
                  divider={i < open.categories.length - 1}
                />
              ))}
            </Card>
          ) : null}
          {open ? (
            <Card style={{ marginTop: 12 }}>
              <CardRow
                onPress={() => onCreateFromConfig(open)}
                chevron
                dot="hidden"
                left="Create vehicle"
              />
              <CardRow
                onPress={() => duplicate(open)}
                chevron
                dot="hidden"
                left="Duplicate"
              />
              <CardRow
                onPress={() => exportConfig(open).catch((e) => Alert.alert("Export failed", e?.message || String(e)))}
                chevron
                dot="hidden"
                left="Export"
                divider={!open.builtin}
              />
              {!open.builtin ? (
                <CardRow onPress={() => remove(open)} dot="hidden" left="Delete" divider={false} />
              ) : null}
            </Card>
          ) : (
            <Card>
              {all.map((cfg, i) => (
                <CardRow
                  key={cfg.id}
                  onPress={() => setOpenId(cfg.id)}
                  chevron
                  dot="hidden"
                  left={
                    <View>
                      <Text style={[TYPE.row, { color: c.ink }]}>{cfg.name}</Text>
                      <Text style={[TYPE.small, { color: c.muted, marginTop: 2 }]}>
                        {TYPE_META[cfg.type]?.label || cfg.type}  ·  {cfg.categories.length} categories
                        {cfg.builtin ? "  ·  default" : ""}
                      </Text>
                    </View>
                  }
                  divider={i < all.length - 1}
                />
              ))}
            </Card>
          )}
          {!open ? (
            <Card style={{ marginTop: 12 }}>
              <CardRow onPress={importFile} chevron dot="hidden" left="Import file" divider={false} />
            </Card>
          ) : null}
        </View>

        <View style={{ marginTop: SPACE.block }}>
          <SectionHeader>Export data</SectionHeader>
          <Card>
            <CardRow
              onPress={() => runExport("json", exportJson)}
              chevron
              dot="hidden"
              left="JSON backup"
              right={busy === "json" ? "…" : "Full data"}
            />
            <CardRow
              onPress={() => runExport("csv", exportCsv)}
              chevron
              dot="hidden"
              left="CSV log"
              right={busy === "csv" ? "…" : "Spreadsheet"}
            />
            <CardRow
              onPress={() => setPdfPick((open) => !open)}
              chevron
              dot="hidden"
              left="PDF report"
              right={pdfPick ? "Close" : "Choose"}
              divider={false}
            />
          </Card>
          {pdfPick ? (
            <Card style={{ marginTop: 12 }}>
              <CardRow
                onPress={() => runExport("pdf-all", exportPdf)}
                chevron
                dot="hidden"
                left="All vehicles"
                right={busy === "pdf-all" ? "…" : undefined}
                divider={vehicles.length > 0}
              />
              {vehicles.map((v, i) => (
                <CardRow
                  key={v.id}
                  onPress={() => runExport(`pdf-${v.id}`, () => exportPdf([v]))}
                  chevron
                  dot="hidden"
                  left={v.name}
                  right={busy === `pdf-${v.id}` ? "…" : undefined}
                  divider={i < vehicles.length - 1}
                />
              ))}
            </Card>
          ) : null}
          <Text style={[TYPE.small, { color: c.muted, marginTop: 10, lineHeight: 18 }]}>
            Configs are the checklist setup only. Data export includes logs and odometer.
          </Text>
        </View>

        <View style={{ marginTop: SPACE.block }}>
          <SectionHeader>About</SectionHeader>
          <Card>
            <CardRow left="GreaseTrail" right="1.0" divider={false} dot="hidden" />
          </Card>
        </View>
      </ScrollView>
    </View>
  );
}
