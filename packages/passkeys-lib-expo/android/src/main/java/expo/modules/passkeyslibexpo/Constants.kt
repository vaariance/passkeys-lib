package expo.modules.passkeyslibexpo

import expo.modules.kotlin.records.Field
import expo.modules.kotlin.records.Record

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

class RelyingParty : Record {
  @Field
  val name: String = ""

  @Field
  val id: String = ""
}

class UserEntity : Record {
  @Field
  val id: String = ""

  @Field
  val name: String = ""

  @Field
  val displayName: String = ""
}

class AuthenticatorSelection : Record {
  @Field
  val authenticatorAttachment: String = Constants.AUTHENTICATOR_ATTACHMENT

  @Field
  val requireResidentKey: Boolean = Constants.REQUIRE_RESIDENT_KEY

  @Field
  val residentKey: String = Constants.RESIDENT_KEY

  @Field
  val userVerification: String = Constants.USER_VERIFICATION
}

class PublicKeyCredentialDescriptor : Record {
  @Field
  val id: String = ""

  @Field
  val type: String = "public-key"

  @Field
  val transports: List<String>? = null
}

class ExclusiveCredentials : Record {
  @Field
  val items: List<PublicKeyCredentialDescriptor> = listOf()
}

class PublicKeyCred : Record {
  @Field
  val type: String = Constants.PUB_KEY_CRED_PARAM["type"] as String

  @Field
  val alg: Int = Constants.PUB_KEY_CRED_PARAM["alg"] as Int
}

data class CreateCredentialOptions(
  val challenge: String,

  val rp: RelyingParty,

  val user: UserEntity,

  val pubKeyCredParams: List<PublicKeyCred>,

  val timeout: Int?,

  val attestation: String?,

  val authenticatorSelection: AuthenticatorSelection,

  val excludeCredentials: List<PublicKeyCredentialDescriptor>?
)

data class GetCredentialOptions(
  val challenge: String,

  val allowCredentials: List<PublicKeyCredentialDescriptor>?,

  val userVerification: String?,

  val timeout: Int?,

  val rpId: String
)