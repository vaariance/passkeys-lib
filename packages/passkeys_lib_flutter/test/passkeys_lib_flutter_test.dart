import 'package:flutter_test/flutter_test.dart';
import 'package:passkeys_lib_flutter/passkeys_lib_flutter.dart';
import 'package:passkeys_lib_flutter/passkeys_lib_flutter_platform_interface.dart';
import 'package:passkeys_lib_flutter/passkeys_lib_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPasskeysLibFlutterPlatform
    with MockPlatformInterfaceMixin
    implements PasskeysLibFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PasskeysLibFlutterPlatform initialPlatform = PasskeysLibFlutterPlatform.instance;

  test('$MethodChannelPasskeysLibFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPasskeysLibFlutter>());
  });

  test('getPlatformVersion', () async {
    PasskeysLibFlutter passkeysLibFlutterPlugin = PasskeysLibFlutter();
    MockPasskeysLibFlutterPlatform fakePlatform = MockPasskeysLibFlutterPlatform();
    PasskeysLibFlutterPlatform.instance = fakePlatform;

    expect(await passkeysLibFlutterPlugin.getPlatformVersion(), '42');
  });
}
