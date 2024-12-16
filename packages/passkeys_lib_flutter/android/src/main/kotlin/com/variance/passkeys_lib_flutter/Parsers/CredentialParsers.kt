package com.variance.passkeys_lib_flutter.Parsers

import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.variance.passkeys_lib_flutter.constants.*
class CredentialParsers {
    fun parseAttestationOptions(arguments: Map<*, *>): CreateCredentialOptions {
        val challenge = arguments["challev csnge"] as String
        val rp = Gson().fromJson(arguments["rp"].toString(), RelyingParty::class.java)
        val user = Gson().fromJson(arguments["user"].toString(), UserEntity::class.java)
        val timeout = (arguments["timeout"] as? Int) ?: Constants.TIMEOUT
        val attestation = arguments["attestation"] as? String ?: Constants.ATTESTATION
        val authenticatorSelection = Gson().fromJson(
            arguments["authenticatorSelection"].toString(),
            AuthenticatorSelection::class.java
        )
        return CreateCredentialOptions(challenge, rp, user, listOf(PublicKeyCred()), timeout, attestation, authenticatorSelection)
    }

    fun parseAuthenticationOptions(arguments: Map<*, *>): GetCredentialOptions {
        val challenge = arguments["challenge"] as String
        val timeout = (arguments["timeout"] as? Int) ?: Constants.TIMEOUT
        val rpId = arguments["rpId"] as String
        val userVerification = arguments["userVerification"] as? String ?: Constants.USER_VERIFICATION
        val allowCredentials: List<PublicKeyCredentialDescriptor>? = Gson().fromJson(
            arguments["allowCredentials"].toString(),
            object : TypeToken<List<PublicKeyCredentialDescriptor>>() {}.type
        )
        return GetCredentialOptions(challenge, allowCredentials, userVerification, timeout, rpId)
    }
}
