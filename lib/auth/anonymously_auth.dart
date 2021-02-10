part of firestore_model_notifier;

/// Process sign-in.
/// Perform an anonymous login.
class AnonymouslyAuth {
  /// Gets the options for the provider.
  static const AuthProviderOptions options = AuthProviderOptions(
      id: "anonymous",
      provider: _provider,
      title: "Anonymous SignIn",
      text: "Sign in as a guest.");
  static Future<FirebaseAuthModel> _provider(
      BuildContext context, Duration timeout) async {
    final auth = context.read(firebaseAuthProvider);
    await auth.signInAnonymously(timeout: timeout);
    return auth;
  }

  /// Process sign-in.
  /// Perform an anonymous login.
  ///
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirebaseAuthModel> signIn(
      {Duration timeout = const Duration(seconds: 60)}) async {
    final auth = ProviderContainer().read(firebaseAuthProvider);
    await auth.signInAnonymously(timeout: timeout);
    return auth;
  }
}
