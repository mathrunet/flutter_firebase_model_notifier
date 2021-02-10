part of firestore_model_notifier;

mixin FirestoreDocumentMetaMixin<T> on FirestoreDocumentModel<T> {
  @override
  @protected
  @mustCallSuper
  Map<String, Object> filterOnSave(Map<String, Object> save) {
    save[timeValueKey] = Timestamp.fromDate(DateTime.now());
    save[uidValueKey] = reference.id;
    return super.filterOnSave(save);
  }
}
