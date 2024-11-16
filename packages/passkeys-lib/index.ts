import {
  type AssertionOptions,
  type AttestationOptions,
  type CreateCredentialOptions,
  type GetCredentialOptions,
  type PublicKeyCredential,
  type AuthenticatorAttestationResponse,
  type AuthenticatorAssertionResponse,
  type CredentialHandlerModuleEvents,
  type Subscription,
  type EventEmitter,
  type EventTypeMap,
  Constants,
} from "./types";

const EventEmitter = (): EventEmitter => {
  const listeners = <
    {
      [K in keyof EventTypeMap]: Set<(event: EventTypeMap[K]) => void>;
    }
  >{};

  return {
    addListener<T extends keyof EventTypeMap>(
      eventName: T,
      listener: (event: EventTypeMap[T]) => void
    ): Subscription {
      if (!listeners[eventName]) {
        listeners[eventName] = new Set<any>();
      }
      listeners[eventName].add(listener);

      return {
        remove: () => {
          listeners[eventName].delete(listener);
        },
      };
    },

    removeAllListeners(eventName: CredentialHandlerModuleEvents): void {
      delete listeners[eventName];
    },

    removeSubscription(subscription: Subscription): void {
      subscription.remove();
    },

    emit<T extends keyof EventTypeMap>(
      eventName: T,
      params: EventTypeMap[T]
    ): void {
      const callbacks = listeners[eventName];
      if (callbacks) {
        callbacks.forEach((callback) => callback(params));
      }
    },
  };
};

export const CredentialHandlerModule = (
  eventEmitter: EventEmitter = EventEmitter()
) => {
  const moduleObject = {
    // Constants
    defaultConfiguraton: { ...Constants },

    // Events
    events: {
      onRegistrationStarted: (
        callback: (event: EventTypeMap["onRegistrationStarted"]) => void
      ) => eventEmitter.addListener("onRegistrationStarted", callback),
      onRegistrationFailed: (
        callback: (event: EventTypeMap["onRegistrationFailed"]) => void
      ) => eventEmitter.addListener("onRegistrationFailed", callback),
      onRegistrationComplete: (
        callback: (event: EventTypeMap["onRegistrationComplete"]) => void
      ) => eventEmitter.addListener("onRegistrationComplete", callback),
      onAuthenticationStarted: (
        callback: (event: EventTypeMap["onAuthenticationStarted"]) => void
      ) => eventEmitter.addListener("onAuthenticationStarted", callback),
      onAuthenticationFailed: (
        callback: (event: EventTypeMap["onAuthenticationFailed"]) => void
      ) => eventEmitter.addListener("onAuthenticationFailed", callback),
      onAuthenticationSuccess: (
        callback: (event: EventTypeMap["onAuthenticationSuccess"]) => void
      ) => eventEmitter.addListener("onAuthenticationSuccess", callback),
    },
  };

  // Helper functions
  const helpers = {
    parseAssertionOptions: (
      args: AssertionOptions<BufferSource>
    ): GetCredentialOptions => {
      return {
        ...args,
        allowCredentials: args.allowCredentials?.items ?? [],
        timeout: args.timeout ?? Constants.TIMEOUT,
        userVerification: args.userVerification ?? Constants.USER_VERIFICATION,
      };
    },

    parseAttestationOptions: (
      args: AttestationOptions<BufferSource>
    ): CreateCredentialOptions => {
      return {
        ...args,
        pubKeyCredParams: [Constants.PUB_KEY_CRED_PARAM],
        timeout: args.timeout ?? Constants.TIMEOUT,
        attestation: args.attestation ?? Constants.ATTESTATION,
        excludeCredentials: args.excludeCredentials?.items ?? [],
        authenticatorSelection: args.authenticatorSelection ?? {
          authenticatorAttachment: Constants.AUTHENTICATOR_ATTACHMENT,
          requireResidentKey: Constants.REQUIRE_RESIDENT_KEY,
          residentKey: Constants.RESIDENT_KEY,
          userVerification: Constants.USER_VERIFICATION,
        },
      };
    },
    _emitEvent: eventEmitter.emit.bind(eventEmitter),
  };

  const mainFunctions = {
    async register(
      this: typeof helpers,
      args: AttestationOptions<BufferSource>
    ) {
      if (!navigator.credentials) {
        throw new Error(
          "Web Authentication API is not supported in this environment."
        );
      }
      try {
        const createOptions = this.parseAttestationOptions(args);
        this._emitEvent("onRegistrationStarted", createOptions);
        const credential = await internalFunctions.register(createOptions);
        this._emitEvent("onRegistrationComplete", credential);
        return credential;
      } catch (error: unknown) {
        this._emitEvent("onRegistrationFailed", error);
        throw error;
      }
    },

    async authenticate(
      this: typeof helpers,
      args: AssertionOptions<BufferSource>
    ) {
      if (!navigator.credentials) {
        throw new Error(
          "Web Authentication API is not supported in this environment."
        );
      }
      try {
        const getOptions = this.parseAssertionOptions(args);
        this._emitEvent("onAuthenticationStarted", getOptions);
        const credential = await internalFunctions.authenticate(getOptions);
        this._emitEvent("onAuthenticationSuccess", credential);
        return credential;
      } catch (error: unknown) {
        this._emitEvent("onAuthenticationFailed", error);
        throw error;
      }
    },
  };

  const internalFunctions = {
    register: async (
      request: CreateCredentialOptions
    ): Promise<PublicKeyCredential<
      BufferSource,
      AuthenticatorAttestationResponse<BufferSource>
    > | null> =>
      navigator.credentials.create({
        publicKey: request,
      }),

    authenticate: async (
      request: GetCredentialOptions
    ): Promise<PublicKeyCredential<
      BufferSource,
      AuthenticatorAssertionResponse<BufferSource>
    > | null> =>
      navigator.credentials.get({
        publicKey: request,
      }),
  };

  return Object.assign(moduleObject, helpers, mainFunctions);
};

export * from "./types";
