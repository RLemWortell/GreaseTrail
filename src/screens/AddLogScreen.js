import React, { useState } from "react";
import { View, Text, ScrollView, TextInput } from "react-native";
import { Card, Label, Field, OptionList, Action, CheckRow, useC } from "../components/ui";
import { TYPE, SPACE } from "../theme";
import { uid } from "../data/templates";
import TopBar from "../components/TopBar";
import { PhotoStrip } from "../components/Photos";

function todayISO() {
  return new Date().toISOString().slice(0, 10);
}

export default function AddLogScreen({ vehicle, category, onBack, onSave }) {
  const c = useC();
  const [values, setValues] = useState(() =>
    Object.fromEntries(category.fields.map((f) => [f.label, f.type === "checkbox" ? false : ""]))
  );
  const [note, setNote] = useState("");
  const [date, setDate] = useState(todayISO());
  const [odo, setOdo] = useState(String(vehicle.odometer));
  const [photos, setPhotos] = useState([]);

  const inlineFields = category.fields.filter((f) => f.type !== "select");
  const selectFields = category.fields.filter((f) => f.type === "select");

  return (
    <View style={{ flex: 1, backgroundColor: c.bg }}>
      <TopBar title={category.name} onBack={onBack} />
      <ScrollView
        contentContainerStyle={{ paddingHorizontal: SPACE.side, paddingTop: 12, paddingBottom: 40 }}
        keyboardShouldPersistTaps="handled"
      >
        <Card>
          <Field label="Date" value={date} onChangeText={setDate} placeholder="YYYY-MM-DD" />
          <Field
            label="Odometer"
            value={odo}
            onChangeText={setOdo}
            unit="km"
            keyboardType="numeric"
            last={inlineFields.length === 0}
          />
          {inlineFields.map((f, i) =>
            f.type === "checkbox" ? (
              <CheckRow
                key={f.id}
                label={f.label}
                checked={!!values[f.label]}
                onToggle={() => setValues((s) => ({ ...s, [f.label]: !s[f.label] }))}
                last={i === inlineFields.length - 1}
              />
            ) : (
              <Field
                key={f.id}
                label={f.label}
                unit={f.unit}
                value={values[f.label]}
                onChangeText={(v) => setValues((s) => ({ ...s, [f.label]: v }))}
                keyboardType={f.type === "number" ? "numeric" : "default"}
                placeholder={f.unit ? "e.g. 0.6" : ""}
                last={i === inlineFields.length - 1}
              />
            )
          )}
        </Card>

        {category.fields.length === 0 && (
          <Text style={[TYPE.small, { color: c.muted, paddingVertical: SPACE.rowY }]}>
            This category has no measurement fields — logging the date and km is enough.
          </Text>
        )}

        {selectFields.map((f) => (
          <View key={f.id} style={{ marginTop: SPACE.block }}>
            <Label style={{ marginBottom: 10 }}>{f.label}</Label>
            <Card>
              <OptionList
                options={f.options}
                value={values[f.label]}
                onChange={(v) => setValues((s) => ({ ...s, [f.label]: v }))}
              />
            </Card>
          </View>
        ))}

        <View style={{ marginTop: SPACE.block }}>
          <Label style={{ marginBottom: 10 }}>Note</Label>
          <Card>
            <TextInput
              value={note}
              onChangeText={setNote}
              placeholder="Anything worth remembering"
              placeholderTextColor={c.faint}
              multiline
              style={[
                TYPE.body,
                {
                  color: c.ink,
                  paddingHorizontal: SPACE.cardPad,
                  paddingVertical: SPACE.fieldY,
                  minHeight: 72,
                  textAlignVertical: "top",
                },
              ]}
            />
          </Card>
        </View>

        <View style={{ marginTop: SPACE.block }}>
          <Label style={{ marginBottom: 10 }}>Photos</Label>
          <Card style={{ padding: SPACE.cardPad }}>
            <PhotoStrip uris={photos} editable onChange={setPhotos} />
          </Card>
        </View>

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
              photos,
            })
          }
        />
      </ScrollView>
    </View>
  );
}
