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

Future<bool> tryRestoreAuth({
  Duration timeout = const Duration(seconds: 60),
  bool retryWhenTimeout = false,
}) {
  final auth = readProvider(firebaseAuthProvider);
  return auth.tryRestoreAuth(
      timeout: timeout, retryWhenTimeout: retryWhenTimeout);
}
