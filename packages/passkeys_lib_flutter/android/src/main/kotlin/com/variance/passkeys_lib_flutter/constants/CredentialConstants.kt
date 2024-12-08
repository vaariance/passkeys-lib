package com.variance.passkeys_lib_flutter.constants
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

object Constants {
    const val TIMEOUT = 60000
    const val ATTESTATION = "direct"
    const val AUTHENTICATOR_ATTACHMENT = "platform"
    const val REQUIRE_RESIDENT_KEY = true
    const val RESIDENT_KEY = "required"
    const val USER_VERIFICATION = "required"

    @JvmField
    val PUB_KEY_CRED_PARAM = mapOf("type" to "public-key", "alg" to -7)
}

@Serializable
data class RelyingParty(
    @SerialName("name")
    val name: String = "",
    @SerialName("id")
    val id: String = ""
)

@Serializable
data class UserEntity(
    @SerialName("id")
    val id: String = "",
    @SerialName("name")
    val name: String = "",
    @SerialName("displayName")
    val displayName: String = ""
)

@Serializable
data class AuthenticatorSelection(
    @SerialName("authenticatorAttachment")
    val authenticatorAttachment: String = Constants.AUTHENTICATOR_ATTACHMENT,
    @SerialName("requireResidentKey")
    val requireResidentKey: Boolean = Constants.REQUIRE_RESIDENT_KEY,
    @SerialName("userVerification")
    val userVerification: String = Constants.USER_VERIFICATION,
    @SerialName("residentKey")
    val residentKey: String = Constants.RESIDENT_KEY
)

@Serializable
data class PublicKeyCredentialDescriptor(
    @SerialName("type")
    val type: String = "public-key",
    @SerialName("id")
    val id: String = "",
    @SerialName("transports")
    val transports: List<String>? = null
)

@Serializable
data class PublicKeyCred(
    @SerialName("type")
    val type: String = "public-key",
    @SerialName("alg")
    val alg: Int = -7
)

@Serializable
data class CreateCredentialOptions(
    @SerialName("challenge")
    val challenge: String,
    @SerialName("relyingParty")
    val rp: RelyingParty,
    @SerialName("user")
    val user: UserEntity,
    @SerialName("pubKeyCredParams")
    val pubKeyCredParams: List<PublicKeyCred>,
    @SerialName("timeout")
    val timeout: Int? = Constants.TIMEOUT,
    @SerialName("attestation")
    val attestation: String? = Constants.ATTESTATION,
    @SerialName("authenticatorSelection")
    val authenticatorSelection: AuthenticatorSelection,
    @SerialName("excludeCredentials")
    val excludeCredentials: List<PublicKeyCredentialDescriptor>? = null
)

@Serializable
data class GetCredentialOptions(
    @SerialName("challenge")
    val challenge: String,
    @SerialName("allowCredentials")
    val allowCredentials: List<PublicKeyCredentialDescriptor>? = null,
    @SerialName("userVerification")
    val userVerification: String? = Constants.USER_VERIFICATION,
    @SerialName("timeout")
    val timeout: Int? = Constants.TIMEOUT,
    @SerialName("rpId")
    val rpId: String
)

@Serializable
