part of firebase_model_notifier;

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

  @protected
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  final String path;
  final Map<String, String> paramaters;
  final List<StreamSubscription> subscriptions = [];

  @protected
  @mustCallSuper
  Query query(Query query) {
    if (paramaters.isNotEmpty) {
      if (!paramaters.containsKey("key")) {
        return query;
      }
      if (paramaters.containsKey("equalTo")) {
        query = query.where(paramaters["key"],
            isEqualTo: _parse(paramaters["equalTo"]));
      }
      if (paramaters.containsKey("notEqualTo")) {
        query = query.where(paramaters["key"],
            isNotEqualTo: _parse(paramaters["noteEqualTo"]));
      }
      if (paramaters.containsKey("startAt")) {
        query = query.where(paramaters["key"],
            isGreaterThanOrEqualTo: num.parse(paramaters["startAt"] ?? "0"));
      }
      if (paramaters.containsKey("endAt")) {
        query = query.where(paramaters["key"],
            isLessThanOrEqualTo: num.parse(paramaters["endAt"] ?? "0"));
      }
      if (paramaters.containsKey("contains")) {
        query = query.where(paramaters["key"],
            arrayContains: _parse(paramaters["contains"]));
      }
      if (paramaters.containsKey("limitToFirst")) {
        query = query.limit(int.parse(paramaters["limitToFirst"] ?? "0"));
      }
      if (paramaters.containsKey("limitToLast")) {
        query = query.limitToLast(int.parse(paramaters["limitToLast"] ?? "0"));
      }
      if (paramaters.containsKey("orderByDesc")) {
        query = query.orderBy(paramaters["orderByDesc"], descending: true);
      }
      if (paramaters.containsKey("orderByAsc")) {
        query = query.orderBy(paramaters["orderByAsc"]);
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

  List<Query> get references {
    if (paramaters.containsKey("containsAny")) {
      final queries = <Query>[];
      final items = paramaters["containsAny"]?.split(",") ?? <String>[];
      for (var i = 0; i < items.length; i += 10) {
        queries.add(
          query(
            firestore.collection(path.split("?").first),
          ).where(
            paramaters["key"],
            arrayContainsAny: items
                .sublist(
                  i,
                  min(i + 10, items.length),
                )
                .map((e) => _parse(e))
                .toList(),
          ),
        );
      }
      return queries;
    } else if (paramaters.containsKey("whereIn")) {
      final queries = <Query>[];
      final items = paramaters["whereIn"]?.split(",") ?? <String>[];
      for (var i = 0; i < items.length; i += 10) {
        queries.add(
          query(
            firestore.collection(path.split("?").first),
          ).where(
            paramaters["key"],
            whereIn: items
                .sublist(
                  i,
                  min(i + 10, items.length),
                )
                .map((e) => _parse(e))
                .toList(),
          ),
        );
      }
      return queries;
    } else if (paramaters.containsKey("whereNotIn")) {
      final queries = <Query>[];
      final items = paramaters["whereNotIn"]?.split(",") ?? <String>[];
      for (var i = 0; i < items.length; i += 10) {
        queries.add(
          query(
            firestore.collection(path.split("?").first),
          ).where(
            paramaters["key"],
            whereIn: items
                .sublist(
                  i,
                  min(i + 10, items.length),
                )
                .map((e) => _parse(e))
                .toList(),
          ),
        );
      }
      return queries;
    }
    return [query(firestore.collection(path))];
  }

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
  Future<List<T>> load() async {
    await FirebaseCore.initialize();
    await onLoad();
    await Future.delayed(Duration(milliseconds: Random().nextInt(100)));
    await Future.wait(
      references.map((reference) => reference.get().then(_handleOnUpdate)),
    );
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
    await Future.wait(
      references.map((reference) =>
          reference.startAtDocument(last).get().then(_handleOnUpdate)),
    );
    await onDidLoadNext();
    return this;
  }

  Future<void> listen() async {
    if (subscriptions.isNotEmpty) {
      return;
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
  }

  @override
  Future<List<T>> save() async {
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
