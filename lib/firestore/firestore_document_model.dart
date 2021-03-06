part of firebase_model_notifier;

abstract class FirestoreDocumentModel<T> extends DocumentModel<T>
    implements
        StoredModel<T, FirestoreDocumentModel<T>>,
        ListenedModel<T, FirestoreDocumentModel<T>>,
        DocumentMockModel<T, FirestoreDocumentModel<T>> {
  FirestoreDocumentModel(String path, T value)
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 0),
            "The path hierarchy must be an even number."),
        path = path.trimQuery(),
        parameters = _getParameters(path),
        super(value);

  static Map<String, String> _getParameters(String path) {
    if (path.contains("?")) {
      return Uri.parse(path).queryParameters;
    }
    return const {};
  }

  /// Key for UID values.
  final String uidValueKey = Const.uid;

  /// Key for time values.
  final String timeValueKey = Const.time;

  /// Key for locale values.
  final String localeValueKey = MetaConst.locale;

  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    if (Config.isEnabledMockup && initialMock != null) {
      // ignore: null_check_on_nullable_type_parameter
      value = initialMock!;
    }
  }

  @override
  @protected
  final T? initialMock = null;

  @override
  @protected
  @mustCallSuper
  void dispose() {
    super.dispose();
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();
  }

  final String path;
  final Map<String, String> parameters;

  final List<StreamSubscription> subscriptions = [];

  DocumentSnapshot<DynamicMap>? _snapshot;
  DocumentReference<DynamicMap>? _reference;

  /// Returns itself after the load/save finishes.
  @override
  Future<void>? get future => _completer?.future;
  Completer<void>? _completer;

  /// It becomes `true` after [loadOnce] is executed.
  @override
  bool loaded = false;

  @override
  @protected
  @mustCallSuper
  Future<void> onLoad() async {}

  @protected
  @mustCallSuper
  Future<void> onListen() async {}

  @override
  @protected
  @mustCallSuper
  Future<void> onSave() async {}

  @protected
  @mustCallSuper
  Future<void> onDelete() async {}

  @override
  @protected
  @mustCallSuper
  Future<void> onDidLoad() async {}

  @protected
  @mustCallSuper
  Future<void> onDidListen() async {}

  @override
  @protected
  @mustCallSuper
  Future<void> onDidSave() async {}

  @protected
  @mustCallSuper
  Future<void> onDidDelete() async {}

  @override
  bool get notifyOnChangeValue => false;

  @protected
  @mustCallSuper
  DynamicMap filterOnLoad(DynamicMap loaded) => loaded;

  @protected
  @mustCallSuper
  DynamicMap filterOnSave(DynamicMap save) => save;

  @protected
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  DocumentReference<DynamicMap> get reference {
    if (_reference != null) {
      return _reference!;
    }
    return firestore.doc(path);
  }

  @override
  FirestoreDocumentModel<T> mock(T mockData) {
    if (!Config.isEnabledMockup) {
      return this;
    }
    if (value == mockData) {
      return this;
    }
    value = mockData;
    notifyListeners();
    return this;
  }

  @override
  Future<FirestoreDocumentModel<T>> load() async {
    if (_completer != null) {
      await future;
      return this;
    }
    _completer = Completer<void>();
    await FirebaseCore.initialize();
    FirebaseCore.enqueueTransaction(() async {
      if (_completer == null) {
        return;
      }
      try {
        await onLoad();
        if (_completer == null) {
          return;
        }
        await reference.get().then(_handleOnUpdate);
        await onDidLoad();
        _completer?.complete();
        _completer = null;
      } catch (e) {
        _completer?.completeError(e);
        _completer = null;
      } finally {
        _completer?.complete();
        _completer = null;
      }
    });
    await future;
    return this;
  }

  @override
  Future<FirestoreDocumentModel<T>> listen() async {
    if (subscriptions.isNotEmpty) {
      return this;
    }
    if (_completer != null) {
      await future;
      return this;
    }
    _completer = Completer<void>();
    await FirebaseCore.initialize();
    FirebaseCore.enqueueTransaction(() async {
      if (subscriptions.isNotEmpty) {
        return;
      }
      if (_completer == null) {
        return;
      }
      try {
        await onListen();
        if (subscriptions.isNotEmpty) {
          return;
        }
        if (_completer == null) {
          return;
        }
        final stream = reference.snapshots();
        subscriptions.add(stream.listen(_handleOnUpdate));
        await stream.first;
        await onDidListen();
        _completer?.complete();
        _completer = null;
      } catch (e) {
        _completer?.completeError(e);
        _completer = null;
      } finally {
        _completer?.complete();
        _completer = null;
      }
    });
    await future;
    return this;
  }

  void _handleOnUpdate(DocumentSnapshot<DynamicMap> snapshot) {
    value = fromMap(filterOnLoad(snapshot.data()?.cast() ?? {}));
    notifyListeners();
  }

  @override
  Future<FirestoreDocumentModel<T>> save() async {
    if (_completer != null) {
      await future;
      return this;
    }
    _completer = Completer<void>();
    await FirebaseCore.initialize();
    FirebaseCore.enqueueTransaction(() async {
      if (_completer == null) {
        return;
      }
      try {
        await onSave();
        if (_completer == null) {
          return;
        }
        await reference.set(filterOnSave(toMap(value)));
        await onDidSave();
        _completer?.complete();
        _completer = null;
      } catch (e) {
        _completer?.completeError(e);
        _completer = null;
      } finally {
        _completer?.complete();
        _completer = null;
      }
    });
    await future;
    return this;
  }

  /// Reload data and updates the data in the model.
  ///
  /// It is basically the same as the [load] method,
  /// but combining it with [loadOnce] makes it easier to manage the data.
  @override
  Future<FirestoreDocumentModel<T>> reload() => load();

  /// If the data is empty, [load] is performed only once.
  ///
  /// In other cases, the value is returned as is.
  ///
  /// Use [isEmpty] to determine whether the file is empty or not.
  @override
  Future<FirestoreDocumentModel<T>> loadOnce() async {
    if (!loaded) {
      loaded = true;
      return load();
    }
    return this;
  }

  /// Delete this document.
  Future<void> delete() async {
    if (_completer != null) {
      await future;
      return;
    }
    _completer = Completer<void>();
    await FirebaseCore.initialize();
    FirebaseCore.enqueueTransaction(() async {
      if (_completer == null) {
        return;
      }
      try {
        await onDelete();
        if (_completer == null) {
          return;
        }
        await reference.delete();
        await onDidDelete();
        _completer?.complete();
        _completer = null;
      } catch (e) {
        _completer?.completeError(e);
        _completer = null;
      } finally {
        _completer?.complete();
        _completer = null;
      }
    });
    await future;
  }

  /// The equality operator.
  ///
  /// The default behavior for all [Object]s is to return true if and only if this object and [other] are the same object.
  ///
  /// Override this method to specify a different equality relation on a class. The overriding method must still be an equivalence relation. That is, it must be:
  ///
  /// Total: It must return a boolean for all arguments. It should never throw.
  ///
  /// Reflexive: For all objects o, o == o must be true.
  ///
  /// Symmetric: For all objects o1 and o2, o1 == o2 and o2 == o1 must either both be true, or both be false.
  ///
  /// Transitive: For all objects o1, o2, and o3, if o1 == o2 and o2 == o3 are true, then o1 == o3 must be true.
  ///
  /// The method should also be consistent over time, so whether two objects are equal should only change if at least one of the objects was modified.
  ///
  /// If a subclass overrides the equality operator, it should override the [hashCode] method as well to maintain consistency.
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) => hashCode == other.hashCode;

  /// The hash code for this object.
  ///
  /// A hash code is a single integer which represents the state of the object that affects [operator ==] comparisons.
  ///
  /// All objects have hash codes. The default hash code implemented by [Object] represents only the identity of the object,
  /// the same way as the default [operator ==] implementation only considers objects equal if they are identical (see [identityHashCode]).
  ///
  /// If [operator ==] is overridden to use the object state instead,
  /// the hash code must also be changed to represent that state,
  /// otherwise the object cannot be used in hash based data structures like the default [Set] and [Map] implementations.
  ///
  /// Hash codes must be the same for objects that are equal to each other according to [operator ==].
  /// The hash code of an object should only change if the object changes in a way that affects equality.
  /// There are no further requirements for the hash codes. They need not be consistent between executions of the same program and there are no distribution guarantees.
  ///
  /// Objects that are not equal are allowed to have the same hash code.
  /// It is even technically allowed that all instances have the same hash code,
  /// but if clashes happen too often, it may reduce the efficiency of hash-based data structures like [HashSet] or [HashMap].
  ///
  /// If a subclass overrides [hashCode],
  /// it should override the [operator ==] operator as well to maintain consistency.
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => super.hashCode ^ path.hashCode;

  void _notifyListeners() {
    notifyListeners();
  }
}
