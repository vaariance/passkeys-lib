package com.variance.passkeys_lib_flutter

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import androidx.credentials.CredentialManager
import com.variance.passkeys_lib_flutter.handlers.CredentialMethodCallHandler
import com.variance.passkeys_lib_flutter.Parsers.CredentialParsers
import com.variance.passkeys_lib_flutter.Manger.CredentialOperationManager
import com.variance.passkeys_lib_flutter.handlers.ErrorHandler



class PasskeysLibFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var activity: Activity? = null

    private lateinit var methodCallHandler: CredentialMethodCallHandler
    private var eventSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val credentialManager = CredentialManager.create(binding.applicationContext)
        val parser = CredentialParsers()
        val operationManager = CredentialOperationManager(credentialManager, eventEmitter = { event: Map<String, Any?> ->
            sendEvent(event as Map<String, Any>)
        })
        val errorHandler = ErrorHandler()

        methodCallHandler = CredentialMethodCallHandler(
            parser,
            operationManager,
            errorHandler
        ) { activity }

        channel = MethodChannel(binding.binaryMessenger, "passkeys_lib_flutter")
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "credential_handler/events")
        eventChannel.setStreamHandler(object: EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
                this@PasskeysLibFlutterPlugin.eventSink = eventSink
            }

            override fun onCancel(arguments: Any?) {
                this@PasskeysLibFlutterPlugin.eventSink = null
            }
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        methodCallHandler.handleMethodCall(call, result)
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

    fun sendEvent(event: Map<String, Any>) {
        if (eventSink != null) {
            eventSink?.success(event)
        } else {
            // Optionally, log or handle the case where no listener is active
            println("No active event listener to receive the event.")
        }
    }
}