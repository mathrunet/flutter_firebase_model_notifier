part of firebase_model_notifier;

mixin FirestoreCollectionQueryMixin<T extends FirestoreDocumentModel>
    on FirestoreCollectionModel<T> {
  @override
  @protected
  @mustCallSuper
  Query<DynamicMap> query(Query<DynamicMap> query) {
    if (parameters.isNotEmpty) {
      if (!parameters.containsKey("key")) {
        return query;
      }
      if (parameters.containsKey("equalTo")) {
        query = query.where(parameters["key"]!,
            isEqualTo: FirestoreUtility._parse(parameters["equalTo"]));
      }
      if (parameters.containsKey("notEqualTo")) {
        query = query.where(parameters["key"]!,
            isNotEqualTo: FirestoreUtility._parse(parameters["noteEqualTo"]));
      }
      if (parameters.containsKey("startAt")) {
        query = query.where(parameters["key"]!,
            isGreaterThanOrEqualTo: num.parse(parameters["startAt"] ?? "0"));
      }
      if (parameters.containsKey("endAt")) {
        query = query.where(parameters["key"]!,
            isLessThanOrEqualTo: num.parse(parameters["endAt"] ?? "0"));
      }
      if (parameters.containsKey("contains")) {
        query = query.where(parameters["key"]!,
            arrayContains: FirestoreUtility._parse(parameters["contains"]));
      }
      if (parameters.containsKey("limitToFirst")) {
        query = query.limit(int.parse(parameters["limitToFirst"] ?? "0"));
      }
      if (parameters.containsKey("limitToLast")) {
        query = query.limitToLast(int.parse(parameters["limitToLast"] ?? "0"));
      }
      if (parameters.containsKey("orderByDesc")) {
        query = query.orderBy(parameters["orderByDesc"]!, descending: true);
      }
      if (parameters.containsKey("orderByAsc")) {
        query = query.orderBy(parameters["orderByAsc"]!);
      }
    }
    return super.query(query);
  }

  @override
  @protected
  @mustCallSuper
  List<Query<DynamicMap>> get references {
    if (parameters.containsKey("containsAny")) {
      final queries = <Query<DynamicMap>>[];
      final items = parameters["containsAny"]?.split(",") ?? <String>[];
      for (var i = 0; i < items.length; i += 10) {
        queries.add(
          query(
            firestore.collection(path.split("?").first),
          ).where(
            parameters["key"]!,
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
    } else if (parameters.containsKey("whereIn")) {
      final queries = <Query<DynamicMap>>[];
      final items = parameters["whereIn"]?.split(",") ?? <String>[];
      for (var i = 0; i < items.length; i += 10) {
        queries.add(
          query(
            firestore.collection(path.split("?").first),
          ).where(
            parameters["key"]!,
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
    } else if (parameters.containsKey("whereNotIn")) {
      final queries = <Query<DynamicMap>>[];
      final items = parameters["whereNotIn"]?.split(",") ?? <String>[];
      for (var i = 0; i < items.length; i += 10) {
        queries.add(
          query(
            firestore.collection(path.split("?").first),
          ).where(
            parameters["key"]!,
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
