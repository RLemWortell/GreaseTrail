import React, { useState } from "react";
import { View, ScrollView } from "react-native";
import { SPACE } from "../theme";
import { Field, OptionList, Action } from "../components/ui";
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
    <View style={{ flex: 1 }}>
      <View style={{ paddingHorizontal: SPACE.side }}>
        <TopBar title={category.name} onBack={onBack} />
      </View>
      <ScrollView
        contentContainerStyle={{ paddingHorizontal: SPACE.side, paddingBottom: 32 }}
        keyboardShouldPersistTaps="handled"
      >
        <Field label="Date" value={date} onChangeText={setDate} placeholder="2026-08-17" />
        <Field label="Odometer" value={odo} onChangeText={setOdo} unit="km" keyboardType="numeric" />

        {category.fields.map((f) =>
          f.type === "select" ? (
            <View key={f.id} style={{ marginTop: 8 }}>
              <OptionList
                options={f.options}
                value={values[f.label]}
                onChange={(v) => setValues((s) => ({ ...s, [f.label]: v }))}
              />
            </View>
          ) : (
            <Field
              key={f.id}
              label={f.label}
              value={values[f.label]}
              onChangeText={(v) => setValues((s) => ({ ...s, [f.label]: v }))}
              unit={f.unit || undefined}
              keyboardType={f.type === "number" ? "numeric" : "default"}
              placeholder={f.unit ? "0" : ""}
            />
          )
        )}

        <Field label="Note" value={note} onChangeText={setNote} placeholder="Optional" />

        <View style={{ marginTop: 28 }}>
          <Action
            label="Save entry"
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
        </View>
      </ScrollView>
    </View>
  );
}
