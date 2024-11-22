import 'package:passkeys_flutter/passkeys_models.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'passkeys_flutter_method_channel.dart';

abstract class PasskeysFlutterPlatform extends PlatformInterface {
  PasskeysFlutterPlatform() : super(token: _token);

  static final Object _token = Object();
  static PasskeysFlutterPlatform _instance = MethodChannelPasskeysFlutter();

  static PasskeysFlutterPlatform get instance => _instance;

  static set instance(PasskeysFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Map<String, dynamic>?> register(CreateCredentialOptions options) {
    throw UnimplementedError('register() has not been implemented.');
  }

  Future<Map<String, dynamic>?> authenticate(GetCredentialOptions options) {
    throw UnimplementedError('authenticate() has not been implemented.');
  }
}
