part of firestore_model_notifier;

/// Log in using your email and password.
class EmailAndPasswordAuth {
  /// Gets the options for the provider.
  static const AuthProviderOptions options = AuthProviderOptions(
      id: "emailandpassword",
      provider: _provider,
      title: "Email & Password SignIn",
      text: "Enter your email and password to sign in.");
  static Future<FirebaseAuthModel> _provider(
      BuildContext context, Duration timeout) async {
    String? email, password;
    final auth = context.read(firebaseAuthProvider);
    await UIEmailAndPasswordFormDialog.show(
      context,
      defaultSubmitAction: (m, p) {
        email = m;
        password = p;
      },
    );
    if (email.isEmpty || password.isEmpty) {
      return auth;
    }
    await auth.signInEmailAndPassword(
      email: email!,
      password: password!,
      timeout: timeout,
    );
    return auth;
  }

  /// Register using your email and password.
  ///
  /// [email]: Mail address.
  /// [locale]: Specify the language of the confirmation email.
  /// [password]: Password.
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirebaseAuthModel> register(
      {required String email,
      required String password,
      String? locale,
      Duration timeout = const Duration(seconds: 60)}) async {
    final auth = ProviderContainer().read(firebaseAuthProvider);
    await auth.registerInEmailAndPassword(
        email: email, password: password, locale: locale);
    return auth;
  }

  /// Log in using your email and password.
  ///
  /// [email]: Mail address.
  /// [password]: Password.
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirebaseAuthModel> signIn(
      {required String email,
      required String password,
      Duration timeout = const Duration(seconds: 60)}) async {
    final auth = ProviderContainer().read(firebaseAuthProvider);
    await auth.signInEmailAndPassword(
        email: email, password: password, timeout: timeout);
    return auth;
  }

  /// Re-authenticate using your email address and password.
  ///
  /// [password]: Password.
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirebaseAuthModel> reauth(
      {required String password,
      Duration timeout = const Duration(seconds: 60)}) async {
    final auth = ProviderContainer().read(firebaseAuthProvider);
    await auth.reauthInEmailAndPassword(password: password, timeout: timeout);
    return auth;
  }

  /// Resend the email for email address verification.
  ///
  /// [protorol]: Protocol specification.
  /// [locale]: Specify the language of the confirmation email.
  /// [timeout]: Timeout time.
  static Future<FirebaseAuthModel> sendEmailVerification(
      {Duration timeout = const Duration(seconds: 60), String? locale}) async {
    final auth = ProviderContainer().read(firebaseAuthProvider);
    await auth.sendEmailVerification(timeout: timeout, locale: locale);
    return auth;
  }

  /// Send you an email to reset your password.
  ///
  /// [email]: Email.
  /// [protorol]: Protocol specification.
  /// [locale]: Specify the language of the confirmation email.
  /// [timeout]: Timeout time.
  static Future<FirebaseAuthModel> sendPasswordResetEmail(
      {required String email,
      String? locale,
      Duration timeout = const Duration(seconds: 60)}) async {
    final auth = ProviderContainer().read(firebaseAuthProvider);
    await auth.sendPasswordResetEmail(
        email: email, locale: locale, timeout: timeout);
    return auth;
  }

  /// Change your email address.
  ///
  /// It is necessary to execute [reauthInEmailAndPassword]
  /// in advance to re-authenticate.
  ///
  /// [email]: Mail address.
  /// [locale]: Specify the language of the confirmation email.
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirebaseAuthModel> changeEmail(
      {required String email,
      String? locale,
      Duration timeout = const Duration(seconds: 60)}) async {
    final auth = ProviderContainer().read(firebaseAuthProvider);
    await auth.changeEmail(email: email, locale: locale, timeout: timeout);
    return auth;
  }

  /// Change your password.
  ///
  /// It is necessary to execute [reauthInEmailAndPassword]
  /// in advance to re-authenticate.
  ///
  /// [password]: The changed password.
  /// [locale]: Specify the language of the confirmation email.
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  static Future<FirebaseAuthModel> changePassword(
      {required String password,
      String? locale,
      Duration timeout = const Duration(seconds: 60)}) async {
    final auth = ProviderContainer().read(firebaseAuthProvider);
    await auth.changePassword(
        password: password, locale: locale, timeout: timeout);
    return auth;
  }
}
