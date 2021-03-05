part of firebase_model_notifier;

final firestoreSearchableDocumentProvider =
    ModelProvider.family<FirestoreDynamicSearchableDocumentModel, String>(
  (_, path) => FirestoreDynamicSearchableDocumentModel(path),
);

class FirestoreDynamicSearchableDocumentModel
    extends FirestoreDynamicDocumentModel with FirestoreSearchUpdaterMixin {
  FirestoreDynamicSearchableDocumentModel(String path) : super(path);

  @override
  List<String> get searchableKey =>
      (paramaters.containsKey("search")
          ? paramaters["search"]?.split(",")
          : const ["name", "text"]) ??
      const ["name", "text"];
}
