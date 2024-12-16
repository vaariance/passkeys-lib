import 'package:passkeys_lib_flutter/src/passkeys_lib_flutter_model.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'passkeys_lib_flutter_method_channel.dart';

abstract class PasskeysLibFlutterPlatform extends PlatformInterface {
  /// Constructs a PasskeysLibFlutterPlatform.
  PasskeysLibFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static PasskeysLibFlutterPlatform _instance = MethodChannelPasskeysLibFlutter();

  /// The default instance of [PasskeysLibFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelPasskeysLibFlutter].
  static PasskeysLibFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PasskeysLibFlutterPlatform] when
  /// they register themselves.
  static set instance(PasskeysLibFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
  Future<RegisterResponse> registerPasskey(RegisterOptions options) {
    throw UnimplementedError('registerPasskey() has not been implemented.');
  }
  Future<AuthenticateResponse> verifyPasskey(AuthenticateOptions options) {
    throw UnimplementedError('verifyPasskey() has not been implemented.');
  }
}
