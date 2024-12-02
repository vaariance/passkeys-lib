import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
}

