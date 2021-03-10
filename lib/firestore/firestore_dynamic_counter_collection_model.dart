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
  @protected
  String get counterValueKey =>
      (paramaters.containsKey("count") ? paramaters["count"] : "count") ??
      "count";

  @override
  @protected
  List<FirestoreCounterUpdaterInterval> get intervals => [
        if (paramaters.containsKey("enableDaily"))
          FirestoreCounterUpdaterInterval.daily,
        if (paramaters.containsKey("enableMonthly"))
          FirestoreCounterUpdaterInterval.monthly,
        if (paramaters.containsKey("enableWeekly"))
          FirestoreCounterUpdaterInterval.weekly,
        if (paramaters.containsKey("enableYearly"))
          FirestoreCounterUpdaterInterval.yearly
      ];
}
