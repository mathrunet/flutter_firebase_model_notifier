part of firebase_model_notifier;

@immutable
class FirestoreQuery extends CollectionQuery {
  const FirestoreQuery(
    String path, {
    String? key,
    String? orderBy,
    dynamic isEqualTo,
    dynamic isNotEqualTo,
    // dynamic isLessThan;
    dynamic isLessThanOrEqualTo,
    // dynamic isGreaterThan;
    dynamic isGreaterThanOrEqualTo,
    dynamic arrayContains,
    DynamicList? arrayContainsAny,
    DynamicList? whereIn,
    DynamicList? whereNotIn,
    // bool? isNull;
    CollectionQueryOrder order = CollectionQueryOrder.asc,
    int? limit,
  }) : super(
          path,
          key: key,
          orderBy: orderBy,
          isEqualTo: isEqualTo,
          isNotEqualTo: isNotEqualTo,
          isLessThanOrEqualTo: isLessThanOrEqualTo,
          isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
          arrayContains: arrayContains,
          arrayContainsAny: arrayContainsAny,
          whereIn: whereIn,
          whereNotIn: whereNotIn,
          order: order,
          limit: limit,
        );
}
