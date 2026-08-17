import React, { useState } from "react";
import { View, Text, ScrollView, Alert, TouchableOpacity } from "react-native";
import { Feather } from "@expo/vector-icons";
import { T } from "../theme";
import { Panel, TextInput, FieldLabel, PrimaryButton } from "../components/ui";
import { field, uid } from "../data/templates";
import TopBar from "../components/TopBar";

export default function ManageCategoriesScreen({ vehicle, onBack, onUpdateVehicle }) {
  const [categories, setCategories] = useState(vehicle.categories);
  const [newCatName, setNewCatName] = useState("");
  // which category currently has its "add field" mini-form open
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
    Alert.alert(`Remove "${name}"?`, "This also removes its logged history from view.", [
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
    <View>
      <TopBar title="Manage categories" onBack={onBack} />
      <ScrollView contentContainerStyle={{ padding: 16, gap: 12 }} keyboardShouldPersistTaps="handled">
        {categories.map((c) => (
          <Panel key={c.id} style={{ padding: 14 }}>
            <View style={{ flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: 10 }}>
              <Text style={{ color: T.textPrimary, fontWeight: "600", fontSize: 14.5 }}>{c.name}</Text>
              <TouchableOpacity onPress={() => confirmRemoveCategory(c.id, c.name)} hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}>
                <Feather name="trash-2" size={16} color={T.red} />
              </TouchableOpacity>
            </View>

            <View style={{ gap: 6, marginBottom: 10 }}>
              {c.fields.map((f) => (
                <View
                  key={f.id}
                  style={{
                    flexDirection: "row",
                    alignItems: "center",
                    justifyContent: "space-between",
                    backgroundColor: T.bgSurfaceRaised,
                    borderWidth: 1,
                    borderColor: T.hairline,
                    borderRadius: 8,
                    paddingVertical: 8,
                    paddingHorizontal: 10,
                  }}
                >
                  <Text style={{ color: T.textPrimary, fontSize: 13 }}>
                    {f.label} {f.unit ? <Text style={{ color: T.textSecondary }}>({f.unit})</Text> : null}
                  </Text>
                  <TouchableOpacity onPress={() => removeField(c.id, f.id)} hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}>
                    <Feather name="x" size={14} color={T.textSecondary} />
                  </TouchableOpacity>
                </View>
              ))}
              {c.fields.length === 0 && <Text style={{ color: T.textSecondary, fontSize: 12 }}>No measurement fields.</Text>}
            </View>

            {addingFieldFor === c.id ? (
              <View style={{ gap: 8, marginBottom: 12 }}>
                <TextInput value={newFieldLabel} onChangeText={setNewFieldLabel} placeholder="Field name, e.g. Torque" />
                <TextInput value={newFieldUnit} onChangeText={setNewFieldUnit} placeholder="Unit (optional), e.g. mm" />
                <View style={{ flexDirection: "row", gap: 8 }}>
                  <PrimaryButton label="Add" onPress={() => confirmAddField(c.id)} style={{ flex: 1 }} />
                  <PrimaryButton
                    label="Cancel"
                    onPress={() => {
                      setAddingFieldFor(null);
                      setNewFieldLabel("");
                      setNewFieldUnit("");
                    }}
                    style={{ flex: 1, backgroundColor: T.bgSurfaceRaised, borderWidth: 1, borderColor: T.hairline }}
                    textStyle={{ color: T.textSecondary }}
                  />
                </View>
              </View>
            ) : (
              <TouchableOpacity
                onPress={() => setAddingFieldFor(c.id)}
                style={{ flexDirection: "row", alignItems: "center", gap: 4, marginBottom: 12 }}
              >
                <Feather name="plus" size={13} color={T.accent} />
                <Text style={{ color: T.accent, fontSize: 12.5 }}>Add field</Text>
              </TouchableOpacity>
            )}

            <View style={{ flexDirection: "row", gap: 10 }}>
              <View style={{ flex: 1 }}>
                <FieldLabel>Remind every (km)</FieldLabel>
                <TextInput
                  value={c.intervalKm != null ? String(c.intervalKm) : ""}
                  onChangeText={(v) => updateInterval(c.id, "intervalKm", v)}
                  placeholder="off"
                  keyboardType="numeric"
                />
              </View>
              <View style={{ flex: 1 }}>
                <FieldLabel>Remind every (months)</FieldLabel>
                <TextInput
                  value={c.intervalMonths != null ? String(c.intervalMonths) : ""}
                  onChangeText={(v) => updateInterval(c.id, "intervalMonths", v)}
                  placeholder="off"
                  keyboardType="numeric"
                />
              </View>
            </View>
          </Panel>
        ))}

        <Panel style={{ padding: 14 }}>
          <FieldLabel>Add your own category</FieldLabel>
          <View style={{ flexDirection: "row", gap: 8 }}>
            <TextInput
              value={newCatName}
              onChangeText={setNewCatName}
              placeholder="e.g. Fork oil, Timing belt..."
              style={{ flex: 1 }}
            />
            <PrimaryButton label="" icon="plus" onPress={addCategory} style={{ paddingHorizontal: 16 }} />
          </View>
        </Panel>
      </ScrollView>
    </View>
  );
}
