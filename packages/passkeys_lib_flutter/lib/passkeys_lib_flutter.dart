library passkeys_lib_flutter;
import 'package:passkeys_lib_flutter/passkeys_lib_flutter_model.dart';

import 'passkeys_lib_flutter_platform_interface.dart';

class PasskeysLibFlutter {
  Future<RegisterResponse> registerPasskey(RegisterOptions options) {
    return PasskeysLibFlutterPlatform.instance.registerPasskey(options);
  }
  Future<AuthenticateResponse> verifyPasskey(AuthenticateOptions options) {
    return PasskeysLibFlutterPlatform.instance.verifyPasskey(options);
  }
}
