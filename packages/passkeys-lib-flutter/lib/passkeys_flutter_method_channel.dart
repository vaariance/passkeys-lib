import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:passkeys_flutter/passkeys_models.dart';

import 'passkeys_flutter_platform_interface.dart';

/// An implementation of [PasskeysFlutterPlatform] that uses method channels.
class MethodChannelPasskeysFlutter extends PasskeysFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('credential_handler');

  @override
  Future<Map<String, dynamic>?> register(
      CreateCredentialOptions options) async {
    print('register called');
    print('register called ${options.toJson()}');
    try {
      final result = await methodChannel.invokeMethod<Map<String, dynamic>>(
        'register',
        options.toJson(),
      );

      print('result: ${result}');
      return result;
    } on PlatformException catch (e) {
      throw CredentialException(
        code: e.code,
        message: e.message,
        details: e.details,
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> authenticate(
      GetCredentialOptions options) async {
    try {
      final result = await methodChannel.invokeMethod<Map<String, dynamic>>(
        'authenticate',
        options.toJson(),
      );
      return result;
    } on PlatformException catch (e) {
      throw CredentialException(
        code: e.code,
        message: e.message,
        details: e.details,
      );
    }
  }
}
