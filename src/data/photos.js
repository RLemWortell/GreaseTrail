import { Alert } from "react-native";
import * as ImagePicker from "expo-image-picker";
import * as FileSystem from "expo-file-system";

const DIR = `${FileSystem.documentDirectory}photos/`;
export const MAX_PHOTOS = 8;

async function ensureDir() {
  const info = await FileSystem.getInfoAsync(DIR);
  if (!info.exists) {
    await FileSystem.makeDirectoryAsync(DIR, { intermediates: true });
  }
}

async function persist(uri) {
  await ensureDir();
  const name = `${Date.now()}-${Math.random().toString(36).slice(2, 8)}.jpg`;
  const dest = `${DIR}${name}`;
  await FileSystem.copyAsync({ from: uri, to: dest });
  return dest;
}

async function pick(fromCamera) {
  if (fromCamera) {
    const perm = await ImagePicker.requestCameraPermissionsAsync();
    if (!perm.granted) {
      Alert.alert("Camera", "Allow camera access to take a photo.");
      return [];
    }
    const result = await ImagePicker.launchCameraAsync({ quality: 0.7 });
    if (result.canceled) return [];
    return Promise.all(result.assets.map((a) => persist(a.uri)));
  }

  const perm = await ImagePicker.requestMediaLibraryPermissionsAsync();
  if (!perm.granted) {
    Alert.alert("Photos", "Allow photo access to attach pictures.");
    return [];
  }
  const result = await ImagePicker.launchImageLibraryAsync({
    mediaTypes: ImagePicker.MediaTypeOptions.Images,
    quality: 0.7,
    allowsMultipleSelection: true,
    selectionLimit: MAX_PHOTOS,
  });
  if (result.canceled) return [];
  return Promise.all(result.assets.map((a) => persist(a.uri)));
}

export function addPhotos(current = []) {
  const room = MAX_PHOTOS - current.length;
  if (room <= 0) {
    Alert.alert("Photos", `You can attach up to ${MAX_PHOTOS} photos.`);
    return Promise.resolve([]);
  }

  return new Promise((resolve) => {
    Alert.alert("Add photo", undefined, [
      { text: "Cancel", style: "cancel", onPress: () => resolve([]) },
      {
        text: "Camera",
        onPress: async () => resolve(await pick(true)),
      },
      {
        text: "Library",
        onPress: async () => resolve(await pick(false)),
      },
    ]);
  });
}

export async function removePhotoFile(uri) {
  if (!uri || !uri.startsWith(DIR)) return;
  try {
    await FileSystem.deleteAsync(uri, { idempotent: true });
  } catch (e) {
    console.warn("GreaseTrail: could not delete photo", e);
  }
}
