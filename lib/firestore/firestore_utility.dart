part of firebase_model_notifier;

class FirestoreUtility {
  FirestoreUtility._();

  static dynamic _parse(dynamic value) {
    if (value is String) {
      final b = value.toLowerCase();
      if (b == "true") {
        return true;
      } else if (b == "false") {
        return false;
      }
      final n = num.tryParse(value);
      if (n != null) {
        return n;
      }
      return value;
    } else {
      return value;
    }
  }

  static Future<bool> containsValue(
      {required String path,
      required String key,
      required dynamic value}) async {
    await FirebaseCore.initialize();
    await Future.delayed(Duration(milliseconds: Random().nextInt(100)));
    final snapshot = await FirebaseFirestore.instance
        .collection(path)
        .where(key, isEqualTo: value)
        .get();
    return snapshot.size > 0;
  }

  /// Create a code of length [length] randomly for id.
  ///
  /// Characters that are difficult to understand are omitted.
  ///
  /// [seed] can be specified.
  ///
  /// [length]: Cord length.
  /// [seed]: Seed number.
  static Future<String> generateCode({
    required String path,
    required String key,
    int length = 6,
    String charSet = "23456789abcdefghjkmnpqrstuvwxy",
  }) async {
    await FirebaseCore.initialize();
    List<String> generated = [];
    do {
      await Future.delayed(Duration(milliseconds: Random().nextInt(100)));
      generated = List.generate(
          10, (index) => katana.generateCode(length, charSet: charSet));
      final snapshot = await FirebaseFirestore.instance
          .collection(path)
          .where(key, whereIn: generated)
          .get();
      for (final doc in snapshot.docs) {
        if (!doc.exists) {
          continue;
        }
        final map = doc.data();
        if (map == null || !map.containsKey(key)) {
          continue;
        }
        generated.remove(map.get(key, ""));
      }
    } while (generated.isEmpty);
    return generated.first;
  }
}
