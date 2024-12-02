
package com.variance.passkeys_lib_flutter.handlers

import android.app.Activity
import com.google.gson.Gson
import com.variance.passkeys_lib_flutter.Manger.CredentialOperationManager
import com.variance.passkeys_lib_flutter.Parsers.CredentialParsers
import com.variance.passkeys_lib_flutter.Parsers.CredentialParser
import com.variance.passkeys_lib_flutter.constants.CredentialConstants
import com.variance.passkeys_lib_flutter.errors.ErrorHandler
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

class CredentialMethodCallHandler(
    private val parser: CredentialParser,
    private val operationManager: CredentialOperationManager,
    private val errorHandler: ErrorHandler,
    private val activityProvider: () -> Activity?
) {
    fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "register" -> handleRegister(call.arguments as Map<*, *>, result)
            "authenticate" -> handleAuthenticate(call.arguments as Map<*, *>, result)
            else -> result.notImplemented()
        }
    }

    private fun handleRegister(arguments: Map<*, *>, result: MethodChannel.Result) {
        val options = parser.parseAttestationOptions(arguments)
        CoroutineScope(Dispatchers.Main).launch {
            try {
                val activity = activityProvider() ?: throw IllegalStateException("Activity is not available")
                val response = operationManager.createCredential(activity, options)
                result.success(response)
            } catch (e: Exception) {
                result.error("ERROR", errorHandler.handleException(e)["message"], null)
            }
        }
    }

    private fun handleAuthenticate(arguments: Map<*, *>, result: MethodChannel.Result) {
        val options = parser.parseAuthenticationOptions(arguments)
        CoroutineScope(Dispatchers.Main).launch {
            try {
                val activity = activityProvider() ?: throw IllegalStateException("Activity is not available")
                val response = operationManager.getCredential(activity, options)
                result.success(response)
            } catch (e: Exception) {
                result.error("ERROR", errorHandler.handleException(e)["message"], null)
            }
        }
    }
}
