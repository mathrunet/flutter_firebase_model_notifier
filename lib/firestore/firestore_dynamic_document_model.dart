part of firestore_model_notifier;

final firestoreDocumentProvider =
    ModelProvider.family.autoDispose<FirestoreDynamicDocumentModel, String>(
  (_, path) => FirestoreDynamicDocumentModel(path)..listen(),
);

class FirestoreDynamicDocumentModel
    extends FirestoreDocumentModel<Map<String, dynamic>>
    with MapModelMixin<dynamic> {
  FirestoreDynamicDocumentModel(String path, [Map<String, dynamic>? map])
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 0),
            "The path hierarchy must be an even number."),
        super(path, map ?? {});

  @override
  Map<String, dynamic> fromMap(Map<String, Object> map) =>
      map.cast<String, dynamic>();

  @override
  Map<String, Object> toMap(Map<String, dynamic> value) =>
      value.cast<String, Object>();

  @override
  @protected
  Map<String, dynamic> get initialValue => {};
}
