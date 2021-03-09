part of firebase_model_notifier;

extension FirestoreDynamicDocumentModelExtensions
    on FirestoreDynamicDocumentModel {
  FirestoreDynamicDocumentModel searchField(
      {String key = "@search",
      List<String> bigramKeys = const ["name", "text"],
      List<String> tagKeys = const ["tag", "category"]}) {
    var tmp = "";
    for (final bigramKey in bigramKeys) {
      if (this[bigramKey] is! String) {
        continue;
      }
      tmp += this[bigramKey];
    }
    final res = <String, bool>{};
    final bigramList = tmp.splitByBigram();
    for (final bigram in bigramList) {
      res[bigram] = true;
    }
    for (final tagKey in tagKeys) {
      if (this[tagKey] is! List<String>) {
        continue;
      }
      for (final tag in this[tagKey]) {
        res[tag] = true;
      }
    }
    this[key] = res;
    return this;
  }

  FirestoreDynamicDocumentModel increment(String key, num value) {
    this[key] = FieldValue.increment(value);
    return this;
  }

  FirestoreDynamicDocumentModel deleteField(String key) {
    this[key] = FieldValue.delete();
    return this;
  }

  FirestoreDynamicDocumentModel timestamp(String key) {
    this[key] = FieldValue.serverTimestamp();
    return this;
  }
}
