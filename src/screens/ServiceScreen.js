import React, { useMemo, useState } from "react";
import { View, Text, ScrollView, TextInput } from "react-native";
import { Card, Label, Field, OptionList, Action, CheckRow, useC } from "../components/ui";
import { TYPE, SPACE } from "../theme";
import { uid, getServicePackages, emptyFieldValues } from "../data/templates";
import TopBar from "../components/TopBar";
import { PhotoStrip } from "../components/Photos";

function todayISO() {
  return new Date().toISOString().slice(0, 10);
}

export default function ServiceScreen({ vehicle, packageId, onBack, onSave }) {
  const c = useC();
  const pack = useMemo(
    () => getServicePackages(vehicle).find((p) => p.id === packageId),
    [vehicle, packageId]
  );

  const [date, setDate] = useState(todayISO());
  const [odo, setOdo] = useState(String(vehicle.odometer));
  const [note, setNote] = useState("");
  const [done, setDone] = useState({});
  const [values, setValues] = useState({});
  const [photos, setPhotos] = useState([]);

  if (!pack) {
    return (
      <View style={{ flex: 1, backgroundColor: c.bg }}>
        <TopBar title="Service" onBack={onBack} />
      </View>
    );
  }

  const toggle = (cat) => {
    const turningOn = !done[cat.id];
    setDone((d) => ({ ...d, [cat.id]: turningOn }));
    setValues((v) => {
      if (!turningOn) {
        const next = { ...v };
        delete next[cat.id];
        return next;
      }
      return { ...v, [cat.id]: emptyFieldValues(cat, true) };
    });
  };

  const setField = (catId, label, val) => {
    setValues((v) => ({ ...v, [catId]: { ...(v[catId] || {}), [label]: val } }));
  };

  const checked = pack.categories.filter((cat) => done[cat.id]);

  return (
    <View style={{ flex: 1, backgroundColor: c.bg }}>
      <TopBar title={pack.name} onBack={onBack} />
      <ScrollView
        contentContainerStyle={{ paddingHorizontal: SPACE.side, paddingTop: 12, paddingBottom: 40 }}
        keyboardShouldPersistTaps="handled"
      >
        <Card>
          <Field label="Date" value={date} onChangeText={setDate} placeholder="YYYY-MM-DD" />
          <Field label="Odometer" value={odo} onChangeText={setOdo} unit="km" keyboardType="numeric" last />
        </Card>

        <View style={{ marginTop: SPACE.block }}>
          <Label style={{ marginBottom: 10 }}>Checklist</Label>
          <Card>
            {pack.categories.map((cat, i) => {
              const on = !!done[cat.id];
              const isLast = i === pack.categories.length - 1;
              const inline = cat.fields.filter((f) => f.type !== "select");
              const selects = cat.fields.filter((f) => f.type === "select");
              const showFields = on && cat.fields.length > 0;
              const catValues = values[cat.id] || {};

              return (
                <View key={cat.id}>
                  <CheckRow label={cat.name} checked={on} onToggle={() => toggle(cat)} last={showFields || isLast} />
                  {showFields &&
                    inline.map((f, fi) =>
                      f.type === "checkbox" ? (
                        <CheckRow
                          key={f.id}
                          label={f.label}
                          checked={!!catValues[f.label]}
                          onToggle={() => setField(cat.id, f.label, !catValues[f.label])}
                          last={isLast && fi === inline.length - 1 && selects.length === 0}
                        />
                      ) : (
                        <Field
                          key={f.id}
                          label={f.label}
                          unit={f.unit}
                          value={catValues[f.label] || ""}
                          onChangeText={(val) => setField(cat.id, f.label, val)}
                          keyboardType={f.type === "number" ? "numeric" : "default"}
                          placeholder={f.unit ? "e.g. 0.6" : ""}
                          last={isLast && fi === inline.length - 1 && selects.length === 0}
                        />
                      )
                    )}
                  {showFields &&
                    selects.map((f, si) => (
                      <View key={f.id}>
                        <Text style={[TYPE.meta, { color: c.muted, paddingHorizontal: SPACE.cardPad, paddingTop: 10 }]}>
                          {f.label}
                        </Text>
                        <OptionList
                          options={f.options}
                          value={catValues[f.label] || ""}
                          onChange={(val) => setField(cat.id, f.label, val)}
                        />
                        {!(isLast && si === selects.length - 1) ? (
                          <View
                            style={{
                              height: 1,
                              backgroundColor: c.hairline,
                              marginHorizontal: SPACE.cardPad,
                            }}
                          />
                        ) : null}
                      </View>
                    ))}
                </View>
              );
            })}
          </Card>
        </View>

        <View style={{ marginTop: SPACE.block }}>
          <Label style={{ marginBottom: 10 }}>Note</Label>
          <Card>
            <TextInput
              value={note}
              onChangeText={setNote}
              placeholder="Optional — applies to every item"
              placeholderTextColor={c.faint}
              multiline
              style={[
                TYPE.body,
                {
                  color: c.ink,
                  paddingHorizontal: SPACE.cardPad,
                  paddingVertical: SPACE.fieldY,
                  minHeight: 64,
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
          label={checked.length ? `Save · ${checked.length}` : "Tick items first"}
          onPress={() => {
            if (!checked.length) return;
            const odometer = Number(odo) || 0;
            onSave(
              checked.map((cat) => ({
                id: uid(),
                categoryId: cat.id,
                categoryName: cat.name,
                date,
                odometer,
                values: values[cat.id] || {},
                note,
                service: pack.name,
                photos,
              }))
            );
          }}
        />
      </ScrollView>
    </View>
  );
}
