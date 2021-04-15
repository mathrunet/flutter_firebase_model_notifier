part of firebase_model_notifier;

final firestoreDocumentProvider =
    ModelProvider.family<FirestoreDynamicDocumentModel, String>(
  (_, path) => FirestoreDynamicDocumentModel(path),
);

class FirestoreDynamicDocumentModel
    extends FirestoreDocumentModel<Map<String, dynamic>>
    with
        MapModelMixin<dynamic>,
        FirestoreDocumentMetaMixin<Map<String, dynamic>>
    implements DynamicDocumentModel {
  FirestoreDynamicDocumentModel(String path, [Map<String, dynamic>? map])
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 0),
            "The path hierarchy must be an even number."),
        super(path, map ?? {});

  @override
  @protected
  bool get notifyOnChangeMap => false;

  @override
  Map<String, dynamic> fromMap(Map<String, dynamic> map) =>
      map.cast<String, dynamic>();

  @override
  Map<String, dynamic> toMap(Map<String, dynamic> value) =>
      value.cast<String, Object>();
}
