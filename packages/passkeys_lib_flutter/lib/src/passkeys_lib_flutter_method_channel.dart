import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:passkeys_lib_flutter/src/passkeys_lib_flutter_model.dart';

import 'passkeys_lib_flutter_platform_interface.dart';

/// An implementation of [PasskeysLibFlutterPlatform] that uses method channels.
class MethodChannelPasskeysLibFlutter extends PasskeysLibFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('passkeys_lib_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

@override
  Future<RegisterResponse> registerPasskey(RegisterOptions options) async {
    try {
      final response = await methodChannel.invokeMethod<String>('register', options.toJson());

      if (response == null) {
        throw Exception('Registration failed');
      }
      return RegisterResponse.fromJson(Map<String, dynamic>.from(response as Map));

    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<AuthenticateResponse> verifyPasskey(AuthenticateOptions options) async {
    try {
      final response = await methodChannel.invokeMethod<String>('authenticate');

      if (response == null) {
        throw Exception('Authentication failed');
      } else {
        return AuthenticateResponse.fromJson(Map<String, dynamic>.from(response as Map));
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}

