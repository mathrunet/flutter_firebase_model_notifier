part of firestore_model_notifier;

abstract class FirestoreCollectionModel<T extends FirestoreDocumentModel>
    extends ListModel<T> implements StoredModel<List<T>> {
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

  @protected
  @mustCallSuper
  Query query(Query query) {
    if (paramaters.isNotEmpty) {
      if (!paramaters.containsKey("orderBy")) {
        return query;
      }
      if (paramaters.containsKey("equalTo")) {
        query = query.where(paramaters["orderBy"],
            isEqualTo: paramaters["equalTo"]);
      }
      if (paramaters.containsKey("notEqualTo")) {
        query = query.where(paramaters["orderBy"],
            isNotEqualTo: paramaters["noteEqualTo"]);
      }
      if (paramaters.containsKey("startAt")) {
        query = query.where(paramaters["orderBy"],
            isGreaterThanOrEqualTo: double.parse(paramaters["startAt"] ?? "0"));
      }
      if (paramaters.containsKey("endAt")) {
        query = query.where(paramaters["orderBy"],
            isLessThanOrEqualTo: double.parse(paramaters["endAt"] ?? "0"));
      }
      if (paramaters.containsKey("contains")) {
        query = query.where(paramaters["orderBy"],
            arrayContains: paramaters["arrayIn"]);
      }
      if (paramaters.containsKey("containsAny")) {
        query = query.where(paramaters["orderBy"],
            arrayContainsAny: paramaters["containsAny"]?.split(","));
      }
      if (paramaters.containsKey("whereIn")) {
        query = query.where(paramaters["orderBy"],
            whereIn: paramaters["whereIn"]?.split(","));
      }
      if (paramaters.containsKey("whereNotIn")) {
        query = query.where(paramaters["orderBy"],
            whereNotIn: paramaters["whereNotIn"]?.split(","));
      }
      if (paramaters.containsKey("orderBy")) {
        query = query.orderBy(paramaters["orderBy"]);
      }
      if (paramaters.containsKey("limitToFirst")) {
        query = query.limit(int.parse(paramaters["limitToFirst"] ?? "0"));
      }
      if (paramaters.containsKey("limitToLast")) {
        query = query.limitToLast(int.parse(paramaters["limitToLast"] ?? "0"));
      }
      if (paramaters.containsKey("orderByDesc")) {
        query = query.orderBy(paramaters["orderByDesc"]);
      }
      if (paramaters.containsKey("orderByDesc")) {
        query = query.where(paramaters["orderByDesc"]);
      }
    }
    return query;
  }

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
    if (path.contains("?")) {
      return query(firestore.collection(path.split("?").first));
    }
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
