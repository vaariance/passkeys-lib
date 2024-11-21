package com.variance.passkeys_flutter

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import androidx.credentials.CreateCredentialResponse
import androidx.credentials.CreatePublicKeyCredentialRequest
import androidx.credentials.CreatePublicKeyCredentialResponse
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
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import android.util.Base64
import android.util.Log





class CredentialHandlerModule : FlutterPlugin, MethodCallHandler, ActivityAware {

  private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private lateinit var credentialManager: CredentialManager

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "credential_handler")
        channel.setMethodCallHandler(this)
        credentialManager = CredentialManager.create(binding.applicationContext)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "register" -> {
                val arguments = call.arguments as Map<*, *>
                Log.d("CredentialHandler", "arguments: $arguments")
               val options = parseAttestationOptions(
                    challenge = arguments["challenge"] as String,
                    rp = Gson().fromJson(arguments["rp"].toString(), RelyingParty::class.java),
                    user = Gson().fromJson(arguments["user"].toString(), UserEntity::class.java),
                    timeout = arguments["timeout"] as String,
                    attestation = arguments["attestation"] as? String,
                    authenticatorSelection = Gson().fromJson(arguments["authenticatorSelection"].toString(), AuthenticatorSelection::class.java)
                )
                register(options, result)
            }
            "authenticate" -> {
                val arguments = call.arguments as Map<*, *>
                authenticate(arguments, result)
            }
            else -> result.notImplemented()
        }
    }

    private fun parseAttestationOptions(
        challenge: String,
        rp: RelyingParty,
        user: UserEntity,
        timeout: Int?,
        attestation: String?,
        authenticatorSelection: AuthenticatorSelection?
    ): CreateCredentialOptions {
        return CreateCredentialOptions(
            challenge = challenge,
            rp = rp,
            user = user,
            pubKeyCredParams = listOf(PublicKeyCred()),
            timeout = timeout ?: Constants.TIMEOUT,
            attestation = attestation ?: Constants.ATTESTATION,
            authenticatorSelection = authenticatorSelection ?: AuthenticationSelection::class.javaObjectInstance
        )
    }

    private fun register(request: CreateCredentialOptions, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.Main).launch {
            try {
                val currentActivity = activity ?: throw IllegalStateException("Activity is not available")
                val publicKeyCredentialRequest = CreatePublicKeyCredentialRequest(Gson().toJson(request))
                val response = credentialManager.createCredential(currentActivity, publicKeyCredentialRequest)
                result.success(handleAttestationResult(response))
            } catch (e: CreateCredentialException) {
                result.error("ERROR", e.message ?: "Unknown error", null)
            }
        }
    }


private fun authenticate(arguments: Map<*, *>, result: MethodChannel.Result) {
        val challenge = arguments["challenge"] as String
        val timeout = (arguments["timeout"] as? Int) ?: Constants.TIMEOUT
        val rpId = arguments["rpId"] as String
        val userVerification = arguments["userVerification"] as? String ?: Constants.USER_VERIFICATION
        val allowCredentials: List<PublicKeyCredentialDescriptor>? = Gson().fromJson(
            arguments["allowCredentials"].toString(),
            object : TypeToken<List<PublicKeyCredentialDescriptor>>() {}.type
        )

        val getOptions = GetCredentialOptions(
            challenge = challenge,
            allowCredentials = allowCredentials,
            timeout = timeout,
            rpId = rpId,
            userVerification = userVerification
        )

        CoroutineScope(Dispatchers.Main).launch {
            try {
                val currentActivity = activity ?: throw IllegalStateException("Activity is not available")
                val request = GetPublicKeyCredentialOption(Gson().toJson(getOptions))
                val credentialRequest = GetCredentialRequest(listOf(request))
                val response = credentialManager.getCredential(currentActivity, credentialRequest)
                result.success(handleAssertionResult(response))
            } catch (e: GetCredentialException) {
                result.error("ERROR", e.localizedMessage, handleAssertionFailure(e))
            }
        }
    }
    
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    private fun handleAttestationResult(result: CreateCredentialResponse?): Map<String, Any?>? {
        return when (result) {
            is CreatePublicKeyCredentialResponse -> {
                val type = object : TypeToken<Map<String, Any>>() {}.type
                Gson().fromJson<Map<String, Any?>>(result.registrationResponseJson, type)
            }
            else -> mapOf("error" to "Unknown credential type: ${result?.type}")
        }
    }

  private fun handleAttestationFailure(e: CreateCredentialException): Map<String, String> {
    return when (e) {
      is CreatePublicKeyCredentialDomException -> mapOf("error" to "Webauthn Error", "message" to e.domError.toString())
      is CreateCredentialCancellationException -> mapOf("error" to "User cancelled the request")
      is CreateCredentialInterruptedException -> mapOf("error" to "Registration interrupted, please retry!")
      is CreateCredentialProviderConfigurationException -> mapOf(
        "error" to "Configuration Error",
        "message" to "Check if credentials-play-services-auth module is installed"
      )
      is CreateCredentialUnknownException -> mapOf("error" to "Unknown error occurred")
      is CreateCredentialCustomException -> mapOf("error" to "Third-party integration error")
      else -> mapOf("error" to "Unexpected error", "message" to e.localizedMessage)
    }
  }

  private fun handleAssertionResult(result: GetCredentialResponse?): Map<String, Any?>? {
    return when (val credential = result?.credential) {
        is PublicKeyCredential -> {
            val type = object : TypeToken<Map<String, Any>>() {}.type
            Gson().fromJson(credential.authenticationResponseJson, type)
        }
        else -> mapOf("error" to "Unknown credential type: ${credential?.type}")
    }
}


  private fun handleAssertionFailure(e: GetCredentialException): Map<String, String> {
    return when (e) {
      is GetPublicKeyCredentialDomException -> mapOf("error" to "Webauthn Error", "message" to e.domError.toString())
      is GetCredentialCancellationException -> mapOf("error" to "User cancelled the request")
      is GetCredentialInterruptedException -> mapOf("error" to "Authentication interrupted, please retry!")
      is GetCredentialProviderConfigurationException -> mapOf(
        "error" to "Configuration Error",
        "message" to "Check if credentials-play-services-auth module is installed"
      )
      is GetCredentialUnknownException -> mapOf("error" to "Unknown error occurred")
      is GetCredentialCustomException -> mapOf("error" to "Third-party integration error")
      else -> mapOf("error" to "Unexpected error", "message" to e.localizedMessage)
    }
  }
}