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
