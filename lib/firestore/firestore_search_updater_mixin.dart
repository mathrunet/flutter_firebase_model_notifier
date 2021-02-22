part of firestore_model_notifier;

mixin FirestoreSearchUpdaterMixin<T> on FirestoreDocumentModel<T> {
  @protected
  String get searchValueKey => "@search";

  @protected
  List<String> get searchableKey;

  @override
  @protected
  @mustCallSuper
  Map<String, dynamic> filterOnSave(Map<String, dynamic> save) {
    var tmp = "";
    for (final key in searchableKey) {
      if (key.isEmpty || !save.containsKey(key)) {
        continue;
      }
      final val = save.get(key, "");
      tmp += val ?? "";
    }
    if (tmp.isEmpty) {
      return super.filterOnSave(save);
    }
    save[searchValueKey] = tmp
        .splitByBigram()
        .toMap<String, bool>(key: (val) => val, value: (val) => true);
    return super.filterOnSave(save);
  }
}
