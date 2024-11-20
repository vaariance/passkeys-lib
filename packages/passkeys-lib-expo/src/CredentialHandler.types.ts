import { NativeModule } from "expo";
import {
  AttestationOptions,
  EventTypeMap,
  PublicKeyCredential,
  AuthenticatorAttestationResponse,
  AssertionOptions,
  AuthenticatorAssertionResponse,
  CredentialHandlerModule as DefaultHandler,
} from "passkeys-lib";

export declare class CredentialHandlerModule extends NativeModule<{
  [K in keyof EventTypeMap]: (event: EventTypeMap[K]) => void;
}> {}

export type CredentialHandlerModuleType<T = BufferSource | string> = Omit<
  typeof CredentialHandlerModule,
  "prototype"
> &
  Pick<ReturnType<typeof DefaultHandler>, "defaultConfiguration" | "events"> & {
    register: (
      args: AttestationOptions<string>,
    ) => Promise<PublicKeyCredential<
      T,
      AuthenticatorAttestationResponse<T>
    > | null>;
    authenticate: (
      args: AssertionOptions<string>,
    ) => Promise<PublicKeyCredential<
      T,
      AuthenticatorAssertionResponse<T>
    > | null>;
  };
