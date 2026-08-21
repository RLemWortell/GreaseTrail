import AsyncStorage from "@react-native-async-storage/async-storage";

const KEY = "greasetrail:vehicles:v1";
const CONFIG_KEY = "greasetrail:configs:v1";

export async function loadVehicles() {
  try {
    const raw = await AsyncStorage.getItem(KEY);
    if (!raw) return null;
    return JSON.parse(raw);
  } catch (e) {
    console.warn("GreaseTrail: failed to load vehicles", e);
    return null;
  }
}

export async function saveVehicles(vehicles) {
  try {
    await AsyncStorage.setItem(KEY, JSON.stringify(vehicles));
  } catch (e) {
    console.warn("GreaseTrail: failed to save vehicles", e);
  }
}

export async function loadConfigs() {
  try {
    const raw = await AsyncStorage.getItem(CONFIG_KEY);
    if (!raw) return [];
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed : [];
  } catch (e) {
    console.warn("GreaseTrail: failed to load configs", e);
    return [];
  }
}

export async function saveConfigs(configs) {
  try {
    await AsyncStorage.setItem(CONFIG_KEY, JSON.stringify(configs));
  } catch (e) {
    console.warn("GreaseTrail: failed to save configs", e);
  }
}
