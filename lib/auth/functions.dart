part of firebase_model_notifier;

bool get isSignedIn {
  final auth = readProvider(firebaseAuthProvider);
  return auth.isSignedIn;
}

bool get isVerified {
  final auth = readProvider(firebaseAuthProvider);
  return auth.isVerified;
}

String get userId {
  final auth = readProvider(firebaseAuthProvider);
  return auth.uid;
}

/// Returns a JWT refresh token for the user.
String get refreshToken {
  final auth = readProvider(firebaseAuthProvider);
  return auth.refreshToken;
}

/// Returns a JWT access token for the user.
Future<String> get accessToken {
  final auth = readProvider(firebaseAuthProvider);
  return auth.accessToken;
}
