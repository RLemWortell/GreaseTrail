import AsyncStorage from "@react-native-async-storage/async-storage";

const KEY = "greasetrail:vehicles:v1";

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
