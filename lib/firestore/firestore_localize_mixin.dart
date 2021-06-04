part of firebase_model_notifier;

mixin FirestoreLocalizeMixin<T> on FirestoreDocumentModel<T> {
  String get localizationValueKey => MetaConst.translate;
  List<String> get localizationKeys;

  @override
  @protected
  @mustCallSuper
  DynamicMap filterOnLoad(DynamicMap loaded) {
    for (final key in localizationKeys) {
      final language = Localize.language;
      assert(language.isNotEmpty,
          "The locale is not set. Run [Localize.initialize()] to initialize the translation.");
      final localizations =
          loaded.get<DynamicMap>("$key$localizationValueKey", {});
      loaded[key] = localizations.get(language, loaded.get<String>(key, ""));
    }
    return super.filterOnLoad(loaded);
  }

  @override
  @protected
  @mustCallSuper
  DynamicMap filterOnSave(DynamicMap save) {
    final language = Localize.language;
    assert(language.isNotEmpty,
        "The locale is not set. Run [Localize.initialize()] to initialize the translation.");
    save[localeValueKey] = language;
    return super.filterOnSave(save);
  }
}
