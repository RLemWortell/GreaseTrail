import React, { useState, useEffect, useRef } from "react";
import { View, StyleSheet, useColorScheme } from "react-native";
import { SafeAreaProvider, SafeAreaView } from "react-native-safe-area-context";
import { StatusBar } from "expo-status-bar";
import { LIGHT, DARK } from "./src/theme";
import { loadVehicles, saveVehicles, loadConfigs, saveConfigs } from "./src/data/storage";
import { seedDemoData } from "./src/data/templates";
import { TabBar } from "./src/components/ui";

import HomeScreen from "./src/screens/HomeScreen";
import LogScreen from "./src/screens/LogScreen";
import SetupScreen from "./src/screens/SetupScreen";
import AddVehicleScreen from "./src/screens/AddVehicleScreen";
import VehicleScreen from "./src/screens/VehicleScreen";
import AddLogScreen from "./src/screens/AddLogScreen";
import ManageCategoriesScreen from "./src/screens/ManageCategoriesScreen";
import ServiceScreen from "./src/screens/ServiceScreen";
import EditServiceScreen from "./src/screens/EditServiceScreen";

const TABS = new Set(["home", "log", "setup"]);

export default function App() {
  const scheme = useColorScheme();
  const c = scheme === "dark" ? DARK : LIGHT;
  const [vehicles, setVehicles] = useState([]);
  const [configs, setConfigs] = useState([]);
  const [ready, setReady] = useState(false);
  const [screen, setScreen] = useState({ name: "home" });
  const hasLoaded = useRef(false);

  useEffect(() => {
    (async () => {
      const stored = await loadVehicles();
      setVehicles(stored && stored.length ? stored : seedDemoData());
      setConfigs(await loadConfigs());
      hasLoaded.current = true;
      setReady(true);
    })();
  }, []);

  useEffect(() => {
    if (!hasLoaded.current) return;
    saveVehicles(vehicles);
  }, [vehicles]);

  useEffect(() => {
    if (!hasLoaded.current) return;
    saveConfigs(configs);
  }, [configs]);

  const vehicle = vehicles.find((v) => v.id === screen.vehicleId);
  const category = vehicle?.categories.find((cat) => cat.id === screen.categoryId);
  const onTab = TABS.has(screen.name);

  const updateVehicle = (updated) => {
    setVehicles((vs) => vs.map((v) => (v.id === updated.id ? updated : v)));
  };

  const addLogs = (logs) => {
    const maxOdo = Math.max(vehicle.odometer, ...logs.map((l) => l.odometer || 0));
    updateVehicle({
      ...vehicle,
      odometer: maxOdo,
      logs: [...vehicle.logs, ...logs],
    });
    const returnTo = ["home", "log", "setup"].includes(screen.returnTo) ? screen.returnTo : "home";
    setScreen({ name: "vehicle", vehicleId: vehicle.id, returnTo });
  };

  const addLog = (log) => {
    addLogs([log]);
  };

  if (!ready) {
    return (
      <SafeAreaProvider>
        <SafeAreaView style={[styles.root, { backgroundColor: c.bg }]} edges={["top", "bottom"]}>
          <StatusBar style={scheme === "dark" ? "light" : "dark"} />
        </SafeAreaView>
      </SafeAreaProvider>
    );
  }

  return (
    <SafeAreaProvider>
      <View style={[styles.root, { backgroundColor: c.bg }]}>
        <StatusBar style={scheme === "dark" ? "light" : "dark"} />
        <SafeAreaView style={styles.root} edges={onTab ? ["top"] : ["top", "bottom"]}>
          {screen.name === "home" && (
            <HomeScreen
              vehicles={vehicles}
              onOpenVehicle={(id) => setScreen({ name: "vehicle", vehicleId: id, returnTo: "home" })}
              onAddVehicle={() => setScreen({ name: "addVehicle", returnTo: "home" })}
              onOpenCategory={(vehicleId, categoryId) =>
                setScreen({ name: "addLog", vehicleId, categoryId, returnTo: "home" })
              }
            />
          )}

          {screen.name === "log" && (
            <LogScreen
              vehicles={vehicles}
              onOpenVehicle={(id) => setScreen({ name: "vehicle", vehicleId: id, returnTo: "log" })}
            />
          )}

          {screen.name === "setup" && (
            <SetupScreen
              vehicles={vehicles}
              configs={configs}
              onConfigsChange={setConfigs}
              onAddVehicle={() => setScreen({ name: "addVehicle", returnTo: "setup" })}
              onManage={(id) => setScreen({ name: "manage", vehicleId: id, returnTo: "setup" })}
              onCreateFromConfig={(cfg) =>
                setScreen({
                  name: "addVehicle",
                  returnTo: "setup",
                  configId: cfg.builtin ? "default" : cfg.id,
                  vehicleType: cfg.type,
                })
              }
            />
          )}

          {screen.name === "addVehicle" && (
            <AddVehicleScreen
              onBack={() => setScreen({ name: screen.returnTo || "home" })}
              configs={configs}
              initialConfigId={screen.configId}
              initialType={screen.vehicleType}
              onSave={(v) => {
                setVehicles((vs) => [...vs, v]);
                setScreen({ name: "vehicle", vehicleId: v.id, returnTo: screen.returnTo || "home" });
              }}
            />
          )}

          {screen.name === "vehicle" && vehicle && (
            <VehicleScreen
              vehicle={vehicle}
              onBack={() => setScreen({ name: screen.returnTo || "home" })}
              onOpenCategory={(catId) =>
                setScreen({ name: "addLog", vehicleId: vehicle.id, categoryId: catId, returnTo: "vehicle" })
              }
              onManage={() => setScreen({ name: "manage", vehicleId: vehicle.id, returnTo: "vehicle" })}
              onOpenService={(packageId) =>
                setScreen({
                  name: "service",
                  vehicleId: vehicle.id,
                  packageId,
                  returnTo: screen.returnTo,
                })
              }
              onAddService={() =>
                setScreen({ name: "editService", vehicleId: vehicle.id, returnTo: screen.returnTo })
              }
              onUpdateOdo={(val) => updateVehicle({ ...vehicle, odometer: val })}
              onUpdate={(fields) => updateVehicle({ ...vehicle, ...fields })}
            />
          )}

          {screen.name === "service" && vehicle && (
            <ServiceScreen
              vehicle={vehicle}
              packageId={screen.packageId}
              onBack={() => setScreen({ name: "vehicle", vehicleId: vehicle.id, returnTo: screen.returnTo })}
              onSave={addLogs}
            />
          )}

          {screen.name === "editService" && vehicle && (
            <EditServiceScreen
              vehicle={vehicle}
              serviceId={screen.serviceId}
              onBack={() =>
                setScreen(
                  screen.returnTo === "manage"
                    ? { name: "manage", vehicleId: vehicle.id, returnTo: "vehicle" }
                    : { name: "vehicle", vehicleId: vehicle.id, returnTo: screen.returnTo || "home" }
                )
              }
              onUpdateVehicle={updateVehicle}
            />
          )}

          {screen.name === "addLog" && vehicle && category && (
            <AddLogScreen
              vehicle={vehicle}
              category={category}
              onBack={() =>
                setScreen(
                  screen.returnTo === "home" ? { name: "home" } : { name: "vehicle", vehicleId: vehicle.id }
                )
              }
              onSave={addLog}
            />
          )}

          {screen.name === "manage" && vehicle && (
            <ManageCategoriesScreen
              vehicle={vehicle}
              onBack={() =>
                setScreen(
                  screen.returnTo === "setup" ? { name: "setup" } : { name: "vehicle", vehicleId: vehicle.id }
                )
              }
              onUpdateVehicle={updateVehicle}
              onEditService={(serviceId) =>
                setScreen({ name: "editService", vehicleId: vehicle.id, serviceId, returnTo: "manage" })
              }
              onAddService={() =>
                setScreen({ name: "editService", vehicleId: vehicle.id, returnTo: "manage" })
              }
              onSaveConfig={(cfg) => setConfigs((list) => [...list, cfg])}
            />
          )}
        </SafeAreaView>

        {onTab && <TabBar tab={screen.name} onChange={(name) => setScreen({ name })} />}
      </View>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
  },
});
