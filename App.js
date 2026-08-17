import React, { useState, useEffect, useRef } from "react";
import { View, StyleSheet } from "react-native";
import { SafeAreaProvider, SafeAreaView } from "react-native-safe-area-context";
import { StatusBar } from "expo-status-bar";
import { T } from "./src/theme";
import { loadVehicles, saveVehicles } from "./src/data/storage";
import { seedDemoData } from "./src/data/templates";

import HomeScreen from "./src/screens/HomeScreen";
import AddVehicleScreen from "./src/screens/AddVehicleScreen";
import VehicleScreen from "./src/screens/VehicleScreen";
import AddLogScreen from "./src/screens/AddLogScreen";
import ManageCategoriesScreen from "./src/screens/ManageCategoriesScreen";

export default function App() {
  const [vehicles, setVehicles] = useState([]);
  const [ready, setReady] = useState(false);
  const [screen, setScreen] = useState({ name: "home" });
  const hasLoaded = useRef(false);

  // Load persisted vehicles on first mount; fall back to demo data.
  useEffect(() => {
    (async () => {
      const stored = await loadVehicles();
      setVehicles(stored && stored.length ? stored : seedDemoData());
      hasLoaded.current = true;
      setReady(true);
    })();
  }, []);

  // Persist on every change, once initial load has completed.
  useEffect(() => {
    if (!hasLoaded.current) return;
    saveVehicles(vehicles);
  }, [vehicles]);

  const vehicle = vehicles.find((v) => v.id === screen.vehicleId);
  const category = vehicle?.categories.find((c) => c.id === screen.categoryId);

  const updateVehicle = (updated) => {
    setVehicles((vs) => vs.map((v) => (v.id === updated.id ? updated : v)));
  };

  const addLog = (log) => {
    updateVehicle({
      ...vehicle,
      odometer: Math.max(vehicle.odometer, log.odometer),
      logs: [...vehicle.logs, log],
    });
    setScreen({ name: "vehicle", vehicleId: vehicle.id });
  };

  if (!ready) {
    return (
      <SafeAreaProvider>
        <SafeAreaView style={styles.root} edges={["top", "bottom"]}>
          <StatusBar style="light" />
        </SafeAreaView>
      </SafeAreaProvider>
    );
  }

  return (
    <SafeAreaProvider>
      <SafeAreaView style={styles.root} edges={["top", "bottom"]}>
        <StatusBar style="light" />

        {screen.name === "home" && (
          <HomeScreen
            vehicles={vehicles}
            onOpenVehicle={(id) => setScreen({ name: "vehicle", vehicleId: id })}
            onAddVehicle={() => setScreen({ name: "addVehicle" })}
          />
        )}

        {screen.name === "addVehicle" && (
          <AddVehicleScreen
            onBack={() => setScreen({ name: "home" })}
            onSave={(v) => {
              setVehicles((vs) => [...vs, v]);
              setScreen({ name: "vehicle", vehicleId: v.id });
            }}
          />
        )}

        {screen.name === "vehicle" && vehicle && (
          <VehicleScreen
            vehicle={vehicle}
            onBack={() => setScreen({ name: "home" })}
            onOpenCategory={(catId) => setScreen({ name: "addLog", vehicleId: vehicle.id, categoryId: catId })}
            onManage={() => setScreen({ name: "manage", vehicleId: vehicle.id })}
            onUpdateOdo={(val) => updateVehicle({ ...vehicle, odometer: val })}
          />
        )}

        {screen.name === "addLog" && vehicle && category && (
          <AddLogScreen
            vehicle={vehicle}
            category={category}
            onBack={() => setScreen({ name: "vehicle", vehicleId: vehicle.id })}
            onSave={addLog}
          />
        )}

        {screen.name === "manage" && vehicle && (
          <ManageCategoriesScreen
            vehicle={vehicle}
            onBack={() => setScreen({ name: "vehicle", vehicleId: vehicle.id })}
            onUpdateVehicle={updateVehicle}
          />
        )}
      </SafeAreaView>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: T.bgBase,
  },
});
