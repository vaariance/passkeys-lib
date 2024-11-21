package com.variance.passkeys_flutter

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

class PasskeysFlutterPlugin : FlutterPlugin, ActivityAware {
    private lateinit var channel: MethodChannel
    private val credentialHandler = CredentialHandlerModule()

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "passkeys_flutter")
        channel.setMethodCallHandler(credentialHandler)
        credentialHandler.onAttachedToEngine(binding)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        credentialHandler.onDetachedFromEngine(binding)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        credentialHandler.onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        credentialHandler.onDetachedFromActivityForConfigChanges()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        credentialHandler.onReattachedToActivityForConfigChanges(binding)
    }

    override fun onDetachedFromActivity() {
        credentialHandler.onDetachedFromActivity()
    }
}
