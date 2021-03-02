part of firebase_model_notifier;

final functionsDocumentProvider =
    ModelProvider.family<FirebaseFunctionsDynamicDocumentModel, String>(
  (_, endpoint) => FirebaseFunctionsDynamicDocumentModel(endpoint),
);

class FirebaseFunctionsDynamicDocumentModel
    extends FirebaseFunctionsDocumentModel<Map<String, dynamic>>
    with MapModelMixin<dynamic> {
  FirebaseFunctionsDynamicDocumentModel(String endpoint,
      [Map<String, dynamic>? map])
      : super(endpoint, map ?? {});

  @override
  @protected
  bool get notifyOnChangeMap => false;

  @override
  @protected
  Map<String, dynamic> get initialValue => {};

  @override
  Map<String, dynamic> fromMap(Map<String, dynamic> map) =>
      map.cast<String, dynamic>();

  @override
  Map<String, dynamic> toMap(Map<String, dynamic> value) =>
      value.cast<String, Object>();
}
