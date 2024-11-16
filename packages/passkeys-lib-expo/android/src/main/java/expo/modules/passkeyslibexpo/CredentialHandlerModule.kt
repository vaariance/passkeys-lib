package expo.modules.passkeyslibexpo

import androidx.credentials.CreateCredentialResponse
import androidx.credentials.CreatePublicKeyCredentialRequest
import androidx.credentials.CreatePublicKeyCredentialResponse
import androidx.credentials.Credential
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetCredentialResponse
import androidx.credentials.GetPublicKeyCredentialOption
import androidx.credentials.PublicKeyCredential
import androidx.credentials.exceptions.CreateCredentialCancellationException
import androidx.credentials.exceptions.CreateCredentialCustomException
import androidx.credentials.exceptions.CreateCredentialException
import androidx.credentials.exceptions.CreateCredentialInterruptedException
import androidx.credentials.exceptions.CreateCredentialProviderConfigurationException
import androidx.credentials.exceptions.CreateCredentialUnknownException
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.GetCredentialCustomException
import androidx.credentials.exceptions.GetCredentialException
import androidx.credentials.exceptions.GetCredentialInterruptedException
import androidx.credentials.exceptions.GetCredentialProviderConfigurationException
import androidx.credentials.exceptions.GetCredentialUnknownException
import androidx.credentials.exceptions.publickeycredential.CreatePublicKeyCredentialDomException
import androidx.credentials.exceptions.publickeycredential.GetPublicKeyCredentialDomException
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

import expo.modules.kotlin.functions.Coroutine
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition


class CredentialHandlerModule : Module() {
  private lateinit var credentialManager: CredentialManager

  override fun definition() = ModuleDefinition {
    Name("CredentialHandler")

    OnCreate {
      credentialManager = CredentialManager.create(appContext.reactContext!!)
    }

    Constants(
      "TIMEOUT" to Constants.TIMEOUT,
      "ATTESTATION" to Constants.ATTESTATION,
      "AUTHENTICATOR_ATTACHMENT" to Constants.AUTHENTICATOR_ATTACHMENT,
      "REQUIRE_RESIDENT_KEY" to Constants.REQUIRE_RESIDENT_KEY,
      "RESIDENT_KEY" to Constants.RESIDENT_KEY,
      "USER_VERIFICATION" to Constants.USER_VERIFICATION,
      "PUB_KEY_CRED_PARAM" to Constants.PUB_KEY_CRED_PARAM
    )

    Events(
      "onRegistrationStarted",
      "onRegistrationFailed",
      "onRegistrationComplete",
      "onAuthenticationStarted",
      "onAuthenticationFailed",
      "onAuthenticationSuccess"
    )

    AsyncFunction("authenticate") Coroutine {
        prefersImmediatelyAvailableCred: Boolean,
        challenge: String,
        timeout: Int?,
        rpId: String,
        userVerification: String?,
        allowCredentials: ExclusiveCredentials?
      ->

      val getOptions = parseAssertionOptions(
        challenge,
        allowCredentials,
        timeout,
        rpId,
        userVerification
      )
      val getPublicKeyCredentialOption = GetPublicKeyCredentialOption(
        requestJson = Gson().toJson(getOptions))
      val getCredRequest = GetCredentialRequest(
        listOf(getPublicKeyCredentialOption),
        preferImmediatelyAvailableCredentials = prefersImmediatelyAvailableCred)
      return@Coroutine authenticate(getCredRequest)
    }

    AsyncFunction("register") Coroutine {
        prefersImmediatelyAvailableCred: Boolean,
        challenge: String,
        rp: RelyingParty,
        user: UserEntity,
        timeout: Int?,
        attestation: String?,
        excludeCredentials: ExclusiveCredentials?,
        authenticatorSelection: AuthenticatorSelection?
      ->

      val createOptions = parseAttestationOptions(
        challenge,
        rp,
        user,
        timeout,
        attestation,
        excludeCredentials,
        authenticatorSelection
      )
      val createPublicKeyCredentialRequest = CreatePublicKeyCredentialRequest(
        requestJson = Gson().toJson(createOptions),
        preferImmediatelyAvailableCredentials = prefersImmediatelyAvailableCred,
      )
      return@Coroutine register(createPublicKeyCredentialRequest)
    }
  }

  private fun parseAssertionOptions(
    challenge: String,
    allowCredentials: ExclusiveCredentials?,
    timeout: Int?,
    rpId: String,
    userVerification: String?
  ): GetCredentialOptions {
    return GetCredentialOptions(
      challenge = challenge,
      allowCredentials = allowCredentials?.items,
      timeout = timeout ?: Constants.TIMEOUT,
      rpId = rpId,
      userVerification = userVerification ?: Constants.USER_VERIFICATION
    )
  }

  private fun parseAttestationOptions(
    challenge: String,
    rp: RelyingParty,
    user: UserEntity,
    timeout: Int?,
    attestation: String?,
    excludeCredentials: ExclusiveCredentials?,
    authenticatorSelection: AuthenticatorSelection?
  ): CreateCredentialOptions {
    return CreateCredentialOptions(
      challenge = challenge,
      rp = rp,
      user = user,
      pubKeyCredParams = listOf(PublicKeyCred()),
      timeout = timeout ?: Constants.TIMEOUT,
      attestation = attestation ?: Constants.ATTESTATION,
      excludeCredentials = excludeCredentials?.items,
      authenticatorSelection = authenticatorSelection ?: AuthenticatorSelection()
    )
  }

  private suspend fun register(
    request: CreatePublicKeyCredentialRequest
  ): Map<String, Any?>? {
    return try {
      sendEvent("onRegistrationStarted", mapOf("request" to request.requestJson))
      val result = appContext.currentActivity?.let {
        credentialManager.createCredential(
          context = it,
          request = request,
        )
      }
      handleAttestationResult(result)
    } catch (e: CreateCredentialException) {
      handleAttestationFailure(e)
      throw e
    }
  }

  private fun handleAttestationResult(result: CreateCredentialResponse?): Map<String, Any?>? {
    return when (result) {
      is CreatePublicKeyCredentialResponse -> {
        val attestation = result.registrationResponseJson
        val type = object : TypeToken<Map<String, Any>>() {}.type
        val data: Map<String, Any> = attestation.let { Gson().fromJson(it, type) }
        sendEvent("onRegistrationComplete", data)
        data
      }

      else -> {
        val response = mapOf("error" to "Unknown credential type: ${result?.type}")
        sendEvent("onRegistrationFailed", response)
        null
      }
    }
  }

  private fun handleAttestationFailure(e: CreateCredentialException) {
    val response =
      mutableMapOf(
        "error" to "Unexpected exception type ${e::class.java.name}",
        "message" to e.localizedMessage
      )
    when (e) {
      is CreatePublicKeyCredentialDomException -> {
        response["error"] = "Webauthn Error"
        response["message"] = e.domError.toString()
      }

      is CreateCredentialCancellationException -> {
        response["error"] = "User cancelled the request"
      }

      is CreateCredentialInterruptedException -> {
        response["error"] = "Registration did not complete, please retry!"
      }

      is CreateCredentialProviderConfigurationException -> {
        response["error"] =
          "Credential provider configuration error: is credentials-play-services-auth module installed?"
      }

      is CreateCredentialUnknownException -> {
        response["error"] = "An Unknown Error Occurred"
      }

      is CreateCredentialCustomException -> {
        response["error"] = "Error was encountered from a third-party integration"
      }
    }

    sendEvent(
      "onRegistrationFailed", response
    )
  }

  private suspend fun authenticate(request: GetCredentialRequest): Map<String, Any?>? {
    return try {
      sendEvent("onAuthenticationStarted", mapOf("request" to request.toString()))
      val result = appContext.currentActivity?.let {
        credentialManager.getCredential(
          context = it,
          request = request
        )
      }
      handleAssertionResult(result)
    } catch (e: GetCredentialException) {
      handleAssertionFailure(e)
      throw e
    }
  }

  private fun handleAssertionResult(result: GetCredentialResponse?): Map<String, Any?>? {
    return when (val credential: Credential? = result?.credential) {
      is PublicKeyCredential -> {
        val assertion = credential.authenticationResponseJson
        val type = object : TypeToken<Map<String, Any>>() {}.type
        val data: Map<String, Any> = assertion.let { Gson().fromJson(it, type) }
        sendEvent("onAuthenticationSuccess", data)
        data
      }

      else -> {
        val response = mapOf("error" to "Unknown credential type: ${credential?.type}")
        sendEvent("onAuthenticationFailed", response)
        null
      }
    }
  }

  private fun handleAssertionFailure(e: GetCredentialException) {
    val response =
      mutableMapOf(
        "error" to "Unexpected exception: ${e::class.java.name}",
        "message" to e.localizedMessage
      )
    when (e) {
      is GetPublicKeyCredentialDomException -> {
        response["error"] = "Webauthn Error"
        response["message"] = e.domError.toString()
      }

      is GetCredentialCancellationException -> {
        response["error"] = "User cancelled the request"
      }

      is GetCredentialInterruptedException -> {
        response["error"] = "Authentication did not complete, please retry!"
      }

      is GetCredentialProviderConfigurationException -> {
        response["error"] =
          "Credential provider configuration error: is credentials-play-services-auth module installed?"
      }

      is GetCredentialUnknownException -> {
        response["error"] = "An Unknown Error Occurred"
      }

      is GetCredentialCustomException -> {
        response["error"] = "Error was encountered from a third-party integration"
      }
    }

    sendEvent(
      "onAuthenticationFailed", response
    )
  }
}