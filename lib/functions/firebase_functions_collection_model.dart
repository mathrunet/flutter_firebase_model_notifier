part of firebase_model_notifier;

abstract class FirebaseFunctionsCollectionModel<T> extends ValueModel<List<T>>
    with ListModelMixin<T> {
  FirebaseFunctionsCollectionModel(this.endpoint, [List<T>? value])
      : super(value ?? []);

  @protected
  FirebaseFunctions get functions {
    return FirebaseFunctions.instanceFor(region: FirebaseCore.region);
  }

  @override
  bool get notifyOnChangeList => false;

  @override
  bool get notifyOnChangeValue => true;

  final String endpoint;

  List<T> fromCollection(List<Object> list);
  List<Object> toCollection(List<T> list);

  @protected
  @mustCallSuper
  Future<void> onLoad() async {}

  @protected
  @mustCallSuper
  Future<void> onSave() async {}

  @protected
  @mustCallSuper
  Future<void> onDidLoad() async {}

  @protected
  @mustCallSuper
  Future<void> onDidSave() async {}

  @protected
  @mustCallSuper
  @protected
  @mustCallSuper
  void onCatchResponse(HttpsCallableResult<List> response) {}

  @protected
  List<Object> fromResponse(List list) => list.cast<Object>();

  @protected
  @mustCallSuper
  List<Object> filterOnCall(List<Object> loaded) => loaded;

  @protected
  T createDocument();

  T create() => createDocument();

  Future<List<T>> call({Map<String, dynamic>? parameters}) async {
    await FirebaseCore.initialize();
    await onLoad();
    final res = await functions
        .httpsCallable(endpoint.split("/").last)
        .call<List>(parameters);
    onCatchResponse(res);
    final data = fromCollection(filterOnCall(fromResponse(res.data)));
    addAll(data);
    notifyListeners();
    await onDidLoad();
    return this;
  }
}
