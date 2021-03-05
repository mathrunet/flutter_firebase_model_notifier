part of firebase_model_notifier;

final firestoreCounterCollectionProvider =
    ModelProvider.family<FirestoreDynamicCounterCollectionModel, String>(
  (_, path) => FirestoreDynamicCounterCollectionModel(path),
);

class FirestoreDynamicCounterCollectionModel
    extends FirestoreDynamicCollectionModel with FirestoreCounterUpdaterMixin {
  FirestoreDynamicCounterCollectionModel(String path) : super(path);

  @override
  @protected
  FirestoreDynamicDocumentModel createDocument(String path) =>
      FirestoreDynamicDocumentModel(path);

  @override
  String get counterValueKey =>
      (paramaters.containsKey("count") ? paramaters["count"] : "count") ??
      "count";
}
