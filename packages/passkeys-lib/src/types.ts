export type Subscription = {
  remove: () => void;
};
export type EventEmitter = {
  addListener: <T extends keyof EventTypeMap>(
    eventName: T,
    listener: (event: EventTypeMap[T]) => void
  ) => Subscription;
  removeAllListeners: (eventName: CredentialHandlerModuleEvents) => void;
  removeSubscription?: (subscription: Subscription) => void;
  emit: <T extends keyof EventTypeMap>(
    eventName: T,
    params: EventTypeMap[T]
  ) => void;
};

export type CredentialHandlerModuleEvents =
  | "onRegistrationStarted"
  | "onRegistrationFailed"
  | "onRegistrationComplete"
  | "onAuthenticationStarted"
  | "onAuthenticationFailed"
  | "onAuthenticationSuccess";

export type EventTypeMap = {
  onRegistrationStarted: CreateCredentialOptions;
  onRegistrationComplete: PublicKeyCredential<
    BufferSource,
    AuthenticatorAttestationResponse<BufferSource>
  > | null;
  onRegistrationFailed: unknown;
  onAuthenticationStarted: GetCredentialOptions;
  onAuthenticationSuccess: PublicKeyCredential<
    BufferSource,
    AuthenticatorAssertionResponse<BufferSource>
  > | null;
  onAuthenticationFailed: unknown;
};

export type RelyingParty = {
  name: string;
  id: string;
};

export type UserEntity<T extends string | BufferSource = BufferSource> = {
  id: T;
  name: string;
  displayName: string;
};

export type AuthenticatorSelection = {
  authenticatorAttachment: AuthenticatorAttachment;
  requireResidentKey: boolean;
  residentKey: ResidentKeyRequirement;
  userVerification: UserVerificationRequirement;
};

export type ExclusiveCredentials = {
  items: PublicKeyCredentialDescriptor[];
};

type ExclusiveCredentialsB64 = {
  items: (Pick<PublicKeyCredentialDescriptor, "type" | "transports"> & {
    id: string;
  })[];
};

export interface CreateCredentialOptions {
  rp: RelyingParty;
  user: UserEntity;
  challenge: BufferSource;
  pubKeyCredParams: PublicKeyCredentialParameters[];
  timeout: number;
  authenticatorSelection: AuthenticatorSelection;
  attestation: AttestationConveyancePreference;
  excludeCredentials?: PublicKeyCredentialDescriptor[];
}

export interface GetCredentialOptions {
  challenge: BufferSource;
  allowCredentials: PublicKeyCredentialDescriptor[];
  timeout: number;
  userVerification?: UserVerificationRequirement;
  rpId?: string;
}

export const Constants = {
  TIMEOUT: 60000,
  ATTESTATION: "direct" as AttestationConveyancePreference,
  AUTHENTICATOR_ATTACHMENT: "platform" as AuthenticatorAttachment,
  REQUIRE_RESIDENT_KEY: true,
  RESIDENT_KEY: "required" as ResidentKeyRequirement,
  USER_VERIFICATION: "required" as UserVerificationRequirement,
  PUB_KEY_CRED_PARAM: {
    type: "public-key",
    alg: -7,
  } as PublicKeyCredentialParameters,
};

export type AttestationOptions<G = string | BufferSource> =
  G extends BufferSource ? AttestationOptionsBinary : AttestationOptionsB64;

export type AttestationOptionsBinary = {
  preferImmediatelyAvailableCred?: boolean;
  challenge: BufferSource;
  rp: RelyingParty;
  user: UserEntity;
  timeout: number | null;
  attestation: AttestationConveyancePreference | null;
  excludeCredentials?: ExclusiveCredentials;
  authenticatorSelection?: AuthenticatorSelection;
};

export type AttestationOptionsB64 = Omit<
  AttestationOptionsBinary,
  "challenge" | "user" | "excludeCredentials"
> & {
  challenge: string;
  user: UserEntity<string>;
  excludeCredentials?: ExclusiveCredentialsB64;
};

export type AssertionOptions<H = string | BufferSource> = H extends BufferSource
  ? AssertionOptionsBinary
  : AssertionOptionsB64;

export type AssertionOptionsBinary = {
  preferImmediatelyAvailableCred?: boolean;
  challenge: BufferSource;
  allowCredentials?: ExclusiveCredentials;
  timeout: number | null;
  userVerification?: UserVerificationRequirement;
  rpId?: string;
};

export type AssertionOptionsB64 = Omit<
  AssertionOptionsBinary,
  "challenge" | "allowCredentials"
> & {
  challenge: string;
  allowCredentials?: ExclusiveCredentialsB64;
};

export type PublicKeyCredential<
  S = BufferSource | string,
  T = AuthenticatorAttestationResponse<S> | AuthenticatorAssertionResponse<S>,
> = {
  id: string;
  rawId?: S;
  type: string;
  response?: T;
};

export type AuthenticatorAttestationResponse<T> = {
  attestationObject: T;
  clientDataJSON: T;
  authenticatorData?: T;
  publicKey?: T;
  publicKeyAlgorithm?: number;
  transports?: AuthenticatorTransport[];
};

export type AuthenticatorAssertionResponse<U> = {
  authenticatorData: U;
  signature: U;
  clientDataJSON: U;
  userHandle: U;
};

export type ClientDataObject = {
  challenge: string;
  origin: string;
  type: "webauthn.create" | "webauthn.get";
};

export type AttestationObject = {
  authData: ArrayBuffer;
  fmt: string;
  attStmt: AttestationStatement;
};

export type AttestationStatement = {
  sig: Uint8Array;
  x5c: ArrayLike<number>;
  alg: number;
};

export type AttestedCredentialData<T = ArrayBuffer> = {
  aaguid: ArrayBuffer;
  credentialIDLength: number;
  credentialID: ArrayBuffer;
  credentialPublicKey: Tuple<T, T>;
};

export type Tuple<T, U> = [T, U];
