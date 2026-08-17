import React, { useState } from "react";
import { View, Text, ScrollView, Alert, TouchableOpacity } from "react-native";
import { C, TYPE, SPACE } from "../theme";
import { Card, Field, Action } from "../components/ui";
import { field, uid } from "../data/templates";
import TopBar from "../components/TopBar";

export default function ManageCategoriesScreen({ vehicle, onBack, onUpdateVehicle }) {
  const [categories, setCategories] = useState(vehicle.categories);
  const [newCatName, setNewCatName] = useState("");
  const [addingFieldFor, setAddingFieldFor] = useState(null);
  const [newFieldLabel, setNewFieldLabel] = useState("");
  const [newFieldUnit, setNewFieldUnit] = useState("");

  const commit = (next) => {
    setCategories(next);
    onUpdateVehicle({ ...vehicle, categories: next });
  };

  const removeField = (catId, fieldId) => {
    commit(categories.map((c) => (c.id === catId ? { ...c, fields: c.fields.filter((f) => f.id !== fieldId) } : c)));
  };

  const confirmRemoveCategory = (catId, name) => {
    Alert.alert(`Remove "${name}"?`, "Logged history for this category will be hidden.", [
      { text: "Cancel", style: "cancel" },
      { text: "Remove", style: "destructive", onPress: () => commit(categories.filter((c) => c.id !== catId)) },
    ]);
  };

  const confirmAddField = (catId) => {
    if (!newFieldLabel.trim()) return;
    const unit = newFieldUnit.trim() || null;
    commit(
      categories.map((c) =>
        c.id === catId
          ? { ...c, fields: [...c.fields, field(newFieldLabel.trim(), unit, unit ? "number" : "text")] }
          : c
      )
    );
    setAddingFieldFor(null);
    setNewFieldLabel("");
    setNewFieldUnit("");
  };

  const updateInterval = (catId, key, val) => {
    commit(categories.map((c) => (c.id === catId ? { ...c, [key]: val === "" ? null : Number(val) } : c)));
  };

  const addCategory = () => {
    if (!newCatName.trim()) return;
    commit([...categories, { id: uid(), name: newCatName.trim(), fields: [], intervalKm: null, intervalMonths: null }]);
    setNewCatName("");
  };

  return (
    <View style={{ flex: 1 }}>
      <View style={{ paddingHorizontal: SPACE.side }}>
        <TopBar title="Categories" onBack={onBack} />
      </View>
      <ScrollView
        contentContainerStyle={{ paddingHorizontal: SPACE.side, paddingBottom: 32, gap: 22 }}
        keyboardShouldPersistTaps="handled"
      >
        {categories.map((c) => (
          <View key={c.id}>
            <View style={{ flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: 6 }}>
              <Text style={[TYPE.name, { color: C.ink, fontSize: 13 }]}>{c.name}</Text>
              <TouchableOpacity onPress={() => confirmRemoveCategory(c.id, c.name)} hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}>
                <Text style={[TYPE.small, { color: C.accent }]}>Remove</Text>
              </TouchableOpacity>
            </View>

            <Card>
              {c.fields.map((f) => (
                <View
                  key={f.id}
                  style={{
                    flexDirection: "row",
                    alignItems: "center",
                    justifyContent: "space-between",
                    paddingHorizontal: 16,
                    paddingVertical: 12,
                    borderBottomWidth: SPACE.hairline,
                    borderBottomColor: C.hairline,
                  }}
                >
                  <Text style={[TYPE.body, { color: C.ink }]}>
                    {f.label}
                    {f.unit ? <Text style={{ color: C.muted }}>  {f.unit}</Text> : null}
                  </Text>
                  <TouchableOpacity onPress={() => removeField(c.id, f.id)} hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}>
                    <Text style={[TYPE.small, { color: C.muted }]}>Remove</Text>
                  </TouchableOpacity>
                </View>
              ))}

              {addingFieldFor === c.id ? (
                <View style={{ paddingHorizontal: 16, paddingBottom: 12 }}>
                  <Field label="Field" value={newFieldLabel} onChangeText={setNewFieldLabel} placeholder="Torque" />
                  <Field label="Unit" value={newFieldUnit} onChangeText={setNewFieldUnit} placeholder="mm" />
                  <View style={{ flexDirection: "row", gap: 16, paddingTop: 12 }}>
                    <TouchableOpacity onPress={() => confirmAddField(c.id)}>
                      <Text style={[TYPE.body, { color: C.ink, fontWeight: "500" }]}>Add</Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                      onPress={() => {
                        setAddingFieldFor(null);
                        setNewFieldLabel("");
                        setNewFieldUnit("");
                      }}
                    >
                      <Text style={[TYPE.body, { color: C.muted }]}>Cancel</Text>
                    </TouchableOpacity>
                  </View>
                </View>
              ) : (
                <TouchableOpacity
                  onPress={() => setAddingFieldFor(c.id)}
                  style={{ paddingHorizontal: 16, paddingVertical: 12 }}
                >
                  <Text style={[TYPE.small, { color: C.muted }]}>Add field</Text>
                </TouchableOpacity>
              )}
            </Card>

            <Field
              label="Every km"
              value={c.intervalKm != null ? String(c.intervalKm) : ""}
              onChangeText={(v) => updateInterval(c.id, "intervalKm", v)}
              placeholder="off"
              keyboardType="numeric"
            />
            <Field
              label="Every months"
              value={c.intervalMonths != null ? String(c.intervalMonths) : ""}
              onChangeText={(v) => updateInterval(c.id, "intervalMonths", v)}
              placeholder="off"
              keyboardType="numeric"
            />
          </View>
        ))}

        <View>
          <Field
            label="New category"
            value={newCatName}
            onChangeText={setNewCatName}
            placeholder="Fork oil"
          />
          <View style={{ marginTop: 16 }}>
            <Action label="Add category" onPress={addCategory} />
          </View>
        </View>
      </ScrollView>
    </View>
  );
}
