part of firebase_model_notifier;

mixin FirestoreDocumentMetaMixin<T> on FirestoreDocumentModel<T> {
  @override
  @protected
  @mustCallSuper
  Map<String, dynamic> filterOnSave(Map<String, dynamic> save) {
    save[timeValueKey] = FieldValue.serverTimestamp();
    save[uidValueKey] = reference.id;
    final language = Localize.language;
    if (language.isNotEmpty) {
      save[localeValueKey] = language;
    }
    return super.filterOnSave(save);
  }
}
