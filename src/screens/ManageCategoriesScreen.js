import React, { useState } from "react";
import { View, Text, ScrollView, Alert, TouchableOpacity, TextInput } from "react-native";
import { Card, CardRow, Label, Field, OptionList, Action, useC } from "../components/ui";
import { TYPE, SPACE } from "../theme";
import { field, uid, FIELD_TYPES, getServicePackages } from "../data/templates";
import { configFromVehicle } from "../data/config";
import TopBar from "../components/TopBar";

function typeOptionsFor(type) {
  if (type === "select" && !FIELD_TYPES.some((t) => t.key === "select")) {
    return [...FIELD_TYPES, { key: "select", label: "Select" }];
  }
  return FIELD_TYPES;
}

export default function ManageCategoriesScreen({
  vehicle,
  onBack,
  onUpdateVehicle,
  onEditService,
  onAddService,
  onSaveConfig,
}) {
  const c = useC();
  const [categories, setCategories] = useState(vehicle.categories);
  const [newCatName, setNewCatName] = useState("");
  const [fieldForm, setFieldForm] = useState(null);

  const commit = (next, logs = vehicle.logs) => {
    setCategories(next);
    onUpdateVehicle({ ...vehicle, categories: next, logs });
  };

  const persistCatName = (catId, raw) => {
    const name = raw.trim();
    if (!name) {
      const previous = vehicle.categories.find((c) => c.id === catId)?.name;
      if (previous) {
        setCategories((cats) => cats.map((c) => (c.id === catId ? { ...c, name: previous } : c)));
      }
      return;
    }
    const next = categories.map((cat) => (cat.id === catId ? { ...cat, name } : cat));
    const logs = (vehicle.logs || []).map((l) => (l.categoryId === catId ? { ...l, categoryName: name } : l));
    commit(next, logs);
  };

  const removeField = (catId, fieldId) => {
    commit(categories.map((cat) => (cat.id === catId ? { ...cat, fields: cat.fields.filter((f) => f.id !== fieldId) } : cat)));
  };

  const confirmRemoveCategory = (catId, name) => {
    Alert.alert(`Remove "${name}"?`, "This also removes its logged history from view.", [
      { text: "Cancel", style: "cancel" },
      { text: "Remove", style: "destructive", onPress: () => commit(categories.filter((cat) => cat.id !== catId)) },
    ]);
  };

  const openAddField = (catId) => {
    setFieldForm({ catId, fieldId: null, label: "", unit: "", type: "number" });
  };

  const openEditField = (cat, f) => {
    setFieldForm({
      catId: cat.id,
      fieldId: f.id,
      label: f.label,
      unit: f.unit || "",
      type: f.type || "number",
    });
  };

  const resetFieldForm = () => setFieldForm(null);

  const saveFieldForm = () => {
    if (!fieldForm || !fieldForm.label.trim()) return;
    const label = fieldForm.label.trim();
    const type = fieldForm.type;
    const unit = type === "number" && fieldForm.unit.trim() ? fieldForm.unit.trim() : null;

    const cat = categories.find((c) => c.id === fieldForm.catId);
    if (!cat) return;

    let logs = vehicle.logs || [];

    if (fieldForm.fieldId) {
      const old = cat.fields.find((f) => f.id === fieldForm.fieldId);
      const nextFields = cat.fields.map((f) =>
        f.id === fieldForm.fieldId
          ? { ...f, label, unit, type, options: type === "select" ? f.options : null }
          : f
      );
      if (old && old.label !== label) {
        logs = logs.map((l) => {
          if (l.categoryId !== cat.id || !l.values || !(old.label in l.values)) return l;
          const values = { ...l.values, [label]: l.values[old.label] };
          delete values[old.label];
          return { ...l, values };
        });
      }
      commit(
        categories.map((c) => (c.id === cat.id ? { ...c, fields: nextFields } : c)),
        logs
      );
    } else {
      commit(
        categories.map((c) =>
          c.id === cat.id ? { ...c, fields: [...c.fields, field(label, unit, type)] } : c
        )
      );
    }
    resetFieldForm();
  };

  const updateInterval = (catId, key, val) => {
    commit(categories.map((cat) => (cat.id === catId ? { ...cat, [key]: val === "" ? null : Number(val) } : cat)));
  };

  const addCategory = () => {
    if (!newCatName.trim()) return;
    commit([...categories, { id: uid(), name: newCatName.trim(), fields: [], intervalKm: null, intervalMonths: null }]);
    setNewCatName("");
  };

  const renderFieldForm = (catId) => {
    if (!fieldForm || fieldForm.catId !== catId) return null;
    const editing = !!fieldForm.fieldId;
    return (
      <View>
        <Field
          label="Field name"
          value={fieldForm.label}
          onChangeText={(label) => setFieldForm((s) => ({ ...s, label }))}
          placeholder={fieldForm.type === "checkbox" ? "e.g. Front" : "e.g. Torque"}
        />
        <View style={{ paddingTop: 4, paddingBottom: 4 }}>
          <Text style={[TYPE.meta, { color: c.muted, paddingHorizontal: SPACE.cardPad, paddingTop: 8 }]}>Type</Text>
          <OptionList
            options={typeOptionsFor(fieldForm.type)}
            value={fieldForm.type}
            onChange={(type) => setFieldForm((s) => ({ ...s, type }))}
            getKey={(o) => o.key}
            getLabel={(o) => o.label}
          />
        </View>
        {fieldForm.type === "number" ? (
          <Field
            label="Unit"
            value={fieldForm.unit}
            onChangeText={(unit) => setFieldForm((s) => ({ ...s, unit }))}
            placeholder="optional, e.g. mm"
            last
          />
        ) : null}
        <View style={{ flexDirection: "row", gap: 24, paddingHorizontal: SPACE.cardPad, paddingVertical: 12 }}>
          <TouchableOpacity onPress={saveFieldForm}>
            <Text style={[TYPE.meta, { color: c.accent }]}>{editing ? "Save" : "Add"}</Text>
          </TouchableOpacity>
          <TouchableOpacity onPress={resetFieldForm}>
            <Text style={[TYPE.meta, { color: c.muted }]}>Cancel</Text>
          </TouchableOpacity>
        </View>
      </View>
    );
  };

  return (
    <View style={{ flex: 1, backgroundColor: c.bg }}>
      <TopBar title="Categories" onBack={onBack} />
      <ScrollView
        contentContainerStyle={{ paddingHorizontal: SPACE.side, paddingTop: 12, paddingBottom: 40 }}
        keyboardShouldPersistTaps="handled"
      >
        {categories.map((cat) => (
          <Card key={cat.id} style={{ marginBottom: 16 }}>
            <View
              style={{
                flexDirection: "row",
                alignItems: "center",
                gap: 12,
                paddingHorizontal: SPACE.cardPad,
                paddingTop: 10,
                paddingBottom: 6,
              }}
            >
              <TextInput
                value={cat.name}
                onChangeText={(name) =>
                  setCategories((cats) => cats.map((c) => (c.id === cat.id ? { ...c, name } : c)))
                }
                onEndEditing={(e) => persistCatName(cat.id, e.nativeEvent.text)}
                style={[TYPE.category, { flex: 1, color: c.ink, padding: 0 }]}
              />
              <TouchableOpacity
                onPress={() => confirmRemoveCategory(cat.id, cat.name)}
                hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
              >
                <Text style={[TYPE.meta, { color: c.accent }]}>Remove</Text>
              </TouchableOpacity>
            </View>

            {cat.fields.map((f) =>
              fieldForm?.fieldId === f.id ? (
                <View key={f.id}>{renderFieldForm(cat.id)}</View>
              ) : (
                <View key={f.id}>
                  <View
                    style={{
                      flexDirection: "row",
                      alignItems: "center",
                      justifyContent: "space-between",
                      paddingHorizontal: SPACE.cardPad,
                      paddingVertical: SPACE.rowY - 4,
                    }}
                  >
                    <TouchableOpacity onPress={() => openEditField(cat, f)} style={{ flex: 1 }} activeOpacity={0.6}>
                      <Text style={[TYPE.row, { color: c.ink }]}>
                        {f.label}
                        {f.unit ? <Text style={{ color: c.muted }}> ({f.unit})</Text> : null}
                        {f.type && f.type !== "number" ? (
                          <Text style={{ color: c.muted }}>  ·  {f.type}</Text>
                        ) : null}
                      </Text>
                    </TouchableOpacity>
                    <TouchableOpacity onPress={() => removeField(cat.id, f.id)} hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}>
                      <Text style={[TYPE.small, { color: c.muted }]}>×</Text>
                    </TouchableOpacity>
                  </View>
                  <View
                    style={{
                      height: 1,
                      backgroundColor: c.hairline,
                      marginHorizontal: SPACE.cardPad,
                    }}
                  />
                </View>
              )
            )}
            {cat.fields.length === 0 && !fieldForm?.fieldId && fieldForm?.catId !== cat.id && (
              <Text style={[TYPE.small, { color: c.faint, paddingHorizontal: SPACE.cardPad, paddingVertical: 8 }]}>
                No measurement fields.
              </Text>
            )}

            {fieldForm?.catId === cat.id && !fieldForm.fieldId ? (
              renderFieldForm(cat.id)
            ) : fieldForm?.fieldId && fieldForm.catId === cat.id ? null : (
              <TouchableOpacity
                onPress={() => openAddField(cat.id)}
                style={{ paddingHorizontal: SPACE.cardPad, paddingVertical: 12 }}
              >
                <Text style={[TYPE.meta, { color: c.ink }]}>+ Add field</Text>
              </TouchableOpacity>
            )}

            <View style={{ height: 1, backgroundColor: c.hairline, marginHorizontal: SPACE.cardPad }} />
            <Field
              label="Remind every"
              value={cat.intervalKm != null ? String(cat.intervalKm) : ""}
              onChangeText={(v) => updateInterval(cat.id, "intervalKm", v)}
              placeholder="off"
              unit="km"
              keyboardType="numeric"
            />
            <Field
              label="Remind every"
              value={cat.intervalMonths != null ? String(cat.intervalMonths) : ""}
              onChangeText={(v) => updateInterval(cat.id, "intervalMonths", v)}
              placeholder="off"
              unit="months"
              keyboardType="numeric"
              last
            />
          </Card>
        ))}

        <Label style={{ marginBottom: 10 }}>Add your own</Label>
        <Card>
          <Field label="Name" value={newCatName} onChangeText={setNewCatName} placeholder="e.g. Fork oil" last />
        </Card>
        <Action label="Add category" onPress={addCategory} />
        {onSaveConfig ? (
          <Action
            label="Save as config"
            onPress={() => {
              const cfg = configFromVehicle({ ...vehicle, categories });
              onSaveConfig(cfg);
              Alert.alert("Config saved", `"${cfg.name}" is in Setup → Configs.`);
            }}
          />
        ) : null}

        <View style={{ marginTop: SPACE.block }}>
          <Label style={{ marginBottom: 10 }}>Services</Label>
          <Card>
            {getServicePackages(vehicle).map((pack) => (
              <CardRow
                key={pack.id}
                onPress={() => onEditService(pack.id)}
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
      </ScrollView>
    </View>
  );
}
