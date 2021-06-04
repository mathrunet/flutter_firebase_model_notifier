part of firebase_model_notifier;

final functionsDocumentProvider =
    ModelProvider.family<FirebaseFunctionsDynamicDocumentModel, String>(
  (_, endpoint) => FirebaseFunctionsDynamicDocumentModel(endpoint),
);

class FirebaseFunctionsDynamicDocumentModel
    extends FirebaseFunctionsDocumentModel<DynamicMap>
    with MapModelMixin<dynamic> {
  FirebaseFunctionsDynamicDocumentModel(String endpoint, [DynamicMap? map])
      : super(endpoint, map ?? {});

  @override
  @protected
  bool get notifyOnChangeMap => false;

  @override
  @protected
  DynamicMap get initialValue => {};

  @override
  DynamicMap fromMap(DynamicMap map) => map.cast<String, dynamic>();

  @override
  DynamicMap toMap(DynamicMap value) => value.cast<String, Object>();
}
