part of firebase_model_notifier;

extension UserExtensions on User {
  bool get isEmpty {
    return uid.isEmpty;
  }

  bool get isNotEmpty {
    return uid.isNotEmpty;
  }
}

extension NullableUserExtensions on User? {
  bool get isEmpty {
    if (this == null) {
      return true;
    }
    return this!.uid.isEmpty;
  }

  bool get isNotEmpty {
    if (this == null) {
      return false;
    }
    return this!.uid.isNotEmpty;
  }
}
