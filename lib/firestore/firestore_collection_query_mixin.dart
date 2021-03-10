part of firebase_model_notifier;

mixin FirestoreCollectionQueryMixin<T extends FirestoreDocumentModel>
    on FirestoreCollectionModel<T> {
  @override
  @protected
  @mustCallSuper
  Query query(Query query) {
    if (paramaters.isNotEmpty) {
      if (!paramaters.containsKey("key")) {
        return query;
      }
      if (paramaters.containsKey("equalTo")) {
        query = query.where(paramaters["key"],
            isEqualTo: FirestoreUtility._parse(paramaters["equalTo"]));
      }
      if (paramaters.containsKey("notEqualTo")) {
        query = query.where(paramaters["key"],
            isNotEqualTo: FirestoreUtility._parse(paramaters["noteEqualTo"]));
      }
      if (paramaters.containsKey("startAt")) {
        query = query.where(paramaters["key"],
            isGreaterThanOrEqualTo: num.parse(paramaters["startAt"] ?? "0"));
      }
      if (paramaters.containsKey("endAt")) {
        query = query.where(paramaters["key"],
            isLessThanOrEqualTo: num.parse(paramaters["endAt"] ?? "0"));
      }
      if (paramaters.containsKey("contains")) {
        query = query.where(paramaters["key"],
            arrayContains: FirestoreUtility._parse(paramaters["contains"]));
      }
      if (paramaters.containsKey("limitToFirst")) {
        query = query.limit(int.parse(paramaters["limitToFirst"] ?? "0"));
      }
      if (paramaters.containsKey("limitToLast")) {
        query = query.limitToLast(int.parse(paramaters["limitToLast"] ?? "0"));
      }
      if (paramaters.containsKey("orderByDesc")) {
        query = query.orderBy(paramaters["orderByDesc"], descending: true);
      }
      if (paramaters.containsKey("orderByAsc")) {
        query = query.orderBy(paramaters["orderByAsc"]);
      }
    }
    return super.query(query);
  }

  @override
  @protected
  @mustCallSuper
  List<Query> get references {
    if (paramaters.containsKey("containsAny")) {
      final queries = <Query>[];
      final items = paramaters["containsAny"]?.split(",") ?? <String>[];
      for (var i = 0; i < items.length; i += 10) {
        queries.add(
          query(
            firestore.collection(path.split("?").first),
          ).where(
            paramaters["key"],
            arrayContainsAny: items
                .sublist(
                  i,
                  min(i + 10, items.length),
                )
                .map((e) => FirestoreUtility._parse(e))
                .toList(),
          ),
        );
      }
      return queries;
    } else if (paramaters.containsKey("whereIn")) {
      final queries = <Query>[];
      final items = paramaters["whereIn"]?.split(",") ?? <String>[];
      for (var i = 0; i < items.length; i += 10) {
        queries.add(
          query(
            firestore.collection(path.split("?").first),
          ).where(
            paramaters["key"],
            whereIn: items
                .sublist(
                  i,
                  min(i + 10, items.length),
                )
                .map((e) => FirestoreUtility._parse(e))
                .toList(),
          ),
        );
      }
      return queries;
    } else if (paramaters.containsKey("whereNotIn")) {
      final queries = <Query>[];
      final items = paramaters["whereNotIn"]?.split(",") ?? <String>[];
      for (var i = 0; i < items.length; i += 10) {
        queries.add(
          query(
            firestore.collection(path.split("?").first),
          ).where(
            paramaters["key"],
            whereIn: items
                .sublist(
                  i,
                  min(i + 10, items.length),
                )
                .map((e) => FirestoreUtility._parse(e))
                .toList(),
          ),
        );
      }
      return queries;
    }
    return super.references;
  }
}
