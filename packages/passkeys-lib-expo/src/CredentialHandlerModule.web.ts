import { NativeModule, registerWebModule } from "expo";
import {
  type AssertionOptions,
  type AttestationOptions,
  type AuthenticatorAssertionResponse,
  type AuthenticatorAttestationResponse,
  type PublicKeyCredential,
  type EventEmitter,
  type EventTypeMap,
  CredentialHandlerModule as WebHandler,
} from "passkeys-lib";

import { base64UrlToBuffer } from "./utils";

export class CredentialHandlerModule extends NativeModule<{
  [K in keyof EventTypeMap]: (event: EventTypeMap[K]) => void;
}> {
  private webModule = WebHandler(this as EventEmitter);
  defaultConfiguration = this.webModule.defaultConfiguration;
  events = this.webModule.events;
  async authenticate(
    args: AssertionOptions<string>,
  ): Promise<PublicKeyCredential<
    BufferSource,
    AuthenticatorAssertionResponse<BufferSource>
  > | null> {
    return this.webModule.authenticate({
      ...args,
      challenge: base64UrlToBuffer(args.challenge),
      allowCredentials: args.allowCredentials
        ? {
            items: args.allowCredentials?.items.map((cred) => ({
              ...cred,
              id: base64UrlToBuffer(cred.id),
            })),
          }
        : undefined,
    });
  }

  async register(
    args: AttestationOptions<string>,
  ): Promise<PublicKeyCredential<
    BufferSource,
    AuthenticatorAttestationResponse<BufferSource>
  > | null> {
    return this.webModule.register({
      ...args,
      challenge: base64UrlToBuffer(args.challenge),
      excludeCredentials: args.excludeCredentials
        ? {
            items: args.excludeCredentials?.items.map((cred) => ({
              ...cred,
              id: base64UrlToBuffer(cred.id),
            })),
          }
        : undefined,
      user: {
        ...args.user,
        id: base64UrlToBuffer(args.user.id),
      },
    });
  }
}

const webModule = registerWebModule(CredentialHandlerModule);

export default webModule;
