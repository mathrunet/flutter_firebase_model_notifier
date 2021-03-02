part of firebase_model_notifier;

abstract class FirebaseFunctionsCollectionModel<T> extends ValueModel<List<T>>
    with ListModelMixin<T> {
  FirebaseFunctionsCollectionModel(this.endpoint, [List<T>? value])
      : super(value ?? []);

  @protected
  FirebaseFunctions get functions {
    return FirebaseFunctions.instance;
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
  void onCatchResponse(HttpsCallableResult<String> response) {}

  @protected
  List<Object> fromResponse(String json) => jsonDecodeAsList(json);

  @protected
  @mustCallSuper
  List<Object> filterOnCall(List<Object> loaded) => loaded;

  @protected
  T createDocument();

  T create() => createDocument();

  Future<List<T>> call({Map<String, dynamic>? parameters}) async {
    await onLoad();
    final res = await functions
        .httpsCallable(endpoint.split("/").last)
        .call<String>(parameters);
    onCatchResponse(res);
    final data = fromCollection(filterOnCall(fromResponse(res.data)));
    addAll(data);
    streamController.sink.add(value);
    notifyListeners();
    await onDidLoad();
    return this;
  }
}
