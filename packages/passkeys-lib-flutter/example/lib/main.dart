import 'package:flutter/material.dart';
import 'package:passkeys_flutter/passkeys_flutter.dart';
import 'package:passkeys_flutter/passkeys_models.dart';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _passkeysPlugin = PasskeysFlutter();

  Future<void> _register() async {
    final options = CreateCredentialOptions(
      challenge: generateChallenge(),
      rp: RelyingParty(name: 'variance', id: 'variance.space'),
      user: UserEntity(id: '1234', name: 'Geffy', displayName: 'Geffy'),
      authenticatorSelection: AuthenticatorSelection(),
    );
    print(options.toJson());
    try {
      final result = await _passkeysPlugin.register(options);
      print('Registration successful: $result');
    } catch (e) {
      print('Registration failed: $e');
    }
  }

  String generateChallenge([int length = 32]) {
    final random = Random.secure();
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return base64Url.encode(bytes);
  }

  Future<void> _authenticate() async {
    final options = GetCredentialOptions(
      challenge: 'your-base64-challenge',
      rpId: 'yourdomain.com',
    );

    try {
      final result = await _passkeysPlugin.authenticate(options);
      print('Authentication successful: $result');
    } catch (e) {
      print('Authentication failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Passkeys Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _register,
                child: const Text('Register Passkey'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _authenticate,
                child: const Text('Authenticate with Passkey'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
