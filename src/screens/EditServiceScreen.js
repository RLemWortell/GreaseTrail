import React, { useState } from "react";
import { View, Text, ScrollView, Alert } from "react-native";
import { Card, Label, Field, Action, CheckRow, useC } from "../components/ui";
import { TYPE, SPACE } from "../theme";
import { uid, getServiceRecords, upsertService, removeService } from "../data/templates";
import TopBar from "../components/TopBar";

export default function EditServiceScreen({ vehicle, serviceId, onBack, onUpdateVehicle }) {
  const c = useC();
  const existing = serviceId ? getServiceRecords(vehicle).find((s) => s.id === serviceId) : null;
  const [name, setName] = useState(existing?.name || "");
  const [selected, setSelected] = useState(() => new Set(existing?.categoryIds || []));

  const toggle = (id) => {
    setSelected((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  const save = () => {
    const trimmed = name.trim();
    if (!trimmed) return;
    const categoryIds = vehicle.categories.map((cat) => cat.id).filter((id) => selected.has(id));
    if (!categoryIds.length) return;
    onUpdateVehicle(
      upsertService(vehicle, {
        id: existing?.id || uid(),
        name: trimmed,
        categoryIds,
      })
    );
    onBack();
  };

  const remove = () => {
    Alert.alert(`Remove "${existing.name}"?`, "This only removes the checklist, not your log history.", [
      { text: "Cancel", style: "cancel" },
      {
        text: "Remove",
        style: "destructive",
        onPress: () => {
          onUpdateVehicle(removeService(vehicle, existing.id));
          onBack();
        },
      },
    ]);
  };

  return (
    <View style={{ flex: 1, backgroundColor: c.bg }}>
      <TopBar title={existing ? "Edit service" : "New service"} onBack={onBack} />
      <ScrollView
        contentContainerStyle={{ paddingHorizontal: SPACE.side, paddingTop: 12, paddingBottom: 40 }}
        keyboardShouldPersistTaps="handled"
      >
        <Card>
          <Field
            label="Name"
            value={name}
            onChangeText={setName}
            placeholder="e.g. Chain weekend"
            last
          />
        </Card>

        <View style={{ marginTop: SPACE.block }}>
          <Label style={{ marginBottom: 10 }}>Items</Label>
          {vehicle.categories.length === 0 ? (
            <Text style={[TYPE.small, { color: c.muted }]}>Add categories first, then pick them here.</Text>
          ) : (
            <Card>
              {vehicle.categories.map((cat, i) => (
                <CheckRow
                  key={cat.id}
                  label={cat.name}
                  checked={selected.has(cat.id)}
                  onToggle={() => toggle(cat.id)}
                  last={i === vehicle.categories.length - 1}
                />
              ))}
            </Card>
          )}
        </View>

        <Action label="Save service" onPress={save} />
        {existing ? <Action label="Remove service" onPress={remove} destructive /> : null}
      </ScrollView>
    </View>
  );
}
