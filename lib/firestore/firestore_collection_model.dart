part of firestore_model_notifier;

abstract class FirestoreCollectionModel<T extends FirestoreDocumentModel>
    extends ListModel<T> implements StoredModel<List<T>> {
  FirestoreCollectionModel(this.path, [List<T> value = const []])
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 1),
            "The path hierarchy must be an odd number."),
        super(value);

  @protected
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  final String path;

  @protected
  Query query(Query query) => query;

  @protected
  @mustCallSuper
  Future<void> onLoad() async {}

  @protected
  @mustCallSuper
  Future<void> onListen() async {}

  @protected
  @mustCallSuper
  Future<void> onLoadNext() async {}

  @protected
  @mustCallSuper
  Future<void> onDidLoad() async {}

  @protected
  @mustCallSuper
  Future<void> onDidListen() async {}

  @protected
  @mustCallSuper
  Future<void> onDidLoadNext() async {}

  @override
  bool get notifyOnChangeValue => false;

  @override
  bool get notifyOnChangeList => false;

  Query get reference {
    return query(firestore.collection(path));
  }

  @protected
  T createDocument(String path);

  T create([String? id]) => createDocument("$path/${id.isEmpty ? uuid : id}");

  @override
  Future<List<T>> load() async {
    await FirebaseCore.initialize();
    await onLoad();
    await Future.delayed(Duration(milliseconds: Random().nextInt(100)));
    await reference.get().then(_handleOnUpdate);
    await onDidLoad();
    return this;
  }

  Future<List<T>> next() async {
    await FirebaseCore.initialize();
    final last = length <= 0 ? null : this.last._snapshot;
    if (last == null) {
      return load();
    }
    await onLoadNext();
    await Future.delayed(Duration(milliseconds: Random().nextInt(100)));
    await reference.startAtDocument(last).get().then(_handleOnUpdate);
    await onDidLoadNext();
    return this;
  }

  Future listen() async {
    await FirebaseCore.initialize();
    await onLoad();
    await Future.delayed(Duration(milliseconds: Random().nextInt(100)));
    reference.snapshots().listen(_handleOnUpdate);
    await onDidListen();
  }

  @override
  Future<List<T>> save() async {
    throw UnimplementedError("Save process should be done for each document.");
  }

  void _handleOnUpdate(QuerySnapshot snapshot) {
    bool notify = false;
    for (final doc in snapshot.docChanges) {
      switch (doc.type) {
        case DocumentChangeType.added:
          final value = createDocument(doc.doc.reference.path);
          value.value = value
              .fromMap(value.filterOnLoad(doc.doc.data()?.cast() ?? const {}));
          value._snapshot = doc.doc;
          value._reference = doc.doc.reference;
          add(value);
          notify = true;
          break;
        case DocumentChangeType.modified:
          final found = where(
              (element) => doc.doc.reference.path == element._reference?.path);
          if (found.isNotEmpty) {
            final first = found.first;
            first.value = first.fromMap(
                first.filterOnLoad(doc.doc.data()?.cast() ?? const {}));
            first._snapshot = doc.doc;
            first._reference = doc.doc.reference;
            first._notifyListeners();
          }
          break;
        case DocumentChangeType.removed:
          removeWhere(
            (element) => doc.doc.reference.path == element._reference?.path,
          );
          notify = true;
          break;
      }
    }
    if (notify) {
      streamController.sink.add(value);
      notifyListeners();
    }
  }
}
