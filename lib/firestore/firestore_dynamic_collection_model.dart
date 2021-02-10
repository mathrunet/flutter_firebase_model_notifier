part of firestore_model_notifier;

class FirestoreDynamicCollectionModel
    extends FirestoreCollectionModel<FirestoreDynamicDocumentModel> {
  FirestoreDynamicCollectionModel(String path,
      [List<FirestoreDynamicDocumentModel> value = const []])
      : assert(!(path.splitLength() <= 0 || path.splitLength() % 2 != 1),
            "The path hierarchy must be an odd number."),
        super(path, value);

  @override
  @protected
  FirestoreDynamicDocumentModel createDocument(String path) =>
      FirestoreDynamicDocumentModel(path);
}
