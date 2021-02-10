part of firestore_model_notifier;

mixin FirestoreCounterUpdaterMixin<T extends FirestoreDocumentModel>
    on FirestoreCollectionModel<T> {
  String get counterValueKey => "value";
  String get counterCollectionPath => "${path}Count";
  int get counterSharedCount => 1000;

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
    final random = Random();
    await firestore.runTransaction((transaction) async {
      transaction.set(
          firestore.doc(append.path),
          append.filterOnSave(
            append.toMap(append.value),
          ),
          SetOptions(merge: true));
      transaction.set(
          firestore.collection(counterCollectionPath).doc(random
              .nextInt(counterSharedCount)
              .format("".padLeft(counterSharedCount.toString().length, "0"))),
          {
            counterValueKey: FieldValue.increment(1),
          },
          SetOptions(merge: true));
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
    final random = Random();
    await firestore.runTransaction((transaction) async {
      transaction.delete(
        firestore.doc(delete.path),
      );
      transaction.set(
          firestore.collection(counterCollectionPath).doc(random
              .nextInt(counterSharedCount)
              .format("".padLeft(counterSharedCount.toString().length, "0"))),
          {
            counterValueKey: FieldValue.increment(-1),
          },
          SetOptions(merge: true));
    });
    await onDidDelete();
    return this;
  }
}
