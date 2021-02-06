part of firestore_model_notifier;

mixin FirestoreSearchMixin<T extends FirestoreDocumentModel>
    on FirestoreCollectionModel<T> {
  String _searchText = "";
  @protected
  String get searchValueKey => "@search";

  @override
  @protected
  @mustCallSuper
  Query query(Query query) {
    if (_searchText.isEmpty) {
      return query;
    }
    final tmp = [];
    _searchText.toLowerCase().splitByBigram().forEach((text) {
      if (tmp.contains(text)) {
        return;
      }
      tmp.add(text);
      query = query.where("$searchValueKey.$text", isEqualTo: true);
    });
    return query;
  }

  Future<List<T>> search(String search) async {
    if (_searchText == search) {
      return this;
    }
    _searchText = search;
    clear();
    await load();
    return this;
  }

  @override
  Future listen() {
    throw UnimplementedError(
        "In the case of search processing, Listen is not possible.");
  }
}
