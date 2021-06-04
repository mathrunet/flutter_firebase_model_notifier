part of firebase_model_notifier.storage.others;

/// Class for handling Firebase storage.
///
/// Basically, you specify the [path] of the local file in [upload] and
/// receive the URL after the upload.
///
/// You can then use [Image.network] or similar to display that URL.
class FirebaseStorageCore {
  FirebaseStorageCore._();

  /// Class for handling Firebase storage.
  ///
  /// Basically, you specify the [path] of the local file in [upload] and
  /// receive the URL after the upload.
  ///
  /// You can then use [Image.network] or similar to display that URL.
  ///
  /// ```
  /// final media = await FirebaseStorageCore.upload("local path");
  /// if(media == null) return;
  /// Image.network(media.url);
  /// ```
  static Future<String> upload(String path) async {
    assert(path.isNotEmpty, "Path is empty.");
    if (path.startsWith("http")) {
      return path;
    }
    final storage =
        readProvider(firebaseStorageProvider("$uuid.${path.split(".").last}"));
    await storage.upload(path);
    return storage.url;
  }
}
