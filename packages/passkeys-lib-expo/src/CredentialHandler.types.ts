import { NativeModule } from "expo";
import {
  AttestationOptions,
  EventTypeMap,
  PublicKeyCredential,
  AuthenticatorAttestationResponse,
  AssertionOptions,
  AuthenticatorAssertionResponse,
} from "passkeys-lib";

import { CredentialHandlerModule as WebHandler } from "../web";

export declare class CredentialHandlerModule extends NativeModule<{
  [K in keyof EventTypeMap]: (event: EventTypeMap[K]) => void;
}> {}

export type CredentialHandlerModuleType = Omit<
  typeof WebHandler,
  "register" | "authenticate"
> & {
  register: (
    args: AttestationOptions<string | BufferSource>,
  ) => Promise<PublicKeyCredential<
    string | BufferSource,
    AuthenticatorAttestationResponse<string | BufferSource>
  > | null>;
  authenticate: (
    args: AssertionOptions<string | BufferSource>,
  ) => Promise<PublicKeyCredential<
    string | BufferSource,
    AuthenticatorAssertionResponse<string | BufferSource>
  > | null>;
};
