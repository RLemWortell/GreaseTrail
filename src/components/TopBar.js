import React from "react";
import { View, Text, StyleSheet } from "react-native";
import { T } from "../theme";
import { IconButton } from "./ui";

export default function TopBar({ title, onBack, right }) {
  return (
    <View style={styles.bar}>
      <View style={styles.side}>{onBack && <IconButton icon="chevron-left" onPress={onBack} />}</View>
      <Text style={styles.title} numberOfLines={1}>
        {title}
      </Text>
      <View style={[styles.side, { alignItems: "flex-end" }]}>{right}</View>
    </View>
  );
}

const styles = StyleSheet.create({
  bar: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: 16,
    paddingTop: 16,
    paddingBottom: 14,
    backgroundColor: T.bgBase,
    borderBottomWidth: 1,
    borderBottomColor: T.hairline,
  },
  side: {
    minWidth: 40,
  },
  title: {
    color: T.textPrimary,
    fontWeight: "600",
    fontSize: 16,
    flex: 1,
    textAlign: "center",
  },
});
