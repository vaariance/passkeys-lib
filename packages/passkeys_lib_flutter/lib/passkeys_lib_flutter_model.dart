class RegisterOptions {
  final String challenge;
  final RelyingParty rp;
  final UserEntity user;
  final int? timeout;
  final String? attestation;
  final AuthenticatorSelection authenticatorSelection;

  RegisterOptions({
    required this.challenge,
    required this.rp,
    required this.user,
    this.timeout,
    this.attestation,
    required this.authenticatorSelection,
  });

  Map<String, dynamic> toJson() => {
    'challenge': challenge,
    'rp': rp.toJson(),
    'user': user.toJson(),
    'timeout': timeout,
    'attestation': attestation,
    'authenticatorSelection': authenticatorSelection.toJson(),
  };
}
class RelyingParty {
  final String name;
  final String id;

  RelyingParty({
    required this.name,
    required this.id,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'id': id,
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

class AuthenticatorSelection {
  final bool? requireResidentKey;
  final String userVerification;

  AuthenticatorSelection({
    this.requireResidentKey,
    required this.userVerification,
  });

  Map<String, dynamic> toJson() => {
    'requireResidentKey': requireResidentKey,
    'userVerification': userVerification,
  };
}

class RegisterResponse {
  final String credentialId;
  final int createdAt;

  RegisterResponse({
    required this.credentialId,
    required this.createdAt,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) => RegisterResponse(
    credentialId: json['credentialId'] as String,
    createdAt: json['createdAt'] as int,
  );
}

class AuthenticateResponse {
  final String credentialId;
  final String authenticatorData;
  final String signature;

  AuthenticateResponse({
    required this.credentialId,
    required this.authenticatorData,
    required this.signature,
  });

  factory AuthenticateResponse.fromJson(Map<String, dynamic> json) {
    return AuthenticateResponse(
      credentialId: json['credentialId'],
      authenticatorData: json['authenticatorData'],
      signature: json['signature'],
    );
  }
}


class AuthenticateOptions {
  final String challenge;
  final int? timeout;
  final String rpId;
  final String? userVerification;
  final List<PublicKeyCredentialDescriptor>? allowCredentials;

  AuthenticateOptions({
    required this.challenge,
    this.timeout,
    required this.rpId,
    this.userVerification,
    this.allowCredentials,
  });

  Map<String, dynamic> toJson() => {
    'challenge': challenge,
    'timeout': timeout,
    'rpId': rpId,
    'userVerification': userVerification,
    'allowCredentials': allowCredentials?.map((e) => e.toJson()).toList(),
  };
}

class PublicKeyCredentialDescriptor {
  final String type;
  final String id;
  final List<String>? transports;

  PublicKeyCredentialDescriptor({
    required this.type,
    required this.id,
    this.transports,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'transports': transports,
  };
}
