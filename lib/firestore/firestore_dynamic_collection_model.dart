part of firebase_model_notifier;

final firestoreCollectionProvider =
    ModelProvider.family<FirestoreDynamicCollectionModel, String>(
  (_, path) => FirestoreDynamicCollectionModel(path),
);

class FirestoreDynamicCollectionModel
    extends FirestoreCollectionModel<FirestoreDynamicDocumentModel>
    with FirestoreCollectionQueryMixin<FirestoreDynamicDocumentModel>
    implements DynamicCollectionModel<FirestoreDynamicDocumentModel> {
  FirestoreDynamicCollectionModel(String path,
      [List<FirestoreDynamicDocumentModel>? value])
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 1),
            "The path hierarchy must be an odd number."),
        super(path, value ?? []);

  @override
  @protected
  FirestoreDynamicDocumentModel createDocument(String path) =>
      FirestoreDynamicDocumentModel(path);
}
