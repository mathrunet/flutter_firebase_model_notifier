part of firestore_model_notifier;

class FirestoreQuery {
  const FirestoreQuery(
    this.path, {
    this.key,
    this.value,
    this.type,
    this.order = FirestoreQueryOrder.asc,
    this.limit,
    this.orderBy,
  });
  final String path;
  final dynamic value;
  final String? key;
  final String? orderBy;
  final FirestoreQueryType? type;
  final FirestoreQueryOrder order;
  final int? limit;

  String _limit(String path) {
    if (limit == null) {
      return path;
    }
    return "$path&limitToFirst=$limit";
  }

  String _order(String path) {
    if (orderBy.isEmpty) {
      return path;
    }
    if (order == FirestoreQueryOrder.asc) {
      return "$path&orderByAsc=$orderBy";
    } else {
      return "$path&orderByDesc=$orderBy";
    }
  }

  String get url {
    if (key.isEmpty || type == null) {
      return path;
    }
    final tmp = "$path?key=$key";
    switch (type) {
      case FirestoreQueryType.equal:
        if (value is! String) {
          return path;
        }
        return _limit(_order("$tmp&equalTo=$value"));
      case FirestoreQueryType.notEqual:
        if (value is! String) {
          return path;
        }
        return _limit(_order("$tmp&notEqualTo=$value"));
      case FirestoreQueryType.greaterThanOrEqual:
        if (value is! num) {
          return path;
        }
        return _limit(_order("$tmp&startAt=$value"));
      case FirestoreQueryType.lessThanOrEqual:
        if (value is! num) {
          return path;
        }
        return _limit(_order("$tmp&endAt=$value"));
      case FirestoreQueryType.contains:
        if (value is! String) {
          return path;
        }
        return _limit(_order("$tmp&contains=$value"));
      case FirestoreQueryType.containsAny:
        if (value is! List<String>) {
          return path;
        }
        return _limit(_order("$tmp&containsAny=${value.join(",")}"));
      case FirestoreQueryType.whereIn:
        if (value is! List<String>) {
          return path;
        }
        return _limit(_order("$tmp&whereIn=${value.join(",")}"));
      case FirestoreQueryType.whereNotIn:
        if (value is! List<String>) {
          return path;
        }
        return _limit(_order("$tmp&whereNotIn=${value.join(",")}"));
      default:
        return tmp;
    }
  }
}

enum FirestoreQueryOrder { asc, desc }

enum FirestoreQueryType {
  equal,
  notEqual,
  greaterThanOrEqual,
  lessThanOrEqual,
  // range,
  contains,
  containsAny,
  whereIn,
  whereNotIn,
}
