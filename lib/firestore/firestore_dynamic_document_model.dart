part of firebase_model_notifier;

final firestoreDocumentProvider =
    ModelProvider.family<FirestoreDynamicDocumentModel, String>(
  (_, path) => FirestoreDynamicDocumentModel(path),
);

class FirestoreDynamicDocumentModel extends FirestoreDocumentModel<DynamicMap>
    with MapModelMixin<String, dynamic>, FirestoreDocumentMetaMixin<DynamicMap>
    implements DynamicDocumentModel {
  FirestoreDynamicDocumentModel(String path, [DynamicMap? map])
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 0),
            "The path hierarchy must be an even number."),
        super(path, map ?? {});

  @override
  @protected
  bool get notifyOnChangeMap => false;

  @override
  DynamicMap fromMap(DynamicMap map) => map.cast<String, dynamic>();

  @override
  DynamicMap toMap(DynamicMap value) => value.cast<String, Object>();
}
