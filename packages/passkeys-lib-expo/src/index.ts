// Reexport the native module. On web, it will be resolved to CredentialHandlerModule.web.ts
// and on native platforms to CredentialHandlerModule.ts
export { default } from "./CredentialHandlerModule";

export { type CredentialHandlerModuleType } from "./CredentialHandler.types";
