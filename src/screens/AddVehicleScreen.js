import React, { useState } from "react";
import { View, Text, ScrollView } from "react-native";
import { Card, Label, Field, OptionList, Action, useC } from "../components/ui";
import { TYPE, SPACE } from "../theme";
import { TYPE_META, seedVehicle } from "../data/templates";
import { vehicleFromConfig } from "../data/config";
import TopBar from "../components/TopBar";
import { PhotoStrip } from "../components/Photos";

export default function AddVehicleScreen({ onBack, onSave, configs = [], initialConfigId, initialType }) {
  const c = useC();
  const [type, setType] = useState(initialType || "motorcycle");
  const [configId, setConfigId] = useState(
    initialConfigId && initialConfigId !== "default" ? initialConfigId : "default"
  );
  const [name, setName] = useState("");
  const [model, setModel] = useState("");
  const [odo, setOdo] = useState("");
  const [photos, setPhotos] = useState([]);

  const typeOptions = Object.entries(TYPE_META).map(([key, meta]) => ({ key, label: meta.label }));
  const configOptions = [
    { id: "default", name: "Default for type" },
    ...configs.filter((cfg) => cfg.type === type && !cfg.builtin),
  ];

  const selectType = (next) => {
    setType(next);
    const stillValid = configId === "default" || configs.some((cfg) => cfg.id === configId && cfg.type === next);
    if (!stillValid) setConfigId("default");
  };

  return (
    <View style={{ flex: 1, backgroundColor: c.bg }}>
      <TopBar title="Add vehicle" onBack={onBack} />
      <ScrollView
        contentContainerStyle={{ paddingHorizontal: SPACE.side, paddingTop: 12, paddingBottom: 40 }}
        keyboardShouldPersistTaps="handled"
      >
        <Label style={{ marginBottom: 10 }}>Type</Label>
        <Card>
          <OptionList options={typeOptions} value={type} onChange={selectType} getKey={(o) => o.key} getLabel={(o) => o.label} />
        </Card>

        {configOptions.length > 1 ? (
          <View style={{ marginTop: SPACE.block }}>
            <Label style={{ marginBottom: 10 }}>Config</Label>
            <Card>
              <OptionList
                options={configOptions}
                value={configId}
                onChange={setConfigId}
                getKey={(o) => o.id}
                getLabel={(o) => o.name}
              />
            </Card>
          </View>
        ) : null}

        <View style={{ height: SPACE.block }} />
        <Card>
          <Field label="Name" value={name} onChangeText={setName} placeholder="e.g. Suzuki V-Strom" />
          <Field label="Model" value={model} onChangeText={setModel} placeholder="e.g. DL650" />
          <Field label="Odometer" value={odo} onChangeText={setOdo} placeholder="0" unit="km" keyboardType="numeric" last />
        </Card>

        <View style={{ marginTop: SPACE.block }}>
          <Label style={{ marginBottom: 10 }}>Photos</Label>
          <Card style={{ padding: SPACE.cardPad }}>
            <PhotoStrip uris={photos} editable onChange={setPhotos} />
          </Card>
        </View>

        <Text style={[TYPE.small, { color: c.muted, lineHeight: 20, marginTop: 16 }]}>
          Standard categories come from the selected config. You can change them later.
        </Text>

        <Action
          label="Create vehicle"
          onPress={() => {
            if (!name.trim()) return;
            const cfg = configId !== "default" ? configs.find((x) => x.id === configId) : null;
            const v = cfg
              ? vehicleFromConfig(cfg, name.trim(), model.trim(), Number(odo) || 0)
              : seedVehicle(type, name.trim(), model.trim(), Number(odo) || 0);
            v.photos = photos;
            onSave(v);
          }}
        />
      </ScrollView>
    </View>
  );
}
