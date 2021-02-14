part of firestore_model_notifier;

mixin FirestoreCounterViewerMixin<T> on FirestoreDocumentModel<T> {
  String get counterValueKey => "value";
  List<String> get counterKeys;

  T fromCounter(String key, int count);

  @override
  @protected
  @mustCallSuper
  Future<void> onDidLoad() async {
    await super.onDidLoad();
    for (final path in counterKeys) {
      reference.collection(path).get().then(_handleOnCounterUpdate);
    }
  }

  @override
  @protected
  @mustCallSuper
  Future<void> onDidListen() async {
    await super.onDidListen();
    for (final path in counterKeys) {
      reference.collection(path).snapshots().listen(_handleOnCounterUpdate);
    }
  }

  @override
  @protected
  @mustCallSuper
  Map<String, dynamic> filterOnSave(Map<String, dynamic> save) {
    return super.filterOnSave(save)
      ..removeWhere((key, value) => counterKeys.contains(key));
  }

  void _handleOnCounterUpdate(QuerySnapshot snapshot) {
    if (snapshot.docs.isEmpty) {
      return;
    }
    final key = snapshot.docs.first.reference.parent.id;
    final value = snapshot.docs.fold<int>(
      0,
      (previousValue, element) =>
          previousValue + (element.data()?.get<int>(counterValueKey, 0) ?? 0),
    );
    this.value = fromCounter(key, value);
  }
}
