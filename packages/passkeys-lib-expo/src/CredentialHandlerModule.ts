import { requireNativeModule } from "expo";
import {
  type EventTypeMap,
  type PublicKeyCredential,
  type AuthenticatorAttestationResponse,
  type AuthenticatorAssertionResponse,
  type AttestationOptions,
  type AssertionOptions,
} from "passkeys-lib";

import { CredentialHandlerModule } from "./CredentialHandler.types";

const nativeModule =
  requireNativeModule<CredentialHandlerModule>("CredentialHandler");

const moduleObjects = {
  defaultConfiguraton: {
    TIMEOUT: nativeModule.TIMEOUT,
    ATTESTATION: nativeModule.ATTESTATION as AttestationConveyancePreference,
    AUTHENTICATOR_ATTACHMENT:
      nativeModule.AUTHENTICATOR_ATTACHMENT as AuthenticatorAttachment,
    REQUIRE_RESIDENT_KEY: nativeModule.REQUIRE_RESIDENT_KEY as boolean,
    RESIDENT_KEY: nativeModule.RESIDENT_KEY as ResidentKeyRequirement,
    USER_VERIFICATION:
      nativeModule.USER_VERIFICATION as UserVerificationRequirement,
    PUB_KEY_CRED_PARAM:
      nativeModule.PUB_KEY_CRED_PARAM as PublicKeyCredentialParameters,
  },

  events: {
    onRegistrationStarted: (
      callback: (event: EventTypeMap["onRegistrationStarted"]) => void,
    ) => nativeModule.addListener("onRegistrationStarted", callback),
    onRegistrationFailed: (
      callback: (event: EventTypeMap["onRegistrationFailed"]) => void,
    ) => nativeModule.addListener("onRegistrationFailed", callback),
    onRegistrationComplete: (
      callback: (event: EventTypeMap["onRegistrationComplete"]) => void,
    ) => nativeModule.addListener("onRegistrationComplete", callback),
    onAuthenticationStarted: (
      callback: (event: EventTypeMap["onAuthenticationStarted"]) => void,
    ) => nativeModule.addListener("onAuthenticationStarted", callback),
    onAuthenticationFailed: (
      callback: (event: EventTypeMap["onAuthenticationFailed"]) => void,
    ) => nativeModule.addListener("onAuthenticationFailed", callback),
    onAuthenticationSuccess: (
      callback: (event: EventTypeMap["onAuthenticationSuccess"]) => void,
    ) => nativeModule.addListener("onAuthenticationSuccess", callback),
  },
};

const mainFunctions = {
  async register(
    args: AttestationOptions<string>,
  ): Promise<PublicKeyCredential<
    string,
    AuthenticatorAttestationResponse<string>
  > | null> {
    const credential = await nativeModule.register(
      args.preferImmediatelyAvailableCred ?? false,
      args.challenge,
      args.rp,
      args.user,
      args.timeout,
      args.attestation,
      args.excludeCredentials,
      args.authenticatorSelection,
    );
    return credential;
  },

  async authenticate(
    args: AssertionOptions<string>,
  ): Promise<PublicKeyCredential<
    string,
    AuthenticatorAssertionResponse<string>
  > | null> {
    const credential = await nativeModule.authenticate(
      args.preferImmediatelyAvailableCred ?? false,
      args.challenge,
      args.timeout,
      args.rpId,
      args.userVerification,
      args.allowCredentials,
    );
    return credential;
  },
};

export default Object.assign(moduleObjects, mainFunctions, {
  addListener: nativeModule.addListener,
  removeListeners: nativeModule.removeListeners,
  removeAllListeners: nativeModule.removeAllListeners,
  removeSubscription: nativeModule.removeSubscription,
  emit: nativeModule.emit,
});
