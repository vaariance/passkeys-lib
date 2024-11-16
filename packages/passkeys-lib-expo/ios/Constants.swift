import ExpoModulesCore

class Konstants {
    static let TIMEOUT = 60000
    static let ATTESTATION = "direct"
    static let AUTHENTICATOR_ATTACHMENT = "platform"
    static let REQUIRE_RESIDENT_KEY = true
    static let RESIDENT_KEY = "required"
    static let USER_VERIFICATION = "required"
    static let PUB_KEY_CRED_PARAM: [String: Any] = [
        "type": "public-key",
        "alg": -7,
    ]
}

struct RelyingParty: Record {
    @Field
    var name: String = ""

    @Field
    var id: String = ""
}

struct UserEntity: Record {
    @Field
    var id: String = ""

    @Field
    var name: String = ""

    @Field
    var displayName: String = ""
}

struct AuthenticatorSelection: Record {
    @Field
    var authenticatorAttachment: String = Konstants.AUTHENTICATOR_ATTACHMENT

    @Field
    var requireResidentKey: Bool = Konstants.REQUIRE_RESIDENT_KEY

    @Field
    var residentKey: String = Konstants.RESIDENT_KEY

    @Field
    var userVerification: String = Konstants.USER_VERIFICATION
}

struct PublicKeyCredentialDescriptor: Record {
    @Field
    var id: String = ""

    @Field
    var type: String = "public-key"

    @Field
    var transports: [String]? = nil
}

struct ExclusiveCredentials: Record {
    @Field
    var items: [PublicKeyCredentialDescriptor] = []
}

struct PublicKeyCred: Record {
    @Field
    var type: String = Konstants.PUB_KEY_CRED_PARAM["type"] as! String

    @Field
    var alg: Int = Konstants.PUB_KEY_CRED_PARAM["alg"] as! Int
}

struct CreateCredentialOptions {
    var challenge: String

    var rp: RelyingParty

    var user: UserEntity

    var pubKeyCredParams: [PublicKeyCred]

    var timeout: Int?

    var attestation: String?

    var authenticatorSelection: AuthenticatorSelection

    var excludeCredentials: [PublicKeyCredentialDescriptor]?

    init(
        challenge: String,
        rp: RelyingParty,
        user: UserEntity,
        pubKeyCredParams: [PublicKeyCred],
        timeout: Int?,
        attestation: String?,
        authenticatorSelection: AuthenticatorSelection,
        excludeCredentials: [PublicKeyCredentialDescriptor]?
    ) {
        self.challenge = challenge
        self.rp = rp
        self.user = user
        self.pubKeyCredParams = pubKeyCredParams
        self.timeout = timeout
        self.attestation = attestation
        self.authenticatorSelection = authenticatorSelection
        self.excludeCredentials = excludeCredentials
    }

    func toDictionary() -> [String: Any] {
        return [
            "challenge": challenge,
            "rp": rp.toDictionary(),
            "user": user.toDictionary(),
            "pubKeyCredParams": pubKeyCredParams.compactMap {
                element in element.toDictionary()
            },
            "timeout": timeout ?? Konstants.TIMEOUT,
            "attestation": attestation ?? Konstants.ATTESTATION,
            "authenticatorSelection": authenticatorSelection.toDictionary(),
            "excludeCredentials": excludeCredentials?.compactMap {
                element in element.toDictionary()
            } ?? [],
        ]
    }

    func toString() -> String {
        if let payloadJSONData = try? JSONSerialization.data(
            withJSONObject: toDictionary(), options: .fragmentsAllowed)
        {
            guard let payloadJSONText = String(data: payloadJSONData, encoding: .utf8) else {
                return ""
            }
            return payloadJSONText
        }
        return ""
    }
}

struct GetCredentialOptions {
    var challenge: String

    var allowCredentials: [PublicKeyCredentialDescriptor]?

    var userVerification: String?

    var timeout: Int?

    var rpId: String

    init(
        challenge: String,
        allowCredentials: [PublicKeyCredentialDescriptor]?,
        userVerification: String?,
        timeout: Int?,
        rpId: String
    ) {
        self.challenge = challenge
        self.allowCredentials = allowCredentials
        self.userVerification = userVerification
        self.timeout = timeout
        self.rpId = rpId
    }

    func toDictionary() -> [String: Any] {
        return [
            "challenge": challenge,
            "allowCredentials": allowCredentials?.compactMap {
                element in element.toDictionary()
            } ?? [],
            "userVerification": userVerification ?? Konstants.USER_VERIFICATION,
            "timeout": timeout ?? Konstants.TIMEOUT,
            "rpId": rpId,
        ]
    }

    func toString() -> String {
        if let payloadJSONData = try? JSONSerialization.data(
            withJSONObject: toDictionary(), options: .fragmentsAllowed)
        {
            guard let payloadJSONText = String(data: payloadJSONData, encoding: .utf8) else {
                return ""
            }
            return payloadJSONText
        }
        return ""
    }
}
