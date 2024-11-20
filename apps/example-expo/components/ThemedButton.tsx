import React from "react";
import {
  TouchableOpacity,
  Text,
  StyleSheet,
  ActivityIndicator,
  ViewStyle,
  TextStyle,
  StyleProp,
} from "react-native";
import { useThemeColor } from "@/hooks/useThemeColor";

type ButtonVariant = "primary" | "secondary" | "outline" | "ghost";
type ButtonSize = "sm" | "md" | "lg";

interface ThemedButtonProps {
  onPress: () => void;
  children: React.ReactNode;
  variant?: ButtonVariant;
  size?: ButtonSize;
  disabled?: boolean;
  loading?: boolean;
  style?: StyleProp<ViewStyle>;
  textStyle?: StyleProp<TextStyle>;
  fullWidth?: boolean;
  lightColor?: string;
  darkColor?: string;
}

export const ThemedButton: React.FC<ThemedButtonProps> = ({
  onPress,
  children,
  variant = "primary",
  size = "md",
  disabled = false,
  loading = false,
  style,
  textStyle,
  fullWidth = false,
  lightColor,
  darkColor,
}) => {
  const tintColor = useThemeColor(
    { light: lightColor, dark: darkColor },
    "tint"
  );
  const textColor = useThemeColor(
    { light: lightColor, dark: darkColor },
    "text"
  );
  const iconColor = useThemeColor(
    { light: lightColor, dark: darkColor },
    "icon"
  );

  const getVariantStyles = (): ViewStyle => {
    switch (variant) {
      case "primary":
        return {
          backgroundColor: disabled ? iconColor : tintColor,
          borderWidth: 0,
        };
      case "secondary":
        return {
          backgroundColor: disabled
            ? useThemeColor({ light: "#F1F3F5", dark: "#1F2123" }, "background")
            : useThemeColor(
                { light: "#EDF2F7", dark: "#2B2F31" },
                "background"
              ),
          borderWidth: 0,
        };
      case "outline":
        return {
          backgroundColor: "transparent",
          borderWidth: 1,
          borderColor: disabled ? iconColor : tintColor,
        };
      case "ghost":
        return {
          backgroundColor: "transparent",
          borderWidth: 0,
        };
      default:
        return {};
    }
  };

  const getVariantTextColor = (): string => {
    if (disabled) return iconColor;

    switch (variant) {
      case "primary":
        return "#FFFFFF"; // Keep white for contrast on primary
      case "secondary":
        return textColor;
      case "outline":
      case "ghost":
        return tintColor;
      default:
        return textColor;
    }
  };

  const getSizeStyles = (): ViewStyle => {
    switch (size) {
      case "sm":
        return {
          paddingVertical: 8,
          paddingHorizontal: 16,
          borderRadius: 6,
        };
      case "lg":
        return {
          paddingVertical: 16,
          paddingHorizontal: 24,
          borderRadius: 10,
        };
      default: // md
        return {
          paddingVertical: 12,
          paddingHorizontal: 20,
          borderRadius: 8,
        };
    }
  };

  const getTextSize = (): TextStyle => {
    switch (size) {
      case "sm":
        return { fontSize: 14, lineHeight: 20 };
      case "lg":
        return { fontSize: 18, lineHeight: 24 };
      default: // md
        return { fontSize: 16, lineHeight: 22 };
    }
  };

  return (
    <TouchableOpacity
      onPress={onPress}
      disabled={disabled || loading}
      style={[
        styles.button,
        getVariantStyles(),
        getSizeStyles(),
        fullWidth && styles.fullWidth,
        style,
      ]}
      activeOpacity={0.7}
    >
      {loading ? (
        <ActivityIndicator
          color={getVariantTextColor()}
          size={size === "sm" ? "small" : "small"}
        />
      ) : (
        <Text
          style={[
            styles.text,
            getTextSize(),
            { color: getVariantTextColor() },
            textStyle,
          ]}
        >
          {children}
        </Text>
      )}
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    alignItems: "center",
    justifyContent: "center",
    flexDirection: "row",
  },
  fullWidth: {
    width: "100%",
  },
  text: {
    fontWeight: "600",
    textAlign: "center",
  },
});
