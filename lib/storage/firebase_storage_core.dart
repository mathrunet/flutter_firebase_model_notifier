part of firebase_model_notifier;

class FirebaseStorageCore {
  FirebaseStorageCore._();

  static Future<String> upload(String path) async {
    assert(path.isNotEmpty, "Path is empty.");
    if (path.startsWith("http")) {
      return path;
    }
    final file = File(path);
    if (!file.existsSync()) {
      throw Exception("File is not found.");
    }
    final storage =
        readProvider(firebaseStorageProvider("$uuid.${path.split(".").last}"));
    await storage.upload(file);
    return storage.url;
  }
}
