package com.variance.passkeys_lib_flutter

class CredentialHandlerModule : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null

    private lateinit var methodCallHandler: CredentialMethodCallHandler

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val credentialManager = CredentialManager.create(binding.applicationContext)
        val parser = CredentialParser()
        val operationManager = CredentialOperationManager(credentialManager)
        val errorHandler = ErrorHandler()

        methodCallHandler = CredentialMethodCallHandler(
            parser,
            operationManager,
            errorHandler
        ) { activity }

        channel = MethodChannel(binding.binaryMessenger, "credential_handler")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
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
}
