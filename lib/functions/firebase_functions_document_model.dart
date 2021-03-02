part of firebase_model_notifier;

abstract class FirebaseFunctionsDocumentModel<T> extends DocumentModel<T> {
  FirebaseFunctionsDocumentModel(this.endpoint, T initialValue)
      : super(initialValue);

  @override
  @protected
  @mustCallSuper
  void initState() {
    super.initState();
    value ??= initialValue;
  }

  @protected
  FirebaseFunctions get functions {
    return FirebaseFunctions.instance;
  }

  @protected
  T get initialValue;

  final String endpoint;

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
  void onCatchResponse(HttpsCallableResult<String> response) {}

  @protected
  Map<String, dynamic> fromResponse(String json) => jsonDecodeAsMap(json);

  @protected
  @mustCallSuper
  Map<String, dynamic> filterOnCall(Map<String, dynamic> loaded) => loaded;

  Future<T> call({Map<String, dynamic>? parameters}) async {
    await onLoad();
    final res = await functions
        .httpsCallable(endpoint.split("/").last)
        .call<String>(parameters);
    onCatchResponse(res);
    value = fromMap(filterOnCall(fromResponse(res.data)));
    streamController.sink.add(value);
    notifyListeners();
    await onDidLoad();
    return value;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) => hashCode == other.hashCode;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => super.hashCode ^ endpoint.hashCode;
}
