part of firebase_model_notifier;

final firebaseStorageProvider =
    ModelProvider.family<FirebaseStorageModel, String>(
  (_, path) => FirebaseStorageModel(path),
);

class FirebaseStorageModel extends ValueModel<File?> {
  FirebaseStorageModel(this.path) : super(null);

  @protected
  final String path;

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

  @protected
  Reference get reference {
    return storage.ref().child(path);
  }

  /// Perform download.
  ///
  /// Download the file and save it locally.
  ///
  /// [path]: Upload destination path.
  /// [cachePath]: Cache path for downloaded files.
  /// [storageBucket]: Storage bucket path.
  /// [timeout]: Timeout time.
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
  /// Put the file to be uploaded in [File].
  ///
  /// [path]: Upload destination path.
  /// [file]: File to upload.
  /// [storageBucket]: Storage bucket path.
  /// [timeout]: Timeout time.
  Future<FirebaseStorageModel> upload(File file,
      {Duration timeout = const Duration(seconds: 300)}) async {
    assert(path.isNotEmpty, "Path is invalid.");
    await _upload(file, timeout);
    return this;
  }

  /// Download the file again.
  ///
  /// [cachePath]: Cache path for downloaded files.
  /// [timeout]: Timeout time.
  Future<FirebaseStorageModel> retryeDownload(String cachePath,
      {Duration timeout = const Duration(seconds: 300)}) async {
    assert(cachePath.isNotEmpty, "Cache path is invalid.");
    await _download(cachePath, timeout);
    return this;
  }

  Future<void> _download(String cachePath, Duration timeout) async {
    try {
      if (!isSignedIn) {
        throw Exception("Firebase is not initialized and authenticated.");
      }
      final cacheFile = File(cachePath);
      if (cacheFile.existsSync()) {
        final meta = await reference.getMetadata().timeout(timeout);
        if (cacheFile.lastModifiedSync().millisecondsSinceEpoch >=
            (meta.updated?.millisecondsSinceEpoch ??
                DateTime.now().millisecondsSinceEpoch)) {
          debugPrint("The latest data in the cache: $path");
          return;
        }
      }
      final downloadTask = reference.writeToFile(cacheFile);
      await Future.value(downloadTask).timeout(timeout);
      value = cacheFile;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload the file again.
  ///
  /// [file]: File to upload.
  /// [timeout]: Timeout time.
  Future<FirebaseStorageModel> retryUpload(File file,
      {Duration timeout = const Duration(seconds: 300)}) async {
    await _upload(file, timeout);
    return this;
  }

  Future<void> _upload(File file, Duration timeout) async {
    try {
      if (!isSignedIn) {
        throw Exception("Firebase is not initialized and authenticated.");
      }
      final uploadTask = reference.putFile(file);
      await Future.value(uploadTask).timeout(timeout);
      value = file;
    } catch (e) {
      rethrow;
    }
  }
}
