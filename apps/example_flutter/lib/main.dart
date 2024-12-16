import 'package:flutter/material.dart';
import 'package:passkeys_lib_flutter/passkey_lib_flutter.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Passkeys Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PasskeysHomePage(),
    );
  }
}

class PasskeysHomePage extends StatefulWidget {
  const PasskeysHomePage({super.key});

  @override
  State<PasskeysHomePage> createState() => _PasskeysHomePageState();
}

class _PasskeysHomePageState extends State<PasskeysHomePage> {
  String _status = 'Idle';

  Future<void> _registerPasskey() async {
    try {
      final registerOptions = RegisterOptions(
        challenge: '12345',
        user: UserEntity(id: '12345', name: 'John Doe', displayName: 'John Doe'),
        attestation: 'none',
        timeout: 60000,
        authenticatorSelection: AuthenticatorSelection(userVerification: 'required'),
        rp: RelyingParty(id: 'variance.space', name: 'variance'),
      );

      final response = await PasskeysLibFlutter().registerPasskey(registerOptions);

      setState(() {
        _status = 'Registration Successful: Credential ID: ${response.credentialId}';
      });
    } catch (e) {
      setState(() {
        _status = 'Registration Failed: $e';
      });
    }
  }

  // Future<void> _authenticatePasskey() async {
  //   try {
  //     final authenticateOptions = AuthenticateOptions(
  //       userId: '12345',
  //     );
  //
  //     final response = await PasskeysLibFlutter.verifyPasskey(authenticateOptions);
  //
  //     setState(() {
  //       _status = 'Authentication Successful: ${response.status}';
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _status = 'Authentication Failed: $e';
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passkeys Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _status,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _registerPasskey,
                child: const Text('Register Passkey'),
              ),
            ),
            const SizedBox(height: 10),
            // ElevatedButton(
            //   onPressed: _authenticatePasskey,
            //   child: const Text('Authenticate Passkey'),
            // ),
          ],
        ),
      ),
    );
  }
}

class UserVerification {
  static const preferred = 'preferred';
  static const required = 'required';
}
