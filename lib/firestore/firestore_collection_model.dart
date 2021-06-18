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
        path = path.trimQuery(),
        parameters = _getParameters(path),
        super(value ?? []);

  static Map<String, String> _getParameters(String path) {
    if (path.contains("?")) {
      return Uri.parse(path).queryParameters;
    }
    return const {};
  }

  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    FirebaseAuthCore.addListenerOnUnauthorized(_handledOnUnauthorized);
    if (Config.isEnabledMockup) {
      if (isNotEmpty) {
        return;
      }
      if (initialMock.isNotEmpty) {
        addAll(initialMock);
      }
    }
  }

  @override
  @protected
  final List<T> initialMock = const [];

  @protected
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  final String path;
  final Map<String, String> parameters;
  final List<StreamSubscription> subscriptions = [];

  @protected
  @mustCallSuper
  Query<DynamicMap> query(Query<DynamicMap> query) => query;

  /// Returns itself after the load finishes.
  @override
  Future<FirestoreCollectionModel<T>> get loading =>
      _loadingCompleter?.future ?? Future.value(this);
  Completer<FirestoreCollectionModel<T>>? _loadingCompleter;

  /// Returns itself after the save finishes.
  @override
  Future<FirestoreCollectionModel<T>> get saving => throw UnimplementedError(
      "Save process should be done for each document.");

  @override
  @protected
  @mustCallSuper
  Future<void> onLoad() async {}

  @protected
  @mustCallSuper
  Future<void> onListen() async {}

  @protected
  @mustCallSuper
  Future<void> onLoadNext() async {}

  @override
  @protected
  @mustCallSuper
  Future<void> onDidLoad() async {}

  @protected
  @mustCallSuper
  Future<void> onDidListen() async {}

  @protected
  @mustCallSuper
  Future<void> onDidLoadNext() async {}

  /// Callback after the load has been done.
  @override
  @protected
  @mustCallSuper
  Future<void> onSave() async => throw UnimplementedError(
      "Save process should be done for each document.");

  /// Callback after the save has been done.
  @override
  @protected
  @mustCallSuper
  Future<void> onDidSave() async => throw UnimplementedError(
      "Save process should be done for each document.");

  @override
  bool get notifyOnChangeValue => false;

  @override
  bool get notifyOnChangeList => false;

  bool get notifyOnModified => _notifyOnModified;
  // ignore: prefer_final_fields
  bool _notifyOnModified = false;

  void setNotifyOnModified(bool notify) {
    _notifyOnModified = notify;
  }

  @protected
  @mustCallSuper
  List<Query<DynamicMap>> get references => [query(firestore.collection(path))];

  @override
  @protected
  @mustCallSuper
  void dispose() {
    super.dispose();
    FirebaseAuthCore.removeListenerOnUnauthorized(_handledOnUnauthorized);
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();
  }

  Future<void> _handledOnUnauthorized(FirebaseAuthModel auth) async {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();
  }

  @protected
  T createDocument(String path);

  T create([String? id]) =>
      createDocument("${path.trimQuery()}/${id.isEmpty ? uuid : id}");

  @override
  FirestoreCollectionModel<T> mock(List<T> mockDataList) {
    if (!Config.isEnabledMockup) {
      return this;
    }
    if (isNotEmpty) {
      return this;
    }
    if (mockDataList.isNotEmpty) {
      addAll(mockDataList);
      notifyListeners();
    }
    return this;
  }

  @override
  Future<FirestoreCollectionModel<T>> load() async {
    if (_loadingCompleter != null) {
      return loading;
    }
    _loadingCompleter = Completer<FirestoreCollectionModel<T>>();
    await FirebaseCore.initialize();
    FirebaseCore.enqueueTransaction(() async {
      try {
        await onLoad();
        await Future.wait(
          references.map((reference) => reference.get().then(_handleOnUpdate)),
        );
        await onDidLoad();
        _loadingCompleter?.complete(this);
        _loadingCompleter = null;
      } finally {
        _loadingCompleter?.completeError(e);
        _loadingCompleter = null;
      }
    });
    await _loadingCompleter!.future;
    return this;
  }

  /// Reload data and updates the data in the model.
  ///
  /// It is basically the same as the [load] method,
  /// but combining it with [loadOnce] makes it easier to manage the data.
  @override
  Future<FirestoreCollectionModel<T>> reload() async {
    clear();
    await load();
    return this;
  }

  /// If the data is empty, [load] is performed only once.
  ///
  /// In other cases, the value is returned as is.
  ///
  /// Use [isEmpty] to determine whether the file is empty or not.
  @override
  Future<FirestoreCollectionModel<T>> loadOnce() async {
    if (isEmpty) {
      return load();
    }
    return this;
  }

  Future<FirestoreCollectionModel<T>> next() async {
    if (_loadingCompleter != null) {
      return loading;
    }
    final last = length <= 0 ? null : this.last._snapshot;
    if (last == null) {
      return load();
    }
    _loadingCompleter = Completer<FirestoreCollectionModel<T>>();
    await FirebaseCore.initialize();
    FirebaseCore.enqueueTransaction(() async {
      try {
        await onLoadNext();
        await Future.wait(
          references.map((reference) =>
              reference.startAtDocument(last).get().then(_handleOnUpdate)),
        );
        await onDidLoadNext();
        _loadingCompleter?.complete(this);
        _loadingCompleter = null;
      } finally {
        _loadingCompleter?.completeError(e);
        _loadingCompleter = null;
      }
    });
    await _loadingCompleter!.future;
    return this;
  }

  @override
  Future<FirestoreCollectionModel<T>> listen() async {
    if (subscriptions.isNotEmpty) {
      return this;
    }
    if (_loadingCompleter != null) {
      return loading;
    }
    _loadingCompleter = Completer<FirestoreCollectionModel<T>>();
    await FirebaseCore.initialize();
    FirebaseCore.enqueueTransaction(() async {
      try {
        await onLoad();
        subscriptions.addAll(
          references.map(
            (reference) => reference.snapshots().listen(_handleOnUpdate),
          ),
        );
        await onDidListen();
        _loadingCompleter?.complete(this);
        _loadingCompleter = null;
      } finally {
        _loadingCompleter?.completeError(e);
        _loadingCompleter = null;
      }
    });
    await _loadingCompleter!.future;
    return this;
  }

  @override
  Future<FirestoreCollectionModel<T>> save() async {
    throw UnimplementedError("Save process should be done for each document.");
  }

  void _handleOnUpdate(QuerySnapshot<DynamicMap> snapshot) {
    bool notify = false;
    for (final doc in snapshot.docChanges) {
      final found = firstWhereOrNull(
          (element) => doc.doc.reference.path == element._reference?.path);
      switch (doc.type) {
        case DocumentChangeType.added:
          if (found != null) {
            continue;
          }
          final value = createDocument(doc.doc.reference.path.trimQuery());
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
            if (notifyOnModified) {
              notify = true;
            }
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
      notifyListeners();
    }
  }
}
