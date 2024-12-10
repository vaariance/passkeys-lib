package com.variance.passkeys_lib_flutter

class PasskeysLibFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null

    private lateinit var methodCallHandler: CredentialMethodCallHandler
    private var eventSink: EventChannel.EventSink? = null


    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val credentialManager = CredentialManager.create(binding.applicationContext)
        val parser = CredentialParser()
        val operationManager = CredentialOperationManager(credentialManager, eventEmitter=::sendEvent)
        val errorHandler = ErrorHandler()

        methodCallHandler = CredentialMethodCallHandler(
            parser,
            operationManager,
            errorHandler
        ) { activity }

        channel = MethodChannel(binding.binaryMessenger, "passkeys_lib_flutter")
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "credential_handler/events")
        evenrtChannel.setStreamHandler(object: EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
                this.eventSink = eventSink
            }
        })
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
    fun sendEvent(event: Map<String, Any>) {
        eventSink?.success(event)
    }
}
