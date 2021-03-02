part of firebase_model_notifier;

final firestoreSearchableCollectionProvider =
    ModelProvider.family<FirestoreDynamicSearchableCollectionModel, String>(
  (_, path) => FirestoreDynamicSearchableCollectionModel(path),
);

class FirestoreDynamicSearchableCollectionModel
    extends FirestoreCollectionModel<FirestoreDynamicDocumentModel>
    with FirestoreSearchQueryMixin {
  FirestoreDynamicSearchableCollectionModel(String path) : super(path);

  @override
  @protected
  FirestoreDynamicDocumentModel createDocument(String path) =>
      FirestoreDynamicDocumentModel(path);
}
