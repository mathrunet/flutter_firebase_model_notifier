part of firebase_model_notifier;

abstract class FirestoreCollectionModel<T extends FirestoreDocumentModel>
    extends ListModel<T>
    implements
        StoredModel<List<T>, FirestoreCollectionModel<T>>,
        ListenedModel<List<T>, FirestoreCollectionModel<T>>,
        CollectionMockModel<T, FirestoreCollectionModel<T>> {
  FirestoreCollectionModel(String path, [List<T>? value])
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 1),
            "The path hierarchy must be an odd number."),
        path = _getPath(path),
        paramaters = _getParamaters(path),
        super(value ?? []);

  static String _getPath(String path) {
    if (path.contains("?")) {
      return path.split("?").first;
    }
    return path;
  }

  static Map<String, String> _getParamaters(String path) {
    if (path.contains("?")) {
      return Uri.parse(path).queryParameters;
    }
    return const {};
  }

  @protected
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  final String path;
  final Map<String, String> paramaters;
  final List<StreamSubscription> subscriptions = [];

  @protected
  @mustCallSuper
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

  @protected
  @mustCallSuper
  List<Query> get references => [query(firestore.collection(path))];

  @override
  void dispose() {
    super.dispose();
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();
  }

  @protected
  T createDocument(String path);

  T create([String? id]) => createDocument("$path/${id.isEmpty ? uuid : id}");

  @override
  FirestoreCollectionModel<T> mock(List<Map<String, dynamic>> mockData) {
    bool notify = false;
    if (isNotEmpty) {
      clear();
      notify = true;
    }
    if (mockData.isNotEmpty) {
      notify = true;
      final addData = <T>[];
      for (final tmp in mockData) {
        final value = createDocument("$path/${tmp.hashCode}");
        value.value = value.fromMap(value.filterOnLoad(tmp));
        addData.add(value);
      }
      addAll(addData);
    }
    if (notify) {
      streamController.sink.add(value);
      notifyListeners();
    }
    return this;
  }

  @override
  Future<FirestoreCollectionModel<T>> load() async {
    await FirebaseCore.initialize();
    await onLoad();
    await Future.delayed(Duration(milliseconds: Random().nextInt(100)));
    await Future.wait(
      references.map((reference) => reference.get().then(_handleOnUpdate)),
    );
    await onDidLoad();
    return this;
  }

  Future<FirestoreCollectionModel<T>> next() async {
    await FirebaseCore.initialize();
    final last = length <= 0 ? null : this.last._snapshot;
    if (last == null) {
      return load();
    }
    await onLoadNext();
    await Future.delayed(Duration(milliseconds: Random().nextInt(100)));
    await Future.wait(
      references.map((reference) =>
          reference.startAtDocument(last).get().then(_handleOnUpdate)),
    );
    await onDidLoadNext();
    return this;
  }

  @override
  Future<FirestoreCollectionModel<T>> listen() async {
    if (subscriptions.isNotEmpty) {
      return this;
    }
    await FirebaseCore.initialize();
    await onLoad();
    await Future.delayed(Duration(milliseconds: Random().nextInt(100)));
    subscriptions.addAll(
      references.map(
        (reference) => reference.snapshots().listen(_handleOnUpdate),
      ),
    );
    await onDidListen();
    return this;
  }

  @override
  Future<FirestoreCollectionModel<T>> save() async {
    throw UnimplementedError("Save process should be done for each document.");
  }

  void _handleOnUpdate(QuerySnapshot snapshot) {
    bool notify = false;
    for (final doc in snapshot.docChanges) {
      final found = firstWhereOrNull(
          (element) => doc.doc.reference.path == element._reference?.path);
      switch (doc.type) {
        case DocumentChangeType.added:
          if (found != null) {
            continue;
          }
          final value = createDocument(doc.doc.reference.path);
          value.value =
              value.fromMap(value.filterOnLoad(doc.doc.data()?.cast() ?? {}));
          value._snapshot = doc.doc;
          value._reference = doc.doc.reference;
          add(value);
          notify = true;
          break;
        case DocumentChangeType.modified:
          if (found != null) {
            found.value =
                found.fromMap(found.filterOnLoad(doc.doc.data()?.cast() ?? {}));
            found._snapshot = doc.doc;
            found._reference = doc.doc.reference;
            found._notifyListeners();
          }
          break;
        case DocumentChangeType.removed:
          if (found == null) {
            continue;
          }
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
