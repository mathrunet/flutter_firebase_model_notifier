part of firebase_model_notifier;

mixin FirestoreCollectionQueryMixin<T extends FirestoreDocumentModel>
    on FirestoreCollectionModel<T> {
  @override
  @protected
  @mustCallSuper
  Query<DynamicMap> query(Query<DynamicMap> query) {
    if (parameters.isNotEmpty) {
      if (parameters.containsKey("key") && parameters["key"].isNotEmpty) {
        if (parameters.containsKey("equalTo") &&
            parameters["equalTo"].isNotEmpty) {
          query = query.where(parameters["key"]!,
              isEqualTo: FirestoreUtility._parse(parameters["equalTo"]));
        }
        if (parameters.containsKey("notEqualTo") &&
            parameters["noteEqualTo"].isNotEmpty) {
          query = query.where(parameters["key"]!,
              isNotEqualTo: FirestoreUtility._parse(parameters["noteEqualTo"]));
        }
        if (parameters.containsKey("startAt") &&
            parameters["startAt"].isNotEmpty) {
          query = query.where(parameters["key"]!,
              isGreaterThanOrEqualTo: num.parse(parameters["startAt"]!));
        }
        if (parameters.containsKey("endAt") && parameters["endAt"].isNotEmpty) {
          query = query.where(parameters["key"]!,
              isLessThanOrEqualTo: num.parse(parameters["endAt"]!));
        }
        if (parameters.containsKey("contains") &&
            parameters["contains"].isNotEmpty) {
          query = query.where(parameters["key"]!,
              arrayContains: FirestoreUtility._parse(parameters["contains"]));
        }
      }
      if (parameters.containsKey("limitToFirst") &&
          parameters["limitToFirst"].isNotEmpty) {
        query = query.limit(int.parse(parameters["limitToFirst"]!));
      }
      if (parameters.containsKey("limitToLast") &&
          parameters["limitToLast"].isNotEmpty) {
        query = query.limitToLast(int.parse(parameters["limitToLast"]!));
      }
      if (parameters.containsKey("orderByDesc") &&
          parameters["orderByDesc"].isNotEmpty) {
        if (!(parameters.containsKey("key") &&
            parameters["key"] == parameters["orderByDesc"] &&
            (parameters.containsKey("equalTo") ||
                parameters.containsKey("notEqualTo") ||
                parameters.containsKey("containsAny") ||
                parameters.containsKey("whereIn") ||
                parameters.containsKey("whereNotIn")))) {
          query = query.orderBy(parameters["orderByDesc"]!, descending: true);
        }
      }
      if (parameters.containsKey("orderByAsc") &&
          parameters["orderByAsc"].isNotEmpty) {
        if (!(parameters.containsKey("key") &&
            parameters["key"] == parameters["orderByAsc"] &&
            (parameters.containsKey("equalTo") ||
                parameters.containsKey("notEqualTo") ||
                parameters.containsKey("containsAny") ||
                parameters.containsKey("whereIn") ||
                parameters.containsKey("whereNotIn")))) {
          query = query.orderBy(parameters["orderByAsc"]!);
        }
      }
    }
    return super.query(query);
  }

  @override
  @protected
  @mustCallSuper
  List<Query<DynamicMap>> get references {
    if (parameters.containsKey("key")) {
      if (parameters.containsKey("containsAny") &&
          parameters["containsAny"].isNotEmpty) {
        final items = parameters["containsAny"]?.split(",") ?? <String>[];
        if (items.isNotEmpty) {
          final queries = <Query<DynamicMap>>[];
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
        }
      } else if (parameters.containsKey("whereIn") &&
          parameters["whereIn"].isNotEmpty) {
        final items = parameters["whereIn"]?.split(",") ?? <String>[];
        if (items.isNotEmpty) {
          final queries = <Query<DynamicMap>>[];
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
      } else if (parameters.containsKey("whereNotIn") &&
          parameters["whereNotIn"].isNotEmpty) {
        final items = parameters["whereNotIn"]?.split(",") ?? <String>[];
        if (items.isNotEmpty) {
          final queries = <Query<DynamicMap>>[];
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
      }
    }
    return super.references;
  }
}
