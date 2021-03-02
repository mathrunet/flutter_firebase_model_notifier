part of firebase_model_notifier;

final firebaseAuthProvider = ModelProvider((_) => FirebaseAuthModel());

class FirebaseAuthModel extends Model<User?> {
  FirebaseAuthModel() : super();

  @protected
  FirebaseAuth get auth {
    return FirebaseAuth.instance;
  }

  static const String _hashKey = "MBdKdx3nAHFNeaP32zu8re9rzfHSGZj3";

  @protected
  User? get user => _user;
  @protected
  set user(User? user) {
    if (user == null || user == _user) {
      return;
    }
    _user = user;
  }

  User? _user;

  /// Set options for authentication.
  ///
  /// [twitterAPIKey]: Twitter API Key.
  /// [twitterAPISecret]: Twitter API Secret.
  void options({
    required String twitterAPIKey,
    required String twitterAPISecret,
  }) {
    _twitterAPIKey = twitterAPIKey;
    _twitterAPISecret = twitterAPISecret;
  }

  // ignore: unused_field
  String? _twitterAPIKey;
  // ignore: unused_field
  String? _twitterAPISecret;

  /// Check if you are logged in.
  ///
  /// True if logged in.
  ///
  /// [protocol]: Protocol specification.
  /// [timeout]: Timeout time.
  /// [retryWhenTimeout]: If it times out, try again.
  Future<bool> tryRestoreAuth({
    Duration timeout = const Duration(seconds: 60),
    bool retryWhenTimeout = false,
  }) {
    return _tryRestoreAuth(timeout, retryWhenTimeout);
  }

  Future<bool> _tryRestoreAuth(Duration timeout, bool retryWhenTimeout) async {
    try {
      await FirebaseCore.initialize();
      final user = auth.currentUser;
      if (user != null) {
        await user.reload().timeout(timeout);
        this.user = user;
        return true;
      }
    } on TimeoutException {
      if (!retryWhenTimeout) {
        rethrow;
      }
      return _tryRestoreAuth(timeout, retryWhenTimeout);
    } catch (e) {
      return false;
    }
    return false;
  }

  /// True if you are signed in.
  ///
  /// [protorol]: Protocol specification.
  bool get isSignedIn {
    if (user.isEmpty) {
      return false;
    }
    return true;
  }

  /// You can get the UID after authentication is completed.
  ///
  /// Null is returned if authentication is not completed.
  ///
  /// [protorol]: Protocol specification.
  String get uid {
    if (user.isEmpty) {
      return "";
    }
    return user!.uid;
  }

  /// You can get the Email after authentication is completed.
  ///
  /// Null is returned if authentication is not completed.
  ///
  /// [protorol]: Protocol specification.
  String get email {
    if (user.isEmpty) {
      return "";
    }
    return user!.email ?? "";
  }

  /// You can get the status that user email is verified
  /// after authentication is completed.
  ///
  /// [protorol]: Protocol specification.
  bool get isVerified {
    if (user.isEmpty) {
      return false;
    }
    return user!.emailVerified;
  }

  /// You can get the PhoneNumber after authentication is completed.
  ///
  /// Null is returned if authentication is not completed.
  ///
  /// [protorol]: Protocol specification.
  String get phoneNumber {
    if (user.isEmpty) {
      return "";
    }
    return user!.phoneNumber ?? "";
  }

  /// You can get the PhotoURL after authentication is completed.
  ///
  /// Null is returned if authentication is not completed.
  ///
  /// [protorol]: Protocol specification.
  String get photoURL {
    if (user.isEmpty) {
      return "";
    }
    return user!.photoURL ?? "";
  }

  /// You can get the Display Name after authentication is completed.
  ///
  /// Null is returned if authentication is not completed.
  ///
  /// [protorol]: Protocol specification.
  String get name {
    if (user.isEmpty) {
      return "";
    }
    return user!.displayName ?? "";
  }

  /// For anonymous logged in users, True.
  ///
  /// [protorol]: Protocol specification.
  bool get isAnonymously {
    if (user.isEmpty) {
      return false;
    }
    return user!.isAnonymous;
  }

  /// Reload the user data.
  ///
  /// [protorol]: Protocol specification.
  Future<void> reload() async {
    if (user.isEmpty) {
      throw Exception(
          "Not logged in yet. Please wait until login is successful.");
    }
    await user!.reload();
  }

  /// Process sign-in.
  /// Perform an anonymous login.
  ///
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  Future<User> signInAnonymously(
      {Duration timeout = const Duration(seconds: 60)}) async {
    if (user != null && user!.uid.isNotEmpty) {
      return user!;
    }
    await _anonymousProcess(timeout);
    return user!;
  }

  /// Sign out.
  ///
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  Future<void> signOut({Duration timeout = const Duration(seconds: 60)}) async {
    if (user.isEmpty) {
      throw Exception(
          "Not logged in yet. Please wait until login is successful.");
    }
    await _signOutProcess(timeout);
  }

  Future _signOutProcess(Duration timeout) async {
    await FirebaseCore.initialize();
    await auth.signOut().timeout(timeout);
    user = null;
    streamController.sink.add(user);
    notifyListeners();
  }

  /// Account delete.
  ///
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  Future<void> delete({Duration timeout = const Duration(seconds: 60)}) async {
    if (user.isEmpty) {
      throw Exception(
          "Not logged in yet. Please wait until login is successful.");
    }
    await _deleteProcess(timeout);
  }

  Future _deleteProcess(Duration timeout) async {
    await FirebaseCore.initialize();
    await user!.delete().timeout(timeout);
    user = null;
    streamController.sink.add(user);
    notifyListeners();
  }

  /// Check the user's verified status.
  ///
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  Future<bool> updateVerifiedStatus(
          {Duration timeout = const Duration(seconds: 60)}) =>
      tryRestoreAuth(timeout: timeout);

  /// Re-authenticate using your email address and password.
  ///
  /// [password]: Password.
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  Future<User> reauthInEmailAndPassword(
      {required String password,
      Duration timeout = const Duration(seconds: 60)}) async {
    assert(password.isNotEmpty, "This password is invalid.");
    if (user.isEmpty) {
      throw Exception(
          "Not logged in yet. Please wait until login is successful.");
    }
    await _reauthInEmailAndPasswordProcess(password, timeout);
    return user!;
  }

  Future _reauthInEmailAndPasswordProcess(
      String password, Duration timeout) async {
    await FirebaseCore.initialize();
    await user!.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: user!.email!, password: password));
    notifyListeners();
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
  Future<User> changeEmail(
      {required String email,
      String? locale,
      Duration timeout = const Duration(seconds: 60)}) async {
    assert(email.isNotEmpty, "This email is invalid.");
    if (user.isEmpty) {
      throw Exception(
          "Not logged in yet. Please wait until login is successful.");
    }
    await _changeEmailProcess(email, locale ?? Localize.locale, timeout);
    return user!;
  }

  Future<void> _changeEmailProcess(
      String email, String locale, Duration timeout) async {
    await FirebaseCore.initialize();
    await auth.setLanguageCode(locale);
    await user!.updateEmail(email);
    user = auth.currentUser;
    await user!.reload();
    streamController.sink.add(user);
    notifyListeners();
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
  Future<User> changePassword(
      {required String password,
      String? locale,
      Duration timeout = const Duration(seconds: 60)}) async {
    assert(password.isNotEmpty, "This password is invalid.");
    if (user.isEmpty) {
      throw Exception(
          "Not logged in yet. Please wait until login is successful.");
    }
    await _changePasswordProcess(password, locale ?? Localize.locale, timeout);
    return user!;
  }

  Future _changePasswordProcess(
      String password, String locale, Duration timeout) async {
    await FirebaseCore.initialize();
    await auth.setLanguageCode(locale);
    await user!.updatePassword(password);
    user = auth.currentUser;
    await user!.reload();
    streamController.sink.add(user);
    notifyListeners();
  }

  /// Resend the email for email address verification.
  ///
  /// [protorol]: Protocol specification.
  /// [locale]: Specify the language of the confirmation email.
  /// [timeout]: Timeout time.
  Future<User> sendEmailVerification({
    Duration timeout = const Duration(seconds: 60),
    String? locale,
  }) async {
    if (user.isEmpty) {
      throw Exception(
          "Not logged in yet. Please wait until login is successful.");
    }
    await _sendEmailVerificationProcess(locale ?? Localize.locale, timeout);
    return user!;
  }

  Future<void> _sendEmailVerificationProcess(
      String locale, Duration timeout) async {
    await FirebaseCore.initialize();
    if (user!.emailVerified) {
      throw Exception("This user has already been authenticated.");
    }
    await auth.setLanguageCode(locale);
    await user!.sendEmailVerification();
    notifyListeners();
  }

  /// Send you an email to reset your password.
  ///
  /// [email]: Email.
  /// [protorol]: Protocol specification.
  /// [locale]: Specify the language of the confirmation email.
  /// [timeout]: Timeout time.
  Future<User> sendPasswordResetEmail(
      {required String email,
      String? locale,
      Duration timeout = const Duration(seconds: 60)}) async {
    assert(email.isNotEmpty, "This email is invalid.");
    await _sendPasswordResetEmailProcess(
        email, locale ?? Localize.locale, timeout);
    return user!;
  }

  Future<void> _sendPasswordResetEmailProcess(
      String email, String locale, Duration timeout) async {
    await FirebaseCore.initialize();
    await auth.setLanguageCode(locale);
    await auth.sendPasswordResetEmail(email: email);
    notifyListeners();
  }

  /// Link by email link.
  ///
  /// You need to do [sendEmailLink] first.
  ///
  /// Enter the link acquired by Dynamic Link.
  ///
  /// [link]: Email link.
  /// [locale]: Specify the language of the confirmation email.
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  Future<User> signInEmailLink(String link,
      {String? locale, Duration timeout = const Duration(seconds: 60)}) async {
    assert(link.isNotEmpty, "This email link is invalid.");
    final email = Prefs.getString("FirestoreSignInEmail".toSHA256(_hashKey));
    if (email.isEmpty) {
      throw Exception(
          "The processing is invalid. First create a link with [sendEmailLink].");
    }
    await _linkToEmailLinkProcess(
        email, link, locale ?? Localize.locale, timeout);
    return user!;
  }

  Future<void> _linkToEmailLinkProcess(
      String email, String link, String locale, Duration timeout) async {
    await _prepareProcessInternal(timeout);
    if (!auth.isSignInWithEmailLink(link)) {
      throw Exception("This email link is invalid.");
    }
    await auth.setLanguageCode(locale);
    final credential =
        EmailAuthProvider.credentialWithLink(email: email, emailLink: link);
    if (user != null) {
      user = (await user!.linkWithCredential(credential).timeout(timeout)).user;
    } else {
      user =
          (await auth.signInWithCredential(credential).timeout(timeout)).user;
    }
    if (user.isEmpty) {
      throw Exception("User is not found.");
    }
    Prefs.remove("FirestoreSignInEmail".toSHA256(_hashKey));
    streamController.sink.add(user);
    notifyListeners();
  }

  /// Send an email link.
  ///
  /// [email]: Email.
  /// [url]: URL domain of the link. Specify the domain of Dynamic Link.
  /// [packageName]: App package name.
  /// [androidMinimumVersion]: Minimum version of android.
  /// [protorol]: Protocol specification.
  /// [locale]: Specify the language of the confirmation email.
  /// [timeout]: Timeout time.
  Future<void> sendEmailLink(
      {required String email,
      required String url,
      required String packageName,
      int androidMinimumVersion = 1,
      String? locale,
      Duration timeout = const Duration(seconds: 60)}) async {
    assert(email.isNotEmpty, "This email is invalid.");
    await _sendEmailLinkProcess(
      email,
      url,
      packageName,
      androidMinimumVersion,
      locale ?? Localize.locale,
      timeout,
    );
  }

  Future<void> _sendEmailLinkProcess(
      String email,
      String url,
      String packageName,
      int androidMinimumVersion,
      String locale,
      Duration timeout) async {
    await _prepareProcessInternal(timeout);
    if (user != null &&
        user!.providerData
            .any((t) => t.providerId.contains(EmailAuthProvider.PROVIDER_ID))) {
      throw Exception("This user is already linked to a Email account.");
    }
    await auth.setLanguageCode(locale);
    await auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
            androidInstallApp: true,
            url: url,
            handleCodeInApp: true,
            iOSBundleId: packageName,
            androidPackageName: packageName,
            androidMinimumVersion: androidMinimumVersion.toString()));
    Prefs.set("FirestoreSignInEmail".toSHA256(_hashKey), email);
    notifyListeners();
  }

  /// Authenticate by sending a code to your phone number.
  ///
  /// [phoneNumber]: Telephone number (starting with the country code).
  /// [protorol]: Protocol specification.
  /// [locale]: Specify the language of the confirmation email.
  /// [timeout]: Timeout time.
  Future<void> sendSMS(String phoneNumber,
      {String? locale, Duration timeout = const Duration(seconds: 60)}) async {
    assert(phoneNumber.isNotEmpty, "This Phone number is invalid.");
    await _sendSMS(phoneNumber, locale ?? Localize.locale, timeout);
  }

  Future<void> _sendSMS(
      String phoneNumber, String locale, Duration timeout) async {
    await _prepareProcessInternal(timeout);
    await auth.setLanguageCode(locale);
    await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: timeout,
        verificationCompleted: (credential) async {
          if (user != null) {
            if (!user!.providerData.any(
                (t) => t.providerId.contains(PhoneAuthProvider.PROVIDER_ID))) {
              user =
                  (await user!.linkWithCredential(credential).timeout(timeout))
                      .user;
            }
          } else {
            user =
                (await auth.signInWithCredential(credential).timeout(timeout))
                    .user;
          }
          if (user.isEmpty) {
            throw Exception("User is not found.");
          }
          streamController.sink.add(user);
          notifyListeners();
        },
        verificationFailed: (error) {
          throw error;
        },
        codeSent: (verificationCode, [code]) {
          Prefs.set("FirestoreSignInPhoneNumber".toSHA256(_hashKey),
              verificationCode);
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (verificationCode) {
          Prefs.set("FirestoreSignInPhoneNumber".toSHA256(_hashKey),
              verificationCode);
          notifyListeners();
        });
  }

  /// Authenticate by sending a code to your phone number.
  ///
  /// [smsCode]: Authentication code received from SMS.
  /// [protorol]: Protocol specification.
  /// [locale]: Specify the language of the confirmation email.
  /// [timeout]: Timeout time.
  Future<User> signInSMS(String smsCode,
      {String? locale, Duration timeout = const Duration(seconds: 60)}) async {
    assert(smsCode.isNotEmpty, "This SMS code is invalid.");
    final phoneNumber =
        Prefs.getString("FirestoreSignInPhoneNumber".toSHA256(_hashKey));
    if (phoneNumber.isEmpty) {
      throw Exception(
          "An authorization code has not been issued. Use [FirestoreAuth.sendSMS()] to issue the authentication code.");
    }
    await _signInSMS(phoneNumber, smsCode, locale ?? Localize.locale, timeout);
    return user!;
  }

  Future<void> _signInSMS(String phoneNumber, String smsCode, String locale,
      Duration timeout) async {
    await _prepareProcessInternal(timeout);
    await auth.setLanguageCode(locale);
    final credential = PhoneAuthProvider.credential(
        verificationId: phoneNumber, smsCode: smsCode);
    if (user != null) {
      if (!user!.providerData
          .any((t) => t.providerId.contains(PhoneAuthProvider.PROVIDER_ID))) {
        user =
            (await user!.linkWithCredential(credential).timeout(timeout)).user;
      }
    } else {
      user =
          (await auth.signInWithCredential(credential).timeout(timeout)).user;
    }
    if (user.isEmpty) {
      throw Exception("User is not found.");
    }
    Prefs.remove("FirestoreSignInPhoneNumber".toSHA256(_hashKey));
    streamController.sink.add(user);
    notifyListeners();
  }

  /// Update your phone number.
  /// You need to send an SMS with [sendSMS] in advance.
  ///
  /// [smsCode]: Authentication code received from SMS.
  /// [protorol]: Protocol specification.
  /// [locale]: Specify the language of the confirmation email.
  /// [timeout]: Timeout time.
  Future<User> changePhoneNumber(String smsCode,
      {String? locale, Duration timeout = const Duration(seconds: 60)}) async {
    assert(smsCode.isNotEmpty, "This SMS code is invalid.");
    final phoneNumber =
        Prefs.getString("FirestoreSignInPhoneNumber".toSHA256(_hashKey));
    if (phoneNumber.isEmpty) {
      throw Exception(
          "An authorization code has not been issued. Use [FirestoreAuth.sendSMS()] to issue the authentication code.");
    }
    if (user.isEmpty) {
      throw Exception(
          "You are not logged in. You need to log in beforehand using [signInSMS].");
    }
    await _changePhoneNumber(
        phoneNumber, smsCode, locale ?? Localize.locale, timeout);
    return user!;
  }

  Future _changePhoneNumber(String phoneNumber, String smsCode, String locale,
      Duration timeout) async {
    await _prepareProcessInternal(timeout);
    await auth.setLanguageCode(locale);
    final credential = PhoneAuthProvider.credential(
        verificationId: phoneNumber, smsCode: smsCode);
    if (user.isEmpty) {
      throw Exception("User is not found.");
    }
    await user!.updatePhoneNumber(credential as PhoneAuthCredential);
    user = auth.currentUser;
    await user!.reload();
    Prefs.remove("FirestoreSignInPhoneNumber".toSHA256(_hashKey));
    streamController.sink.add(user);
    notifyListeners();
  }

  /// Register using your email and password.
  ///
  /// [email]: Mail address.
  /// [password]: Password.
  /// [locale]: Specify the language of the confirmation email.
  /// [protorol]: Protocol specification.
  /// [timeout]: Timeout time.
  Future<User> registerInEmailAndPassword(
      {required String email,
      required String password,
      String? locale,
      Duration timeout = const Duration(seconds: 60)}) async {
    assert(email.isNotEmpty && password.isNotEmpty,
        "This email or password is invalid.");
    await _registerToEmailAndPasswordProcess(
        email, password, locale ?? Localize.locale, timeout);
    return user!;
  }

  Future<void> _registerToEmailAndPasswordProcess(
      String email, String password, String locale, Duration timeout) async {
    await _prepareProcessInternal(timeout);
    if (user != null) {
      user = (await user!
              .linkWithCredential(EmailAuthProvider.credential(
                  email: email, password: password))
              .timeout(timeout))
          .user;
    } else {
      await auth.setLanguageCode(locale);
      user = (await auth
              .createUserWithEmailAndPassword(email: email, password: password)
              .timeout(timeout))
          .user;
    }
    if (user.isEmpty) {
      throw Exception("User is not found.");
    }
    streamController.sink.add(user);
    notifyListeners();
  }

  Future<User> signInEmailAndPassword(
      {required String email,
      required String password,
      Duration timeout = const Duration(seconds: 60)}) async {
    assert(email.isNotEmpty && password.isNotEmpty,
        "This email or password is invalid.");
    await _linkToEmailAndPasswordProcess(email, password, timeout);
    return user!;
  }

  Future<void> _linkToEmailAndPasswordProcess(
      String email, String password, Duration timeout) async {
    await _prepareProcessInternal(timeout);
    final credential =
        EmailAuthProvider.credential(email: email, password: password);
    if (user != null) {
      user = (await user!.linkWithCredential(credential).timeout(timeout)).user;
    } else {
      user =
          (await auth.signInWithCredential(credential).timeout(timeout)).user;
    }
    if (user.isEmpty) {
      throw Exception("User is not found.");
    }
    streamController.sink.add(user);
    notifyListeners();
  }

  Future<User> signInWithProvider(
      {required Future<AuthCredential> Function(Duration timeout)
          providerCallback,
      required String providerId,
      Duration timeout = const Duration(seconds: 60)}) async {
    assert(providerId.isNotEmpty, "The provier ID is invalid.");
    await _linkWithProviderProcess(providerCallback, providerId, timeout);
    return user!;
  }

  Future<void> _linkWithProviderProcess(
      Future<AuthCredential> providerCallback(Duration timeout),
      String providerId,
      Duration timeout) async {
    await _prepareProcessInternal(timeout);
    if (user != null &&
        user!.providerData.any((t) => t.providerId.contains(providerId))) {
      throw Exception("This user is already linked to a $providerId account.");
    }
    final credential = await providerCallback(timeout);
    if (user != null) {
      user = (await user!.linkWithCredential(credential).timeout(timeout)).user;
    } else {
      user =
          (await auth.signInWithCredential(credential).timeout(timeout)).user;
    }
    if (user.isEmpty) {
      throw Exception("User is not found.");
    }
    streamController.sink.add(user);
    notifyListeners();
  }

  Future<void> _anonymousProcess(Duration timeout) async {
    await _prepareProcessInternal(timeout);
    await _anonymousProcessInternal(timeout);
  }

  Future<void> _prepareProcessInternal(Duration timeout) async {
    await FirebaseCore.initialize();
    final user = auth.currentUser;
    if (user == null) {
      return;
    }
    await user.reload().timeout(timeout);
    this.user = user;
    return;
  }

  Future<void> _anonymousProcessInternal(Duration timeout) async {
    if (user != null) {
      return;
    }
    user = (await auth.signInAnonymously().timeout(timeout)).user;
    if (user.isEmpty) {
      throw Exception("User is not found.");
    }
    streamController.sink.add(user);
    notifyListeners();
  }
}
