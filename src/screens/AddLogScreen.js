import React, { useState } from "react";
import { View, Text, ScrollView } from "react-native";
import { T } from "../theme";
import { Panel, TextInput, FieldLabel, ChipRow, PrimaryButton } from "../components/ui";
import { uid } from "../data/templates";
import TopBar from "../components/TopBar";

function todayISO() {
  return new Date().toISOString().slice(0, 10);
}

export default function AddLogScreen({ vehicle, category, onBack, onSave }) {
  const [values, setValues] = useState(() => Object.fromEntries(category.fields.map((f) => [f.label, ""])));
  const [note, setNote] = useState("");
  const [date, setDate] = useState(todayISO());
  const [odo, setOdo] = useState(String(vehicle.odometer));

  return (
    <View>
      <TopBar title={category.name} onBack={onBack} />
      <ScrollView contentContainerStyle={{ padding: 16 }} keyboardShouldPersistTaps="handled">
        <Panel style={{ padding: 14, gap: 14 }}>
          <View style={{ flexDirection: "row", gap: 10 }}>
            <View style={{ flex: 1 }}>
              <FieldLabel>Date (YYYY-MM-DD)</FieldLabel>
              <TextInput value={date} onChangeText={setDate} placeholder="2026-08-16" />
            </View>
            <View style={{ flex: 1 }}>
              <FieldLabel>Odometer (km)</FieldLabel>
              <TextInput value={odo} onChangeText={setOdo} keyboardType="numeric" />
            </View>
          </View>

          {category.fields.length === 0 && (
            <Text style={{ color: T.textSecondary, fontSize: 13 }}>
              This category has no measurement fields — just logging the date/km is enough.
            </Text>
          )}

          {category.fields.map((f) => (
            <View key={f.id}>
              <FieldLabel>
                {f.label}
                {f.unit ? ` (${f.unit})` : ""}
              </FieldLabel>
              {f.type === "select" ? (
                <ChipRow
                  options={f.options}
                  value={values[f.label]}
                  onChange={(v) => setValues((s) => ({ ...s, [f.label]: v }))}
                />
              ) : (
                <TextInput
                  value={values[f.label]}
                  onChangeText={(v) => setValues((s) => ({ ...s, [f.label]: v }))}
                  keyboardType={f.type === "number" ? "numeric" : "default"}
                  placeholder={f.unit ? "e.g. 0.6" : ""}
                />
              )}
            </View>
          ))}

          <View>
            <FieldLabel>Note (optional)</FieldLabel>
            <TextInput
              value={note}
              onChangeText={setNote}
              placeholder="Anything worth remembering..."
              multiline
              style={{ minHeight: 70, textAlignVertical: "top" }}
            />
          </View>

          <PrimaryButton
            label="Save entry"
            icon="check"
            onPress={() =>
              onSave({
                id: uid(),
                categoryId: category.id,
                categoryName: category.name,
                date,
                odometer: Number(odo) || 0,
                values,
                note,
              })
            }
          />
        </Panel>
      </ScrollView>
    </View>
  );
}
