part of firebase_model_notifier;

Future<bool> containsInServer(
    {required String path, required String key, required dynamic value}) async {
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
Future<String> generateCodeFromServer({
  required String path,
  required String key,
  int length = 6,
  String charSet = "23456789abcdefghjkmnpqrstuvwxy",
}) async {
  await FirebaseCore.initialize();
  List<String> generated = [];
  do {
    await Future.delayed(Duration(milliseconds: Random().nextInt(100)));
    generated =
        List.generate(10, (index) => generateCode(length, charSet: charSet));
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
