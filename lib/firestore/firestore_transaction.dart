part of firebase_model_notifier;

class FirestoreTransaction {
  FirestoreTransaction._();

  static FirestoreIncrementCounterTransactionBuilder incrementCounter({
    required String collectionPath,
    String counterSuffix = "Count",
    String Function(String path)? counterBuilder,
    String? linkedCollectionPath,
    String Function(String linkPath)? linkedCounterBuilder,
    List<FirestoreCounterUpdaterInterval> counterIntervals = const [],
  }) {
    return FirestoreIncrementCounterTransactionBuilder._(
      collectionPath: collectionPath,
      counterSuffix: counterSuffix,
      counterBuilder: counterBuilder,
      linkedCollectionPath: linkedCollectionPath,
      linkedCounterBuilder: linkedCounterBuilder,
      counterIntervals: counterIntervals,
    );
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

class FirestoreIncrementCounterTransactionBuilder {
  FirestoreIncrementCounterTransactionBuilder._({
    required this.collectionPath,
    this.counterBuilder,
    this.counterSuffix = "Count",
    this.linkedCollectionPath,
    this.linkedCounterBuilder,
    this.counterIntervals = const [],
  })  : assert(
            !(collectionPath.splitLength() <= 0 ||
                collectionPath.splitLength() % 2 != 1),
            "The collection path hierarchy must be an odd number."),
        assert(
            linkedCollectionPath.isEmpty ||
                !(linkedCollectionPath!.splitLength() <= 0 ||
                    linkedCollectionPath.splitLength() % 2 != 1),
            "The link collection path hierarchy must be an odd number.");
  final String counterSuffix;
  final String collectionPath;
  final String Function(String path)? counterBuilder;
  final String? linkedCollectionPath;
  final String Function(String linkPath)? linkedCounterBuilder;
  final List<FirestoreCounterUpdaterInterval> counterIntervals;

  String? _buildCounterPath(String? path) {
    if (path.isEmpty) {
      return null;
    }
    return "$path$counterSuffix";
  }

  Map<String, dynamic> _buildCounterUpdate(String key, num value) {
    final now = DateTime.now();
    final map = {key: FieldValue.increment(1)};
    for (final interval in counterIntervals) {
      switch (interval) {
        case FirestoreCounterUpdaterInterval.daily:
          map[dailyKey(key, now)] = FieldValue.increment(value);
          for (var i = 0; i < 30; i++) {
            map[dailyKey(
                    key, DateTime(now.year, now.month, now.day - 60 + i))] =
                FieldValue.delete();
          }
          break;
        case FirestoreCounterUpdaterInterval.monthly:
          map[monthlyKey(key, now)] = FieldValue.increment(value);
          for (var i = 0; i < 12; i++) {
            map[monthlyKey(key, DateTime(now.year, now.month - 24 + i))] =
                FieldValue.delete();
          }
          break;
        case FirestoreCounterUpdaterInterval.yearly:
          map[yearlyKey(key, now)] = FieldValue.increment(value);
          for (var i = 0; i < 5; i++) {
            map[yearlyKey(key, DateTime(now.year, now.month - 10 + i))] =
                FieldValue.delete();
          }
          break;
        case FirestoreCounterUpdaterInterval.weekly:
          map[weeklyKey(key, now)] = FieldValue.increment(value);
          for (var i = 0; i < 4; i++) {
            map[weeklyKey(key,
                    DateTime(now.year, now.month, now.day - ((8 - i) * 7)))] =
                FieldValue.delete();
          }
          break;
      }
    }
    return map;
  }

  Future<void> append(String id, {String? linkId}) async {
    assert(
        linkId.isEmpty ||
            (linkedCollectionPath.isNotEmpty && linkId.isNotEmpty),
        "When [linkId] is specified, [linkPath] must be specified.");
    await FirebaseCore.initialize();
    await Future.delayed(Duration(milliseconds: Random().nextInt(100)));
    final firestore = FirebaseFirestore.instance;
    final docPath = counterBuilder?.call(collectionPath) ??
        _buildCounterPath(collectionPath) ??
        "";
    final linkDocPath = linkedCollectionPath.isEmpty
        ? null
        : (linkedCounterBuilder?.call(linkedCollectionPath!) ??
            _buildCounterPath(linkedCollectionPath!) ??
            "");
    await firestore.runTransaction((transaction) async {
      final doc = await transaction.get(firestore.doc("$collectionPath/$id"));
      final linkDoc = linkId.isEmpty || linkedCollectionPath.isEmpty
          ? null
          : await transaction
              .get(firestore.doc("$linkedCollectionPath/$linkId"));
      if (!doc.exists) {
        transaction.set(
          doc.reference,
          {
            "uid": id,
            "time": FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        if (docPath.isNotEmpty) {
          final key = docPath.split("/").last;
          final path = docPath.trimStringRight("/$key");
          transaction.set(
            firestore.doc(path),
            _buildCounterUpdate(key, 1),
            SetOptions(merge: true),
          );
        }
      }
      if (linkDoc != null && !linkDoc.exists) {
        transaction.set(
          linkDoc.reference,
          {
            "uid": linkId,
            "time": FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        if (linkDocPath.isNotEmpty) {
          final key = linkDocPath!.split("/").last;
          final path = linkDocPath.trimStringRight("/$key");
          transaction.set(
            firestore.doc(path),
            _buildCounterUpdate(key, 1),
            SetOptions(merge: true),
          );
        }
      }
    });
  }

  Future<void> remove(String id, {String? linkId}) async {
    assert(
        linkId.isEmpty ||
            (linkedCollectionPath.isNotEmpty && linkId.isNotEmpty),
        "When [linkId] is specified, [linkPath] must be specified.");
    await FirebaseCore.initialize();
    await Future.delayed(Duration(milliseconds: Random().nextInt(100)));
    final firestore = FirebaseFirestore.instance;
    final docPath = counterBuilder?.call(collectionPath) ??
        _buildCounterPath(collectionPath) ??
        "";
    final linkDocPath = linkedCollectionPath.isEmpty
        ? null
        : (linkedCounterBuilder?.call(linkedCollectionPath!) ??
            _buildCounterPath(linkedCollectionPath!) ??
            "");
    await firestore.runTransaction((transaction) async {
      final doc = await transaction.get(firestore.doc("$collectionPath/$id"));
      final linkDoc = linkId.isEmpty || linkedCollectionPath.isEmpty
          ? null
          : await transaction
              .get(firestore.doc("$linkedCollectionPath/$linkId"));
      if (doc.exists) {
        transaction.delete(doc.reference);
        if (docPath.isNotEmpty) {
          final key = docPath.split("/").last;
          final path = docPath.trimStringRight("/$key");
          transaction.set(
            firestore.doc(path),
            _buildCounterUpdate(key, -1),
            SetOptions(merge: true),
          );
        }
      }
      if (linkDoc != null && linkDoc.exists) {
        transaction.delete(linkDoc.reference);
        if (linkDocPath.isNotEmpty) {
          final key = linkDocPath!.split("/").last;
          final path = linkDocPath.trimStringRight("/$key");
          transaction.set(
            firestore.doc(path),
            _buildCounterUpdate(key, -1),
            SetOptions(merge: true),
          );
        }
      }
    });
  }
}
