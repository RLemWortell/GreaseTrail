import React from "react";
import { ScreenHeader } from "./ui";

export default function TopBar({ title, onBack, rightLabel, onRightPress, subtitle }) {
  return (
    <ScreenHeader
      title={title}
      onBack={onBack}
      rightLabel={rightLabel}
      onRightPress={onRightPress}
      rightIcon={null}
      subtitle={subtitle}
    />
  );
}
