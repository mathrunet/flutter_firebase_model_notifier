part of firebase_model_notifier;

final functionsCollectionProvider =
    ModelProvider.family<FirebaseFunctionsDynamicCollectionModel, String>(
  (_, endpoint) => FirebaseFunctionsDynamicCollectionModel(endpoint),
);

class FirebaseFunctionsDynamicCollectionModel
    extends FirebaseFunctionsCollectionModel<Map<String, dynamic>> {
  FirebaseFunctionsDynamicCollectionModel(String endpoint,
      [List<MapModel<dynamic>>? value])
      : super(endpoint, value ?? []);

  @override
  List<Map<String, dynamic>> fromCollection(List<Object> list) =>
      list.cast<Map<String, dynamic>>();

  @override
  List<Object> toCollection(List<Map<String, dynamic>> list) =>
      list.cast<Object>();

  @override
  Map<String, dynamic> createDocument() => {};
}
