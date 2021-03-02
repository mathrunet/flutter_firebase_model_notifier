part of firebase_model_notifier;

abstract class FirebaseFunctionsModel<T> extends ValueModel<T> {
  FirebaseFunctionsModel(this.endpoint, T initialValue) : super(initialValue);

  @protected
  FirebaseFunctions get functions {
    return FirebaseFunctions.instance;
  }

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
  T fromResponse(String data);

  @protected
  @mustCallSuper
  T filterOnCall(T loaded) => loaded;

  Future<T> call({Map<String, dynamic>? parameters}) async {
    await onLoad();
    final res = await functions
        .httpsCallable(endpoint.split("/").last)
        .call<String>(parameters);
    onCatchResponse(res);
    value = filterOnCall(fromResponse(res.data));
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
