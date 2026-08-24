import React, { useState } from "react";
import {
  View,
  Image,
  TouchableOpacity,
  ScrollView,
  Modal,
  Pressable,
  StyleSheet,
} from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { useC } from "./ui";
import { SPACE } from "../theme";
import { addPhotos, removePhotoFile, MAX_PHOTOS } from "../data/photos";

export function PhotoStrip({ uris = [], onChange, editable = false }) {
  const c = useC();
  const [open, setOpen] = useState(null);

  const add = async () => {
    const added = await addPhotos(uris);
    if (added.length) onChange([...(uris || []), ...added].slice(0, MAX_PHOTOS));
  };

  const remove = async (uri) => {
    await removePhotoFile(uri);
    onChange((uris || []).filter((u) => u !== uri));
  };

  if (!editable && (!uris || uris.length === 0)) return null;

  return (
    <View>
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ gap: 8, paddingVertical: 2 }}
      >
        {(uris || []).map((uri) => (
          <View key={uri}>
            <TouchableOpacity onPress={() => setOpen(uri)} activeOpacity={0.8}>
              <Image
                source={{ uri }}
                style={{ width: 72, height: 72, borderRadius: 8, backgroundColor: c.photo }}
              />
            </TouchableOpacity>
            {editable ? (
              <TouchableOpacity
                onPress={() => remove(uri)}
                hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
                style={{
                  position: "absolute",
                  top: -6,
                  right: -6,
                  width: 20,
                  height: 20,
                  borderRadius: 10,
                  backgroundColor: c.ink,
                  alignItems: "center",
                  justifyContent: "center",
                }}
              >
                <Ionicons name="close" size={12} color={c.card} />
              </TouchableOpacity>
            ) : null}
          </View>
        ))}
        {editable && (uris || []).length < MAX_PHOTOS ? (
          <TouchableOpacity
            onPress={add}
            activeOpacity={0.7}
            style={{
              width: 72,
              height: 72,
              borderRadius: 8,
              borderWidth: 1,
              borderColor: c.border,
              alignItems: "center",
              justifyContent: "center",
            }}
          >
            <Ionicons name="camera-outline" size={22} color={c.ink} />
          </TouchableOpacity>
        ) : null}
      </ScrollView>
      <PhotoViewer uri={open} onClose={() => setOpen(null)} />
    </View>
  );
}

export function PhotoThumbs({ uris, size = 44 }) {
  const c = useC();
  const [open, setOpen] = useState(null);
  if (!uris || uris.length === 0) return null;

  return (
    <View>
      <View style={{ flexDirection: "row", flexWrap: "wrap", gap: 6, marginTop: 8 }}>
        {uris.slice(0, 4).map((uri) => (
          <TouchableOpacity key={uri} onPress={() => setOpen(uri)} activeOpacity={0.8}>
            <Image
              source={{ uri }}
              style={{ width: size, height: size, borderRadius: 6, backgroundColor: c.photo }}
            />
          </TouchableOpacity>
        ))}
      </View>
      <PhotoViewer uri={open} onClose={() => setOpen(null)} />
    </View>
  );
}

function PhotoViewer({ uri, onClose }) {
  const c = useC();
  return (
    <Modal visible={!!uri} transparent animationType="fade" onRequestClose={onClose}>
      <Pressable
        onPress={onClose}
        style={[StyleSheet.absoluteFill, { backgroundColor: "rgba(26,26,26,0.94)", justifyContent: "center" }]}
      >
        {uri ? (
          <Image source={{ uri }} style={{ width: "100%", height: "80%" }} resizeMode="contain" />
        ) : null}
        <Ionicons
          name="close"
          size={22}
          color={c.card}
          style={{ position: "absolute", top: 56, right: SPACE.side }}
        />
      </Pressable>
    </Modal>
  );
}
