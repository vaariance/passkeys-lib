class CredentialException implements Exception {
  final String code;
  final String? message;
  final dynamic details;

  CredentialException({
    required this.code,
    this.message,
    this.details,
  });

  @override
  String toString() => 'CredentialException($code, $message)';
}

class CreateCredentialOptions {
  final String challenge;
  final RelyingParty rp;
  final UserEntity user;
  final List<Map<String, dynamic>> pubKeyCredParams;
  final int? timeout;
  final String? attestation;
  final AuthenticatorSelection authenticatorSelection;
  final List<PublicKeyCredentialDescriptor>? excludeCredentials;

  CreateCredentialOptions({
    required this.challenge,
    required this.rp,
    required this.user,
    this.pubKeyCredParams = const [
      {'type': 'public-key', 'alg': -7}
    ],
    this.timeout = 60000,
    this.attestation = 'direct',
    required this.authenticatorSelection,
    this.excludeCredentials,
  });

  Map<String, dynamic> toJson() => {
        'challenge': challenge,
        'rp': rp.toJson(),
        'user': user.toJson(),
        'pubKeyCredParams': pubKeyCredParams,
        'timeout': timeout,
        'attestation': attestation,
        'authenticatorSelection': authenticatorSelection.toJson(),
        if (excludeCredentials != null)
          'excludeCredentials':
              excludeCredentials!.map((e) => e.toJson()).toList(),
      };
}

class PublicKeyCredentialDescriptor {
  final String id;
  final String type;
  final List<String>? transports;

  PublicKeyCredentialDescriptor({
    required this.id,
    this.type = 'public-key',
    this.transports,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        if (transports != null) 'transports': transports,
      };
}

class AuthenticatorSelection {
  final String authenticatorAttachment;
  final bool requireResidentKey;
  final String userVerification;
  final String residentKey;

  AuthenticatorSelection({
    this.authenticatorAttachment = 'platform',
    this.requireResidentKey = true,
    this.userVerification = 'required',
    this.residentKey = 'required',
  });

  Map<String, dynamic> toJson() => {
        'authenticatorAttachment': authenticatorAttachment,
        'requireResidentKey': requireResidentKey,
        'userVerification': userVerification,
        'residentKey': residentKey,
      };
}

class UserEntity {
  final String id;
  final String name;
  final String displayName;

  UserEntity({
    required this.id,
    required this.name,
    required this.displayName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'displayName': displayName,
      };
}

class RelyingParty {
  final String name;
  final String id;

  RelyingParty({required this.name, required this.id});

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
      };
}

class GetCredentialOptions {
  final String challenge;
  final String rpId;
  final List<PublicKeyCredentialDescriptor>? allowCredentials;
  final String? userVerification;
  final int? timeout;

  GetCredentialOptions({
    required this.challenge,
    required this.rpId,
    this.allowCredentials,
    this.userVerification = 'required',
    this.timeout = 60000,
  });

  Map<String, dynamic> toJson() => {
        'challenge': challenge,
        'rpId': rpId,
        if (allowCredentials != null)
          'allowCredentials': allowCredentials!.map((e) => e.toJson()).toList(),
        'userVerification': userVerification,
        'timeout': timeout,
      };
}
