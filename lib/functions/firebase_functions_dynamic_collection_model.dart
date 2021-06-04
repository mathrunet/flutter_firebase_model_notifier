part of firebase_model_notifier;

final functionsCollectionProvider =
    ModelProvider.family<FirebaseFunctionsDynamicCollectionModel, String>(
  (_, endpoint) => FirebaseFunctionsDynamicCollectionModel(endpoint),
);

class FirebaseFunctionsDynamicCollectionModel
    extends FirebaseFunctionsCollectionModel<DynamicMap> {
  FirebaseFunctionsDynamicCollectionModel(String endpoint,
      [List<MapModel<dynamic>>? value])
      : super(endpoint, value ?? []);

  @override
  List<DynamicMap> fromCollection(List<Object> list) => list.cast<DynamicMap>();

  @override
  List<Object> toCollection(List<DynamicMap> list) => list.cast<Object>();

  @override
  DynamicMap createDocument() => {};
}
