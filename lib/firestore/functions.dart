part of firebase_model_notifier;

String dailyKey(String key, [DateTime? time]) {
  time ??= DateTime.now();
  return "$key:${time.format("yyyyMMdd")}";
}

String weeklyKey(String key, [DateTime? time]) {
  time ??= DateTime.now();
  return "$key:${time.format("yyyyww")}";
}

String monthlyKey(String key, [DateTime? time]) {
  time ??= DateTime.now();
  return "$key:${time.format("yyyyMM")}";
}

String yearlyKey(String key, [DateTime? time]) {
  time ??= DateTime.now();
  return "$key:${time.format("yyyy")}";
}
