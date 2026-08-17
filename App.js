import React, { useState, useEffect, useRef } from "react";
import { StyleSheet } from "react-native";
import { SafeAreaProvider, SafeAreaView } from "react-native-safe-area-context";
import { StatusBar } from "expo-status-bar";
import { C } from "./src/theme";
import { loadVehicles, saveVehicles } from "./src/data/storage";
import { seedDemoData } from "./src/data/templates";
import { TabBar } from "./src/components/TopBar";

import HomeScreen from "./src/screens/HomeScreen";
import LogScreen from "./src/screens/LogScreen";
import SetupScreen from "./src/screens/SetupScreen";
import AddVehicleScreen from "./src/screens/AddVehicleScreen";
import VehicleScreen from "./src/screens/VehicleScreen";
import AddLogScreen from "./src/screens/AddLogScreen";
import ManageCategoriesScreen from "./src/screens/ManageCategoriesScreen";

export default function App() {
  const [vehicles, setVehicles] = useState([]);
  const [ready, setReady] = useState(false);
  const [tab, setTab] = useState("garage");
  const [screen, setScreen] = useState({ name: "tabs" });
  const hasLoaded = useRef(false);

  useEffect(() => {
    (async () => {
      const stored = await loadVehicles();
      setVehicles(stored && stored.length ? stored : seedDemoData());
      hasLoaded.current = true;
      setReady(true);
    })();
  }, []);

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

  const openVehicle = (id) => setScreen({ name: "vehicle", vehicleId: id });
  const addVehicle = () => setScreen({ name: "addVehicle" });

  if (!ready) {
    return (
      <SafeAreaProvider>
        <SafeAreaView style={styles.root} edges={["top", "bottom"]}>
          <StatusBar style="dark" />
        </SafeAreaView>
      </SafeAreaProvider>
    );
  }

  const showTabs = screen.name === "tabs";

  return (
    <SafeAreaProvider>
      <SafeAreaView style={styles.root} edges={["top", "bottom"]}>
        <StatusBar style="dark" />

        {showTabs && tab === "garage" && (
          <HomeScreen
            vehicles={vehicles}
            onOpenVehicle={openVehicle}
            onAddVehicle={addVehicle}
            onOpenCategory={(vehicleId, categoryId) =>
              setScreen({ name: "addLog", vehicleId, categoryId, back: "tabs" })
            }
          />
        )}

        {showTabs && tab === "log" && (
          <LogScreen vehicles={vehicles} onOpenVehicle={openVehicle} />
        )}

        {showTabs && tab === "setup" && (
          <SetupScreen
            vehicles={vehicles}
            onAddVehicle={addVehicle}
            onManageVehicle={(id) => setScreen({ name: "manage", vehicleId: id, back: "tabs" })}
          />
        )}

        {screen.name === "addVehicle" && (
          <AddVehicleScreen
            onBack={() => setScreen({ name: "tabs" })}
            onSave={(v) => {
              setVehicles((vs) => [...vs, v]);
              setScreen({ name: "vehicle", vehicleId: v.id });
            }}
          />
        )}

        {screen.name === "vehicle" && vehicle && (
          <VehicleScreen
            vehicle={vehicle}
            onBack={() => setScreen({ name: "tabs" })}
            onOpenCategory={(catId) =>
              setScreen({ name: "addLog", vehicleId: vehicle.id, categoryId: catId, back: "vehicle" })
            }
            onManage={() => setScreen({ name: "manage", vehicleId: vehicle.id, back: "vehicle" })}
            onUpdateOdo={(val) => updateVehicle({ ...vehicle, odometer: val })}
          />
        )}

        {screen.name === "addLog" && vehicle && category && (
          <AddLogScreen
            vehicle={vehicle}
            category={category}
            onBack={() =>
              setScreen(screen.back === "tabs" ? { name: "tabs" } : { name: "vehicle", vehicleId: vehicle.id })
            }
            onSave={addLog}
          />
        )}

        {screen.name === "manage" && vehicle && (
          <ManageCategoriesScreen
            vehicle={vehicle}
            onBack={() =>
              setScreen(screen.back === "tabs" ? { name: "tabs" } : { name: "vehicle", vehicleId: vehicle.id })
            }
            onUpdateVehicle={updateVehicle}
          />
        )}

        {showTabs && <TabBar tab={tab} onChange={setTab} />}
      </SafeAreaView>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: C.bg,
  },
});
