import AuthenticationServices

@available(iOS 16.0, *)
class CredentialHandler: NSObject, ASAuthorizationControllerPresentationContextProviding,
    ASAuthorizationControllerDelegate
{
    // MARK: - Continuations for Async/Await
    private var kontinuation: CheckedContinuation<[String: Any], Error>?

    var authenticationAnchor: ASPresentationAnchor?

    // MARK: - Authentication Method
    func authenticate(
        getOptions: GetCredentialOptions,
        preferImmediatelyAvailableCredentials: Bool,
        anchor: ASPresentationAnchor?
    ) async throws -> [String: Any] {
        self.authenticationAnchor = anchor

        return try await withCheckedThrowingContinuation { continuation in
            self.kontinuation = continuation

            guard let challengeData = Data.fromBase64url(base64Data: getOptions.challenge) else {
                continuation.resume(
                    throwing: CustomErrors.base64UrlDecodingError(
                        reason: "challenge could not be decoded: Invalid base64url"))
                kontinuation = nil
                return
            }

            let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(
                relyingPartyIdentifier: getOptions.rpId)
            let request = provider.createCredentialAssertionRequest(challenge: challengeData)

            request.userVerificationPreference =
                ASAuthorizationPublicKeyCredentialUserVerificationPreference(
                    rawValue: getOptions.userVerification!)

            let cpProvider = ASAuthorizationSecurityKeyPublicKeyCredentialProvider(
                relyingPartyIdentifier: getOptions.rpId)
            let cpRequest = cpProvider.createCredentialAssertionRequest(challenge: challengeData)

            if let allowCredentials = getOptions.allowCredentials, !allowCredentials.isEmpty {
                request.allowedCredentials = parseCredentials(
                    from: allowCredentials,
                    descriptorType: ASAuthorizationPlatformPublicKeyCredentialDescriptor.self
                )
                cpRequest.allowedCredentials = parseCredentials(
                    from: allowCredentials,
                    descriptorType: ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.self
                )
            }

            let authController = ASAuthorizationController(authorizationRequests: [
                request, cpRequest,
            ])
            authController.delegate = self
            authController.presentationContextProvider = self

            if preferImmediatelyAvailableCredentials {
                authController.performRequests(options: .preferImmediatelyAvailableCredentials)
            } else {
                authController.performRequests()
            }
        }
    }

    // MARK: - Registration Method
    func register(
        createOptions: CreateCredentialOptions,
        preferImmediatelyAvailableCredentials: Bool,
        anchor: ASPresentationAnchor?
    ) async throws -> [String: Any] {
        self.authenticationAnchor = anchor

        return try await withCheckedThrowingContinuation { continuation in
            self.kontinuation = continuation

            guard let challengeData = Data.fromBase64url(base64Data: createOptions.challenge) else {
                continuation.resume(
                    throwing: CustomErrors.base64UrlDecodingError(
                        reason: "challenge could not be decoded: Invalid base64url"))
                kontinuation = nil
                return
            }

            guard let userIDData = Data.fromBase64url(base64Data: createOptions.user.id) else {
                continuation.resume(
                    throwing: CustomErrors.base64UrlDecodingError(
                        reason: "user.id could not be decoded: Invalid base64url"))
                kontinuation = nil
                return
            }

            @MainActor func getRequest() -> ASAuthorizationPublicKeyCredentialRegistrationRequest {
                if createOptions.authenticatorSelection.authenticatorAttachment
                    == Konstants.AUTHENTICATOR_ATTACHMENT
                {
                    // platfrom request
                    let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(
                        relyingPartyIdentifier: createOptions.rp.id)
                    let request = provider.createCredentialRegistrationRequest(
                        challenge: challengeData,
                        name: createOptions.user.name,
                        userID: userIDData
                    )

                    if let excludedCredentials = createOptions.excludeCredentials,
                        !excludedCredentials.isEmpty
                    {
                        if #available(iOS 17.4, *) {
                            request.excludedCredentials = parseCredentials(
                                from: excludedCredentials,
                                descriptorType: ASAuthorizationPlatformPublicKeyCredentialDescriptor
                                    .self
                            )
                        }
                    }

                    return request
                } else {
                    // cross platform request
                    let provider = ASAuthorizationSecurityKeyPublicKeyCredentialProvider(
                        relyingPartyIdentifier: createOptions.rp.id)
                    let request = provider.createCredentialRegistrationRequest(
                        challenge: challengeData,
                        displayName: createOptions.user.displayName,
                        name: createOptions.user.name,
                        userID: userIDData
                    )

                    request.residentKeyPreference =
                        ASAuthorizationPublicKeyCredentialResidentKeyPreference(
                            rawValue: createOptions.authenticatorSelection.residentKey)
                    request.credentialParameters = createOptions.pubKeyCredParams.map {
                        credParam in
                        ASAuthorizationPublicKeyCredentialParameters(
                            algorithm: ASCOSEAlgorithmIdentifier(credParam.alg))
                    }

                    if let excludedCredentials = createOptions.excludeCredentials,
                        !excludedCredentials.isEmpty
                    {
                        request.excludedCredentials = parseCredentials(
                            from: excludedCredentials,
                            descriptorType: ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor
                                .self
                        )
                    }

                    return request
                }
            }

            let request = getRequest()

            if let attestation = createOptions.attestation {
                request.attestationPreference = ASAuthorizationPublicKeyCredentialAttestationKind(
                    rawValue: attestation)
            }
            request.userVerificationPreference =
                ASAuthorizationPublicKeyCredentialUserVerificationPreference(
                    rawValue: createOptions.authenticatorSelection.userVerification)

            let authController = ASAuthorizationController(authorizationRequests: [
                request as! ASAuthorizationRequest
            ])
            authController.delegate = self
            authController.presentationContextProvider = self

            if preferImmediatelyAvailableCredentials {
                authController.performRequests(options: .preferImmediatelyAvailableCredentials)
            } else {
                authController.performRequests()
            }
        }
    }

    // MARK: - ASAuthorizationControllerDelegate Methods
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        switch authorization.credential {
        case let credentialRegistration as ASAuthorizationPlatformPublicKeyCredentialRegistration:
            let attestationObject = credentialRegistration.rawAttestationObject?.base64URLEncode()
            let clientDataJSON = credentialRegistration.rawClientDataJSON.base64URLEncode()
            let credentialId = credentialRegistration.credentialID.base64URLEncode()

            let response = [
                "attestationObject": attestationObject,
                "clientDataJSON": clientDataJSON,
            ]

            let payload =
                [
                    "rawId": credentialId,
                    "id": credentialId,
                    "type": "public-key",
                    "response": response,
                ] as [String: Any]

            kontinuation?.resume(returning: payload)
            kontinuation = nil
        case let credentialAssertion as ASAuthorizationPlatformPublicKeyCredentialAssertion:
            let signature = credentialAssertion.signature.base64URLEncode()
            let authenticatorData = credentialAssertion.rawAuthenticatorData.base64URLEncode()
            let userHandle = credentialAssertion.userID.base64URLEncode()
            let clientDataJSON = credentialAssertion.rawClientDataJSON.base64URLEncode()
            let credentialId = credentialAssertion.credentialID.base64URLEncode()

            let response = [
                "clientDataJSON": clientDataJSON,
                "authenticatorData": authenticatorData,
                "signature": signature,
                "userHandle": userHandle,
            ]

            let payload =
                [
                    "rawId": credentialId,
                    "id": credentialId,
                    "type": "public-key",
                    "response": response,
                ] as [String: Any]

            kontinuation?.resume(returning: payload)
            kontinuation = nil
        default:
            kontinuation?.resume(
                throwing: CustomErrors.unexpectedAuthorizationResponse(
                    credential: authorization.credential))
            kontinuation = nil
        }

    }

    func authorizationController(
        controller: ASAuthorizationController, didCompleteWithError error: Error
    ) {
        if let continuation = kontinuation {
            continuation.resume(throwing: error)
            kontinuation = nil
        }
    }

    // MARK: - ASAuthorizationControllerPresentationContextProviding
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let anchor = authenticationAnchor {
            return anchor
        } else {
            return ASPresentationAnchor()
        }
    }

    private func parseCredentials<T: ASAuthorizationPublicKeyCredentialDescriptor>(
        from credentials: [PublicKeyCredentialDescriptor],
        descriptorType: T.Type
    ) -> [T] {
        return credentials.compactMap { credential in
            guard let credentialID = Data.fromBase64url(base64Data: credential.id) else {
                return nil
            }

            if descriptorType == ASAuthorizationPlatformPublicKeyCredentialDescriptor.self {
                return ASAuthorizationPlatformPublicKeyCredentialDescriptor(
                    credentialID: credentialID) as? T
            } else if descriptorType == ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.self
            {
                let transports =
                    credential.transports?.compactMap { channel in
                        ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor.Transport(
                            rawValue: channel)
                    } ?? [.bluetooth, .nfc, .usb]
                return ASAuthorizationSecurityKeyPublicKeyCredentialDescriptor(
                    credentialID: credentialID, transports: transports) as? T
            } else {
                return nil
            }
        }
    }

}

// MARK: - Data Extensions
extension Data {
    func base64URLEncode() -> String {
        let base64 = self.base64EncodedString()
        let base64URL =
            base64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        return base64URL
    }

    static func fromBase64url(base64Data: String) -> Data? {
        var base64 =
            base64Data
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        if base64.count % 4 != 0 {
            base64.append(String(repeating: "=", count: 4 - base64.count % 4))
        }

        guard let data = Data(base64Encoded: base64) else {
            return nil
        }

        return data
    }
}

// MARK: - Custom Errors
enum CustomErrors: Error {
    case base64UrlDecodingError(reason: String)
    case unexpectedAuthorizationResponse(credential: ASAuthorizationCredential)
    case invalidState(state: String)
}
