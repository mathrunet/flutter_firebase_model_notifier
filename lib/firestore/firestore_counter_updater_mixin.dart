part of firestore_model_notifier;

mixin FirestoreCounterUpdaterMixin<T extends FirestoreDocumentModel>
    on FirestoreCollectionModel<T> {
  @protected
  int get counterSharedCount => 1000;

  @protected
  String get counterValueKey;

  @protected
  List<FirestoreCounterUpdaterInterval> get intervals => const [];

  @protected
  @mustCallSuper
  Future<void> onAppend() async {}

  @protected
  @mustCallSuper
  Future<void> onDelete() async {}

  @protected
  @mustCallSuper
  Future<void> onDidAppend() async {}

  @protected
  @mustCallSuper
  Future<void> onDidDelete() async {}

  Future<List<T>> append(T append) async {
    assert(
      append.path.contains(path) &&
          append.path.splitLength() == path.splitLength() + 1,
      "The document you Append must be a child of the collection. $path ${append.path} ${path.splitLength()} ${append.path.splitLength()}",
    );
    await FirebaseCore.initialize();
    await onAppend();
    final documentPath = path.parentPath();
    await firestore.runTransaction((transaction) async {
      final doc = await transaction.get(firestore.doc(append.path));
      if (doc.exists) {
        return;
      }
      transaction.set(
        firestore.doc(append.path),
        append.filterOnSave(
          append.toMap(append.value),
        ),
        SetOptions(merge: true),
      );
      transaction.set(
        firestore.doc(documentPath),
        _setInterval(FieldValue.increment(1)),
        SetOptions(merge: true),
      );
    });
    await onDidAppend();
    return this;
  }

  Future<List<T>> delete(T delete) async {
    assert(
      delete.path.contains(path) &&
          delete.path.splitLength() == path.splitLength() + 1,
      "The document you Delete must be a child of the collection.",
    );
    await FirebaseCore.initialize();
    await onDelete();
    final documentPath = path.parentPath();
    await firestore.runTransaction((transaction) async {
      final doc = await transaction.get(firestore.doc(delete.path));
      if (!doc.exists) {
        return;
      }
      transaction.delete(
        firestore.doc(delete.path),
      );
      transaction.set(
        firestore.doc(documentPath),
        _setInterval(FieldValue.increment(-1)),
        SetOptions(merge: true),
      );
    });
    await onDidDelete();
    return this;
  }

  Map<String, dynamic> _setInterval(dynamic value) {
    final now = DateTime.now();
    final map = {counterValueKey: value};
    for (final interval in intervals) {
      switch (interval) {
        case FirestoreCounterUpdaterInterval.daily:
          map["$counterValueKey:${now.format("yyyyMMdd")}"] = value;
          for (var i = 0; i < 30; i++) {
            map["$counterValueKey:${DateTime(now.year, now.month, now.day - 60 + i).format("yyyyMMdd")}"] =
                FieldValue.delete();
          }
          break;
        case FirestoreCounterUpdaterInterval.monthly:
          map["$counterValueKey:${now.format("yyyyMM")}"] = value;
          for (var i = 0; i < 12; i++) {
            map["$counterValueKey:${DateTime(now.year, now.month - 24 + i).format("yyyyMM")}"] =
                FieldValue.delete();
          }
          break;
        case FirestoreCounterUpdaterInterval.yearly:
          map["$counterValueKey:${now.format("yyyy")}"] = value;
          for (var i = 0; i < 5; i++) {
            map["$counterValueKey:${DateTime(now.year, now.month - 10 + i).format("yyyy")}"] =
                FieldValue.delete();
          }
          break;
        case FirestoreCounterUpdaterInterval.weekly:
          map["$counterValueKey:${now.format("yyyyww")}"] = value;
          for (var i = 0; i < 4; i++) {
            map["$counterValueKey:${DateTime(now.year, now.month, now.day - ((8 - i) * 7)).format("yyyy")}"] =
                FieldValue.delete();
          }
          break;
      }
    }
    return map;
  }
}

enum FirestoreCounterUpdaterInterval { daily, weekly, monthly, yearly }
