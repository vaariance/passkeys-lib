package com.variance.passkeys_lib_flutter.Manger

import com.variance.passkeys_lib_flutter.constants.CredentialConstants
import android.app.Activity
import androidx.credentials.GetPublicKeyCredentialOption
import androidx.credentials.GetCredentialResponse
import androidx.credentials.CredentialManager
import androidx.credentials.CreateCredentialResponse
import androidx.credentials.CreatePublicKeyCredentialRequest
import androidx.credentials.GetCredentialRequest
import com.google.gson.Gson

class CredentialOperationManager(private val credentialManager: CredentialManager) {
    suspend fun createCredential(activity: Activity, options: CreateCredentialOptions): CreateCredentialResponse {
        val request = CreatePublicKeyCredentialRequest(Gson().toJson(options))
        return credentialManager.createCredential(activity, request)
    }

    suspend fun getCredential(activity: Activity, options: GetCredentialOptions): GetCredentialResponse {
        val request = GetPublicKeyCredentialOption(Gson().toJson(options))
        val credentialRequest = GetCredentialRequest(listOf(request))
        return credentialManager.getCredential(activity, credentialRequest)
    }
}
