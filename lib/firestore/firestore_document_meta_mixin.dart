part of firestore_model_notifier;

mixin FirestoreDocumentMetaMixin<T> on FirestoreDocumentModel<T> {
  @override
  @protected
  @mustCallSuper
  Map<String, dynamic> filterOnSave(Map<String, dynamic> save) {
    save[timeValueKey] = Timestamp.fromDate(DateTime.now());
    save[uidValueKey] = reference.id;
    return super.filterOnSave(save);
  }
}
