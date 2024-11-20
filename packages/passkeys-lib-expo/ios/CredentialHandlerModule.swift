import ExpoModulesCore
import AuthenticationServices

@available(iOS 16.0, *)
public class CredentialHandlerModule: Module {

  // MARK: - Properties
  private var credentialManager: CredentialManager?

  public func definition() -> ModuleDefinition {

    Name("CredentialHandler")

    OnCreate {
      self.credentialManager = CredentialManager()
    }

    Constants([
      "TIMEOUT": Konstants.TIMEOUT,
      "ATTESTATION": Konstants.ATTESTATION,
      "AUTHENTICATOR_ATTACHMENT": Konstants.AUTHENTICATOR_ATTACHMENT,
      "REQUIRE_RESIDENT_KEY": Konstants.REQUIRE_RESIDENT_KEY,
      "RESIDENT_KEY": Konstants.RESIDENT_KEY,
      "USER_VERIFICATION": Konstants.USER_VERIFICATION,
      "PUB_KEY_CRED_PARAM": Konstants.PUB_KEY_CRED_PARAM,
    ])

    Events(
      "onRegistrationStarted",
      "onRegistrationFailed",
      "onRegistrationComplete",
      "onAuthenticationStarted",
      "onAuthenticationFailed",
      "onAuthenticationSuccess"
    )

    AsyncFunction("authenticate") {
      (
        prefersImmediatelyAvailableCred: Bool,
        challenge: String,
        timeout: Int?,
        rpId: String,
        userVerification: String?,
        allowCredentials: ExclusiveCredentials?
      ) in

      let getOptions = self.parseAssertionOptions(
        challenge: challenge,
        allowCredentials: allowCredentials,
        timeout: timeout,
        rpId: rpId,
        userVerification: userVerification
      )

      return try await authenticate(
        getOptions: getOptions, prefersImmediatelyAvailableCred: prefersImmediatelyAvailableCred)
    }

    AsyncFunction("register") {
      (
        prefersImmediatelyAvailableCred: Bool,
        challenge: String,
        rp: RelyingParty,
        user: UserEntity,
        timeout: Int?,
        attestation: String?,
        excludeCredentials: ExclusiveCredentials?,
        authenticatorSelection: AuthenticatorSelection?
      ) in

      let createOptions = self.parseAttestationOptions(
        challenge: challenge,
        rp: rp,
        user: user,
        timeout: timeout,
        attestation: attestation,
        excludeCredentials: excludeCredentials,
        authenticatorSelection: authenticatorSelection
      )

      return try await register(
        createOptions: createOptions,
        prefersImmediatelyAvailableCred: prefersImmediatelyAvailableCred)
    }
  }

  // MARK: - Helper Methods
  private func parseAssertionOptions(
    challenge: String,
    allowCredentials: ExclusiveCredentials?,
    timeout: Int?,
    rpId: String,
    userVerification: String?
  ) -> GetCredentialOptions {
    return GetCredentialOptions(
      challenge: challenge,
      allowCredentials: allowCredentials?.items,
      userVerification: userVerification ?? Konstants.USER_VERIFICATION,
      timeout: timeout ?? Konstants.TIMEOUT,
      rpId: rpId
    )
  }

  private func parseAttestationOptions(
    challenge: String,
    rp: RelyingParty,
    user: UserEntity,
    timeout: Int?,
    attestation: String?,
    excludeCredentials: ExclusiveCredentials?,
    authenticatorSelection: AuthenticatorSelection?
  ) -> CreateCredentialOptions {
    return CreateCredentialOptions(
      challenge: challenge,
      rp: rp,
      user: user,
      pubKeyCredParams: [PublicKeyCred()],
      timeout: timeout ?? Konstants.TIMEOUT,
      attestation: attestation ?? Konstants.ATTESTATION,
      authenticatorSelection: authenticatorSelection ?? AuthenticatorSelection(),
      excludeCredentials: excludeCredentials?.items
    )
  }

  // MARK: - Authentication Methods
  private func authenticate(getOptions: GetCredentialOptions, prefersImmediatelyAvailableCred: Bool)
    async throws -> [String: Any]?
  {
    self.sendEvent("onAuthenticationStarted", ["request": getOptions.toString()])

    do {
      let uiAnchor = await MainActor.run {
        UIApplication.shared.windows.first { $0.isKeyWindow }
      }
      guard let credentialManager = self.credentialManager else {
        throw CustomErrors.invalidState(state: "Credential manager is not initialized")
      }
      let result = try await credentialManager.authenticate(
        getOptions: getOptions,
        preferImmediatelyAvailableCredentials: prefersImmediatelyAvailableCred,
        anchor: uiAnchor)
      self.sendEvent("onAuthenticationSuccess", result)
      return result
    } catch {
      handleAssertionFailure(error: error)
      throw error
    }
  }

  private func register(
    createOptions: CreateCredentialOptions, prefersImmediatelyAvailableCred: Bool
  ) async throws -> [String: Any]? {
    self.sendEvent("onRegistrationStarted", ["request": createOptions.toString()])
    do {
      let uiAnchor = await MainActor.run {
        UIApplication.shared.windows.first { $0.isKeyWindow }
      }
      guard let credentialManager = self.credentialManager else {
        throw CustomErrors.invalidState(state: "Credential manager is not initialized")
      }
      let result = try await credentialManager.register(
        createOptions: createOptions,
        preferImmediatelyAvailableCredentials: prefersImmediatelyAvailableCred,
        anchor: uiAnchor)
      self.sendEvent("onRegistrationComplete", result)
      return result
    } catch {
      handleAttestationFailure(error: error)
      throw error
    }
  }

  // MARK: - Error Handling
  private func handleAssertionFailure(error: Error) {
    var response = ["error": "Unexpected exception", "message": error.localizedDescription]
    if let authError = error as? ASAuthorizationError {
      response["error"] = mapASAuthorizationError(authError)
    }
    self.sendEvent("onAuthenticationFailed", response)
  }

  private func handleAttestationFailure(error: Error) {
    var response = ["error": "Unexpected exception", "message": error.localizedDescription]
    if let authError = error as? ASAuthorizationError {
      response["error"] = mapASAuthorizationError(authError)
    }
    self.sendEvent("onRegistrationFailed", response)
  }

  private func mapASAuthorizationError(_ error: ASAuthorizationError) -> String {
    switch error.code {
    case .canceled:
      return "User canceled the request"
    case .unknown:
      return "An unknown error occurred"
    case .invalidResponse:
      return "Invalid response received"
    case .notHandled:
      return "Request was not handled"
    case .failed:
      return "Authorization failed"
    case .notInteractive:
      return "The operation requires user interaction"
    case .matchedExcludedCredential:
      return "The attempted credential was excluded"
    @unknown default:
      return "Unknown error occurred"
    }
  }
}
