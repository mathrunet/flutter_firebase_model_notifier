part of firebase_model_notifier;

abstract class FirestoreDocumentModel<T> extends DocumentModel<T>
    implements
        StoredModel<T, FirestoreDocumentModel<T>>,
        ListenedModel<T, FirestoreDocumentModel<T>>,
        DocumentMockModel<T, FirestoreDocumentModel<T>> {
  FirestoreDocumentModel(String path, T value)
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 0),
            "The path hierarchy must be an even number."),
        path = _getPath(path),
        paramaters = _getParamaters(path),
        super(value);

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

  final String uidValueKey = "uid";
  final String timeValueKey = "time";
  final String localeValueKey = "@locale";

  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    if (Config.isMockup) {
      value = fromMap(filterOnLoad(initialMock));
    }
  }

  @override
  @protected
  final Map<String, dynamic> initialMock = const {};

  @override
  void dispose() {
    super.dispose();
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    subscriptions.clear();
  }

  final String path;
  final Map<String, String> paramaters;

  final List<StreamSubscription> subscriptions = [];

  DocumentSnapshot? _snapshot;
  DocumentReference? _reference;

  @protected
  @mustCallSuper
  Future<void> onLoad() async {}

  @protected
  @mustCallSuper
  Future<void> onListen() async {}

  @protected
  @mustCallSuper
  Future<void> onSave() async {}

  @protected
  @mustCallSuper
  Future<void> onDelete() async {}

  @protected
  @mustCallSuper
  Future<void> onDidLoad() async {}

  @protected
  @mustCallSuper
  Future<void> onDidListen() async {}

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
  Map<String, dynamic> filterOnLoad(Map<String, dynamic> loaded) => loaded;

  @protected
  @mustCallSuper
  Map<String, dynamic> filterOnSave(Map<String, dynamic> save) => save;

  @protected
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  DocumentReference get reference {
    if (_reference != null) {
      return _reference!;
    }
    return firestore.doc(path);
  }

  @override
  FirestoreDocumentModel<T> mock(Map<String, dynamic> mockData) {
    if (!Config.isMockup) {
      return this;
    }
    value = fromMap(filterOnLoad(mockData));
    notifyListeners();
    return this;
  }

  @override
  Future<FirestoreDocumentModel<T>> load() async {
    await FirebaseCore.initialize();
    await onLoad();
    await Future.delayed(Duration(milliseconds: Random().nextInt(100)));
    await reference.get().then(_handleOnUpdate);
    await onDidLoad();
    return this;
  }

  @override
  Future<FirestoreDocumentModel<T>> listen() async {
    if (subscriptions.isNotEmpty) {
      return this;
    }
    await FirebaseCore.initialize();
    await onListen();
    await Future.delayed(Duration(milliseconds: Random().nextInt(100)));
    subscriptions.add(
      reference.snapshots().listen(_handleOnUpdate),
    );
    await onDidListen();
    return this;
  }

  void _handleOnUpdate(DocumentSnapshot snapshot) {
    value = fromMap(filterOnLoad(snapshot.data()?.cast() ?? {}));
    notifyListeners();
  }

  @override
  Future<FirestoreDocumentModel<T>> save() async {
    await FirebaseCore.initialize();
    await onSave();
    await reference.set(filterOnSave(toMap(value)), SetOptions(merge: true));
    await onDidSave();
    return this;
  }

  Future<void> delete() async {
    await FirebaseCore.initialize();
    await onDelete();
    await reference.delete();
    await onDidDelete();
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
