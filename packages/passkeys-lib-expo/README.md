# passkeys-lib-expo

Native passkeys (WebAuthn) credential handler library for React Native and Expo apps.

## Installation

### Managed Expo Projects

```bash
npx expo install passkeys-lib-expo
```

### Bare React Native Projects

1. Install the package:

```bash
npm install passkeys-lib-expo
```

2. iOS Setup:

```bash
npx pod-install
```

3. Android Setup:
No additional setup required.

## Usage

```typescript
import CredentialHandlerModule, { 
  type CredentialHandlerModuleType,
  toBase64Url, 
} from "passkeys-lib-expo";

// Initialize
const credentialManager: CredentialHandlerModuleType = CredentialHandlerModule;

// Register a new passkey
const register = async () => {
  const result = await credentialManager.register({
    attestation: "none",
    challenge: toBase64Url("challenge"),
    rp: {
      id: "your-domain.com",
      name: "Your App"
    },
    user: {
      displayName: "User Name",
      id: toBase64Url("user-id"),
      name: "user@your-domain.com"
    },
    timeout: 60000
  });
};

// Authenticate with passkey
const authenticate = async () => {
  const result = await credentialManager.authenticate({
    challenge: toBase64Url("challenge"),
    timeout: 60000,
    userVerification: "required",
    rpId: "your-domain.com"
  });
};
```

## API Reference

### CredentialHandlerModule

#### Methods

##### `register(options: AttestationOptions<string>)`

Creates a new passkey credential.

```typescript
type AttestationOptions<T> = {
  challenge: T;
  rp: {
    id: string;
    name: string;
  };
  user: {
    id: T;
    name: string;
    displayName: string;
  };
  timeout?: number;
  attestation?: AttestationConveyancePreference;
  authenticatorSelection?: AuthenticatorSelectionCriteria;
  excludeCredentials?: PublicKeyCredentialDescriptor<T>[];
  preferImmediatelyAvailableCred?: boolean;
};
```

##### `authenticate(options: AssertionOptions<string>)`

Authenticates using an existing passkey.

```typescript
type AssertionOptions<T> = {
  challenge: T;
  rpId: string;
  timeout?: number;
  userVerification?: UserVerificationRequirement;
  allowCredentials?: PublicKeyCredentialDescriptor<T>[];
  preferImmediatelyAvailableCred?: boolean;
};
```

#### Events

access events via `CredentialHandlerModule.events`:

```typescript
// Registration Events
onRegistrationStarted: (callback: (event) => void) => void
onRegistrationComplete: (callback: (event) => void) => void
onRegistrationFailed: (callback: (event) => void) => void

// Authentication Events
onAuthenticationStarted: (callback: (event) => void) => void
onAuthenticationSuccess: (callback: (event) => void) => void
onAuthenticationFailed: (callback: (event) => void) => void
```

usage:

```typescript
CredentialHandlerModule.events.onRegistrationStarted((event) => {
  // do something when registration starts
});

CredentialHandlerModule.events.onRegistrationComplete((event) => {
// do something when registration is complete
})
```

#### Default Configuration

Access default settings via `CredentialHandlerModule.defaultConfiguration`:
> default configurations cannot be modified.

```typescript
{
  TIMEOUT: number;
  ATTESTATION: AttestationConveyancePreference;
  AUTHENTICATOR_ATTACHMENT: AuthenticatorAttachment;
  REQUIRE_RESIDENT_KEY: boolean;
  RESIDENT_KEY: ResidentKeyRequirement;
  USER_VERIFICATION: UserVerificationRequirement;
  PUB_KEY_CRED_PARAM: PublicKeyCredentialParameters;
}
```

## Utilities

The package includes utility functions for handling passkey data:

```typescript
import { toBase64Url, fromBase64Url, base64UrlToBuffer } from "passkeys-lib-expo";
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
