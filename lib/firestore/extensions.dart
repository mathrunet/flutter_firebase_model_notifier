part of firebase_model_notifier;

extension FirestoreDynamicDocumentModelExtensions
    on FirestoreDynamicDocumentModel {
  String localized(
    String key,
    String orElse, {
    String? locale,
    String localizationValueKey = "@translate",
  }) {
    locale ??= Localize.language;
    final map = get(
      "$key$localeValueKey",
      const <String, dynamic>{},
    );
    if (map.isEmpty) {
      return get(key, orElse);
    }
    return map.get(
      locale,
      get(key, orElse),
    );
  }

  FirestoreDynamicDocumentModel setSearchField({
    String key = "@search",
    List<String> bigramKeys = const [Const.name, Const.text],
    List<String> tagKeys = const [Const.tag, Const.category],
  }) {
    var tmp = "";
    for (final bigramKey in bigramKeys) {
      if (this[bigramKey] is! String) {
        continue;
      }
      tmp += this[bigramKey];
    }
    for (final tagKey in tagKeys) {
      final tags = this[tagKey];
      if (tags is! List<String>) {
        continue;
      }
      for (final tag in tags) {
        tmp += tag;
      }
    }
    final res = <String, bool>{};
    tmp = tmp.toLowerCase();
    final bigramList = tmp.splitByBigram();
    for (final bigram in bigramList) {
      res[bigram] = true;
    }
    final characterList = tmp.splitByCharacter();
    for (final character in characterList) {
      res[character] = true;
    }
    this[key] = res;
    return this;
  }

  FirestoreDynamicDocumentModel setNotificationField({
    required String title,
    required String text,
    required DateTime time,
    String timeKey = "@pushTime",
    String titleKey = "@pushName",
    String textKey = "@pushText",
  }) {
    assert(title.isNotEmpty, "The title is empty.");
    assert(text.isNotEmpty, "The text is empty.");
    assert(timeKey.isNotEmpty, "The time key is empty.");
    assert(titleKey.isNotEmpty, "The title key is empty.");
    assert(textKey.isNotEmpty, "The text key is empty.");
    this[timeKey] = Timestamp.fromDate(time);
    this[titleKey] = title;
    this[textKey] = text;
    return this;
  }

  FirestoreDynamicDocumentModel increment(
    String key,
    num value, {
    List<FirestoreCounterUpdaterInterval> intervals = const [],
  }) {
    this[key] = FieldValue.increment(value);
    if (intervals.isEmpty) {
      return this;
    }
    final now = DateTime.now();
    for (final interval in intervals) {
      switch (interval) {
        case FirestoreCounterUpdaterInterval.daily:
          this[dailyKey(key, now)] = FieldValue.increment(value);
          for (var i = 0; i < 30; i++) {
            this[dailyKey(
                    key, DateTime(now.year, now.month, now.day - 60 + i))] =
                FieldValue.delete();
          }
          break;
        case FirestoreCounterUpdaterInterval.monthly:
          this[monthlyKey(key, now)] = FieldValue.increment(value);
          for (var i = 0; i < 12; i++) {
            this[monthlyKey(key, DateTime(now.year, now.month - 24 + i))] =
                FieldValue.delete();
          }
          break;
        case FirestoreCounterUpdaterInterval.yearly:
          this[yearlyKey(key, now)] = FieldValue.increment(value);
          for (var i = 0; i < 5; i++) {
            this[yearlyKey(key, DateTime(now.year, now.month - 10 + i))] =
                FieldValue.delete();
          }
          break;
        case FirestoreCounterUpdaterInterval.weekly:
          this[weeklyKey(key, now)] = FieldValue.increment(value);
          for (var i = 0; i < 4; i++) {
            this[weeklyKey(key,
                    DateTime(now.year, now.month, now.day - ((8 - i) * 7)))] =
                FieldValue.delete();
          }
          break;
      }
    }
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
