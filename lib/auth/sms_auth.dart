part of firestore_model_notifier;

/// Log in using your phone number.
class SMSAuth {
  /// Gets the options for the provider.
  static const AuthProviderOptions options = AuthProviderOptions(
      id: "phone",
      provider: _provider,
      title: "Phone number SignIn",
      text: "Enter your phone number to sign in.");
  static Future<FirebaseAuthModel> _provider(
      BuildContext context, Duration timeout) async {
    String? phoneNumber;
    final auth = context.read(firebaseAuthProvider);
    await UISMSFormDialog.show(
      context,
      defaultSubmitAction: (m) {
        phoneNumber = m;
      },
    );
    if (phoneNumber.isEmpty) {
      return auth;
    }
    await auth.sendSMS(phoneNumber!, timeout: timeout);
    return auth;
  }

  /// Authenticate by sending a code to your phone number.
  ///
  /// [phoneNumber]: Telephone number (starting with the country code).
  /// [protorol]: Protocol specification.
  /// [locale]: Specify the language of the confirmation email.
  /// [timeout]: Timeout time.
  static Future<FirebaseAuthModel> send(String phoneNumber,
      {String? locale, Duration timeout = const Duration(seconds: 60)}) async {
    final auth = ProviderContainer().read(firebaseAuthProvider);
    await auth.sendSMS(phoneNumber, locale: locale, timeout: timeout);
    return auth;
  }

  /// Authenticate by sending a code to your phone number.
  ///
  /// [smsCode]: Authentication code received from SMS.
  /// [protorol]: Protocol specification.
  /// [locale]: Specify the language of the confirmation email.
  /// [timeout]: Timeout time.
  static Future<FirebaseAuthModel> signIn(String smsCode,
      {String? locale, Duration timeout = const Duration(seconds: 60)}) async {
    final auth = ProviderContainer().read(firebaseAuthProvider);
    await auth.signInSMS(smsCode, locale: locale, timeout: timeout);
    return auth;
  }

  /// Update your phone number.
  /// You need to send an SMS with [sendSMS] in advance.
  ///
  /// [smsCode]: Authentication code received from SMS.
  /// [protorol]: Protocol specification.
  /// [locale]: Specify the language of the confirmation email.
  /// [timeout]: Timeout time.
  static Future<FirebaseAuthModel> changePhoneNumber(String smsCode,
      {String? locale, Duration timeout = const Duration(seconds: 60)}) async {
    final auth = ProviderContainer().read(firebaseAuthProvider);
    await auth.changePhoneNumber(smsCode, locale: locale, timeout: timeout);
    return auth;
  }
}
