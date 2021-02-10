part of firestore_model_notifier;

mixin FirestoreLocalizeMixin<T> on FirestoreDocumentModel<T> {
  String get localeValueKey => "@locale";
  String get localizationValueKey => "@translate";
  List<String> get localizationKeys;

  @override
  @protected
  @mustCallSuper
  Map<String, Object> filterOnLoad(Map<String, Object> loaded) {
    for (final key in localizationKeys) {
      final language = Localize.language;
      assert(language.isNotEmpty,
          "The locale is not set. Run [Localize.initialize()] to initialize the translation.");
      final localizations = loaded
          .get<Map<String, dynamic>>("$key$localizationValueKey", const {});
      loaded[key] =
          localizations?.get(language, loaded.get<String>(key, "")) ?? const {};
    }
    return super.filterOnLoad(loaded);
  }

  @override
  @protected
  @mustCallSuper
  Map<String, Object> filterOnSave(Map<String, Object> save) {
    final language = Localize.language;
    assert(language.isNotEmpty,
        "The locale is not set. Run [Localize.initialize()] to initialize the translation.");
    save[localeValueKey] = language;
    return super.filterOnSave(save);
  }
}
