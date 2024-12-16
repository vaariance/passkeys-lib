package com.variance.passkeys_lib_flutter.Manger

import com.variance.passkeys_lib_flutter.constants.*
import com.variance.passkeys_lib_flutter.handlers.*
import android.app.Activity
import androidx.credentials.GetPublicKeyCredentialOption
import androidx.credentials.GetCredentialResponse
import androidx.credentials.CredentialManager
import androidx.credentials.CreateCredentialResponse
import androidx.credentials.CreatePublicKeyCredentialRequest
import androidx.credentials.PublicKeyCredential
import androidx.credentials.GetCredentialRequest
import com.google.gson.Gson

class CredentialOperationManager(private val credentialManager: CredentialManager, private val eventEmitter: (Map<String, Any?>) -> Unit) {

    private fun emitEvent(eventName: String, status: String, data: Map<String, Any?>?=null, errorMessage: String?=null) {
        val event = mapOf("event" to eventName, "status" to status, "data" to data, "errorMessage" to errorMessage)
        eventEmitter.invoke(event)
    }
    suspend fun createCredential(activity: Activity, options: CreateCredentialOptions): CreateCredentialResponse {

        try {
            val request = CreatePublicKeyCredentialRequest(Gson().toJson(options))
            val credentialResponse = credentialManager.createCredential(activity, request)
//            val credentialId = (credentialResponse.credential as PublicKeyCredential).id
            emitEvent(
                "credentialCreationStarted",
                "success",
                mapOf("credential" to credentialResponse),
                null
            )
            return credentialResponse
        } catch (e: Exception) {
            emitEvent(
                "credentialCreationFailed",
                "error",
                null,
                e.localizedMessage
            )

            throw e
        }

    }

    suspend fun getCredential(activity: Activity, options: GetCredentialOptions): GetCredentialResponse {
       try {
           val request = GetPublicKeyCredentialOption(Gson().toJson(options))
           val credentialRequest = GetCredentialRequest(listOf(request))
           val response = credentialManager.getCredential(activity, credentialRequest)
           emitEvent(
               "credentialRetrievalStarted",
               "success",
               mapOf("credential" to response.credential),
               null

           )
           return response
       } catch (e: Exception){
           emitEvent(
               "credentialRetrievalFailed",
               "error",
               null,
               e.localizedMessage
           )

        throw e
       }

    }
}
