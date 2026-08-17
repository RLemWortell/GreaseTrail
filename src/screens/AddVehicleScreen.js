import React, { useState } from "react";
import { View, ScrollView } from "react-native";
import { SPACE } from "../theme";
import { Field, OptionList, Action } from "../components/ui";
import { TYPE_META, seedVehicle } from "../data/templates";
import TopBar from "../components/TopBar";

export default function AddVehicleScreen({ onBack, onSave }) {
  const [type, setType] = useState("motorcycle");
  const [name, setName] = useState("");
  const [model, setModel] = useState("");
  const [odo, setOdo] = useState("");

  const typeOptions = Object.entries(TYPE_META).map(([key, meta]) => ({ key, label: meta.label }));

  return (
    <View style={{ flex: 1 }}>
      <View style={{ paddingHorizontal: SPACE.side }}>
        <TopBar title="Add vehicle" onBack={onBack} />
      </View>
      <ScrollView
        contentContainerStyle={{ paddingHorizontal: SPACE.side, paddingBottom: 32 }}
        keyboardShouldPersistTaps="handled"
      >
        <OptionList
          options={typeOptions}
          value={type}
          onChange={setType}
          getKey={(o) => o.key}
          getLabel={(o) => o.label}
        />
        <Field label="Name" value={name} onChangeText={setName} placeholder="Suzuki V-Strom" />
        <Field label="Model" value={model} onChangeText={setModel} placeholder="DL650" />
        <Field label="Odometer" value={odo} onChangeText={setOdo} placeholder="0" unit="km" keyboardType="numeric" />
        <View style={{ marginTop: 28 }}>
          <Action
            label="Create vehicle"
            onPress={() => {
              if (!name.trim()) return;
              onSave(seedVehicle(type, name.trim(), model.trim(), Number(odo) || 0));
            }}
          />
        </View>
      </ScrollView>
    </View>
  );
}
