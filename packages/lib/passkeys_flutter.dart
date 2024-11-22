import 'package:passkeys_flutter/passkeys_models.dart';

import 'passkeys_flutter_platform_interface.dart';

class PasskeysFlutter {
  Future<Map<String, dynamic>?> register(
      CreateCredentialOptions options) async {
    return PasskeysFlutterPlatform.instance.register(options);
  }

  Future<Map<String, dynamic>?> authenticate(
      GetCredentialOptions options) async {
    return PasskeysFlutterPlatform.instance.authenticate(options);
  }
}
