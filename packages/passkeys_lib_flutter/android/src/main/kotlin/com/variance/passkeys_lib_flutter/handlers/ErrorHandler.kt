package com.variance.passkeys_lib_flutter.handlers

import androidx.credentials.exceptions.CreateCredentialException
import androidx.credentials.exceptions.GetCredentialException

class ErrorHandler {
    fun handleException(e: Exception): Map<String, String> {
        return when (e) {
            is CreateCredentialException -> mapOf("error" to "Credential Error", "message" to e.localizedMessage)
            is GetCredentialException -> mapOf("error" to "Get Credential Error", "message" to e.localizedMessage)
            else -> mapOf("error" to "Unexpected Error", "message" to e.localizedMessage)
        }
    }
}
