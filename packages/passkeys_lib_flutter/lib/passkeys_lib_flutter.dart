
import 'passkeys_lib_flutter_platform_interface.dart';

class PasskeysLibFlutter {
  Future<String?> getPlatformVersion() {
    return PasskeysLibFlutterPlatform.instance.getPlatformVersion();
  }
}
