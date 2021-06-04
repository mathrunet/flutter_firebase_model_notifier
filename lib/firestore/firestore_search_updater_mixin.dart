part of firebase_model_notifier;

mixin FirestoreSearchUpdaterMixin<T> on FirestoreDocumentModel<T> {
  @protected
  String get searchValueKey => MetaConst.search;

  @protected
  List<String> get searchableKey;

  @override
  @protected
  @mustCallSuper
  DynamicMap filterOnSave(DynamicMap save) {
    var tmp = "";
    for (final key in searchableKey) {
      if (key.isEmpty || !save.containsKey(key)) {
        continue;
      }
      final val = save.get(key, "");
      tmp += val;
    }
    if (tmp.isEmpty) {
      return super.filterOnSave(save);
    }
    save[searchValueKey] = tmp
        .toLowerCase()
        .splitByBigram()
        .toMap<String, bool>(key: (val) => val, value: (val) => true);
    return super.filterOnSave(save);
  }
}
