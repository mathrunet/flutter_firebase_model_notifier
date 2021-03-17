part of firebase_model_notifier;

final functionsProvider =
    ModelProvider.family<FirebaseFunctionsDynamicModel, String>(
  (_, endpoint) => FirebaseFunctionsDynamicModel(endpoint),
);

class FirebaseFunctionsDynamicModel extends FirebaseFunctionsModel<dynamic> {
  FirebaseFunctionsDynamicModel(String endpoint, [dynamic initialValue])
      : super(endpoint, initialValue);

  @override
  @protected
  bool get notifyOnChangeValue => false;

  @override
  dynamic fromResponse(dynamic value) {
    return value;
  }
}
