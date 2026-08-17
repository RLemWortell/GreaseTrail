import React, { useState } from "react";
import { View, Text, ScrollView } from "react-native";
import { T } from "../theme";
import { Panel, TextInput, FieldLabel, ChipRow, PrimaryButton } from "../components/ui";
import { TYPE_META, seedVehicle } from "../data/templates";
import TopBar from "../components/TopBar";

export default function AddVehicleScreen({ onBack, onSave }) {
  const [type, setType] = useState("motorcycle");
  const [name, setName] = useState("");
  const [model, setModel] = useState("");
  const [odo, setOdo] = useState("");

  const typeOptions = Object.entries(TYPE_META).map(([key, meta]) => ({ key, label: meta.label }));

  return (
    <View>
      <TopBar title="Add vehicle" onBack={onBack} />
      <ScrollView contentContainerStyle={{ padding: 16 }} keyboardShouldPersistTaps="handled">
        <Panel style={{ padding: 14, gap: 14 }}>
          <View>
            <FieldLabel>Type</FieldLabel>
            <ChipRow
              options={typeOptions}
              value={type}
              onChange={setType}
              getKey={(o) => o.key}
              getLabel={(o) => o.label}
            />
          </View>

          <View>
            <FieldLabel>Name</FieldLabel>
            <TextInput value={name} onChangeText={setName} placeholder="e.g. Suzuki V-Strom" />
          </View>

          <View>
            <FieldLabel>Model / details (optional)</FieldLabel>
            <TextInput value={model} onChangeText={setModel} placeholder="e.g. DL650, 2019" />
          </View>

          <View>
            <FieldLabel>Current odometer (km)</FieldLabel>
            <TextInput value={odo} onChangeText={setOdo} placeholder="0" keyboardType="numeric" />
          </View>

          <Text style={{ color: T.textSecondary, fontSize: 12, lineHeight: 17 }}>
            Standard categories for this vehicle type will be added automatically — you can edit, remove or add
            your own afterwards from the vehicle's settings.
          </Text>

          <PrimaryButton
            label="Create vehicle"
            icon="check"
            onPress={() => {
              if (!name.trim()) return;
              onSave(seedVehicle(type, name.trim(), model.trim(), Number(odo) || 0));
            }}
          />
        </Panel>
      </ScrollView>
    </View>
  );
}
