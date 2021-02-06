part of firestore_model_notifier;

abstract class FirestoreDocumentModel<T> extends DocumentModel<T> {
  FirestoreDocumentModel(this.path, T value)
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 0),
            "The path hierarchy must be an even number."),
        super(value);

  String get uidValueKey => "uid";
  String get timeValueKey => "time";

  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    value = initialValue;
  }

  @protected
  T get initialValue;

  final String path;

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

  @protected
  @mustCallSuper
  Map<String, Object> filterOnLoad(Map<String, Object> loaded) => loaded;

  @protected
  @mustCallSuper
  Map<String, Object> filterOnSave(Map<String, Object> save) => save;

  @protected
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  DocumentReference get reference {
    if (_reference != null) {
      return _reference!;
    }
    return firestore.doc(path);
  }

  @override
  Future<T> load() async {
    await FirebaseInitializer.initialize();
    await onLoad();
    await Future.delayed(Duration(milliseconds: Random().nextInt(100)));
    await reference.get().then(_handleOnUpdate);
    await onDidLoad();
    return value;
  }

  Future listen() async {
    await FirebaseInitializer.initialize();
    await onListen();
    await Future.delayed(Duration(milliseconds: Random().nextInt(100)));
    reference.snapshots().listen(_handleOnUpdate);
    await onDidListen();
  }

  void _handleOnUpdate(DocumentSnapshot snapshot) {
    value = fromMap(filterOnLoad(snapshot.data()?.cast() ?? const {}));
  }

  @override
  Future<T> save() async {
    await FirebaseInitializer.initialize();
    await onSave();
    await reference.set(filterOnSave(toMap(value)), SetOptions(merge: true));
    await onDidSave();
    return value;
  }

  Future delete() async {
    await FirebaseInitializer.initialize();
    await onDelete();
    await reference.delete();
    await onDidDelete();
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) => hashCode == other.hashCode;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => super.hashCode ^ path.hashCode;
}
