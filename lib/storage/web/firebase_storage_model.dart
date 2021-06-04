part of firebase_model_notifier.storage.web;

/// Class for handling Firebase storage.
///
/// Basically, you specify the [path] of the local file in [upload] and
/// receive the URL after the upload.
///
/// You can then use [Image.network] or similar to display that URL.
///
/// ```
/// final firebaseStorageProvider = readProvider(firebaseStorageProvider("remote path"));
/// final media = firebaseStorageProvider.upload("local path");
/// if(media == null) return;
/// Image.network(media.url);
/// ```
final firebaseStorageProvider =
    ModelProvider.family<FirebaseStorageModel, String>(
  (_, path) => FirebaseStorageModel(path),
);

/// Class for handling Firebase storage.
///
/// Basically, you specify the [path] of the local file in [upload] and
/// receive the URL after the upload.
///
/// You can then use [Image.network] or similar to display that URL.
class FirebaseStorageModel extends ValueModel<String?> {
  /// Class for handling Firebase storage.
  ///
  /// Basically, you specify the [path] of the local file in [upload] and
  /// receive the URL after the upload.
  ///
  /// You can then use [Image.network] or similar to display that URL.
  FirebaseStorageModel(this.path) : super(null);

  /// The remote file path.
  @protected
  final String path;

  /// Firebase storage instance.
  @protected
  FirebaseStorage get storage {
    return FirebaseStorage.instance;
  }

  /// Firebase Storage bucket domain.
  @protected
  String get storageBucket => storage.bucket;

  /// URL path to the file.
  String get url =>
      "https://firebasestorage.googleapis.com/v0/b/$storageBucket/o/$path?alt=media";

  /// Reference to Firebase storage.
  @protected
  Reference get reference {
    return storage.ref().child(path);
  }

  /// Perform download.
  ///
  /// Download the file and save it locally.
  ///
  /// Specify [cachePath] and save the downloaded file there.
  Future<FirebaseStorageModel> download(
    String cachePath, {
    Duration timeout = const Duration(seconds: 300),
  }) async {
    assert(path.isNotEmpty, "Path is invalid.");
    assert(cachePath.isNotEmpty, "Cache path is invalid.");
    await _download(cachePath, timeout);
    return this;
  }

  /// Perform upload.
  ///
  /// Put the file to be uploaded from [filePath].
  Future<FirebaseStorageModel> upload(
    String filePath, {
    Duration timeout = const Duration(seconds: 300),
  }) async {
    assert(path.isNotEmpty, "Path is invalid.");
    await _upload(filePath, timeout);
    return this;
  }

  /// Download the file again.
  ///
  /// Specify [cachePath] and save the downloaded file there.
  Future<FirebaseStorageModel> retryDownload(String cachePath,
      {Duration timeout = const Duration(
        seconds: 300,
      )}) async {
    assert(cachePath.isNotEmpty, "Cache path is invalid.");
    await _download(cachePath, timeout);
    return this;
  }

  /// Upload the file again.
  ///
  /// Put the file to be uploaded from [filePath].
  Future<FirebaseStorageModel> retryUpload(
    String filePath, {
    Duration timeout = const Duration(seconds: 300),
  }) async {
    await _upload(filePath, timeout);
    return this;
  }

  Future<void> _download(String cachePath, Duration timeout) async {
    if (!isSignedIn) {
      throw Exception("Firebase is not initialized and authenticated.");
    }
    throw UnsupportedError("This feature is not supported.");
  }

  Future<void> _upload(String filePath, Duration timeout) async {
    try {
      if (!isSignedIn) {
        throw Exception("Firebase is not initialized and authenticated.");
      }
      assert(filePath.isNotEmpty, "Path is empty.");
      if (filePath.startsWith("http")) {
        return;
      }
      final byte = await readBytes(Uri.parse(path));
      final uploadTask = reference.putData(byte);
      await Future.value(uploadTask).timeout(timeout);
      value = filePath;
    } catch (e) {
      rethrow;
    }
  }
}
