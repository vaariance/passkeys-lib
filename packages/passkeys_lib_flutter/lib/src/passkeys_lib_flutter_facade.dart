import 'package:passkeys_lib_flutter/src/passkeys_lib_flutter_model.dart';

import 'passkeys_lib_flutter_platform_interface.dart';

class PasskeysLibFlutter {
  /// Register or create a passkey by providing [RegisterOptions]
  Future<RegisterResponse> registerPasskey(RegisterOptions options) {
    return PasskeysLibFlutterPlatform.instance.registerPasskey(options);
  }

  /// Verify a passkey by providing [AuthenticateOptions]
  Future<AuthenticateResponse> verifyPasskey(AuthenticateOptions options) {
    return PasskeysLibFlutterPlatform.instance.verifyPasskey(options);
  }
}
