import { useWindowDimensions, StyleSheet, Platform } from "react-native";

import { ThemedButton } from "@/components/ThemedButton";
import { ThemedText } from "@/components/ThemedText";
import { ThemedView } from "@/components/ThemedView";
import { SafeAreaView } from "react-native-safe-area-context";

import CredentialHandlerModule, {
  type CredentialHandlerModuleType,
  toBase64Url,
} from "passkeys-lib-expo";

const rpData =
  Platform.OS === "web"
    ? {
        rpId: "localhost",
        rpName: "localhost",
      }
    : {
        rpId: "variance.space",
        rpName: "variance",
      };

export default function HomeScreen() {
  const { height: screenHeight } = useWindowDimensions();

  const credentialManager: CredentialHandlerModuleType =
    CredentialHandlerModule;
  const { rpId, rpName } = rpData;

  const register = async () => {
    const result = await credentialManager.register({
      attestation: "none",
      challenge: toBase64Url("register me"),
      rp: {
        id: rpId,
        name: rpName,
      },
      user: {
        displayName: "user",
        id: toBase64Url("user id"),
        name: `user@${rpId}`,
      },
      timeout: 60000,
    });
    console.log(result);
  };

  const authenticate = async () => {
    const result = await credentialManager.authenticate({
      challenge: toBase64Url("sign this"),
      timeout: 60000,
      userVerification: "required",
      rpId: rpId,
    });
    console.log(result);
  };
  return (
    <SafeAreaView>
      <ThemedView style={[styles.container, { height: screenHeight }]}>
        <ThemedButton variant={"secondary"} onPress={register}>
          <ThemedText>Create A Passkey</ThemedText>
        </ThemedButton>
        <ThemedButton variant={"secondary"} onPress={authenticate}>
          <ThemedText>Sign in with Passkey</ThemedText>
        </ThemedButton>
      </ThemedView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    display: "flex",
    width: "100%",
    alignItems: "center",
    justifyContent: "center",
    flexDirection: "column-reverse",
    padding: 6,
    gap: 5,
  },
});
