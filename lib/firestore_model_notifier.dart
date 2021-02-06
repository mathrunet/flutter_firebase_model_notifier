// Copyright 2021 mathru. All rights reserved.

/// Package to use [model_notifier] for Firestore.
///
/// To use, import `package:firestore_model_notifier/firestore_model_notifier.dart`.
///
/// [mathru.net]: https://mathru.net
/// [YouTube]: https://www.youtube.com/c/mathrunetchannel
library firestore_model_notifier;

import 'dart:math';

import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:katana/katana.dart";
import "package:katana_firebase/katana_firebase.dart";
import "package:model_notifier/model_notifier.dart";

part "src/extensions.dart";
part "src/firestore_document_model.dart";
part "src/firestore_collection_model.dart";
part "src/firestore_search_mixin.dart";
part "src/firestore_localize_mixin.dart";
part "src/firestore_document_meta_mixin.dart";
part 'src/firestore_counter_viewer_mixin.dart';
part 'src/firestore_counter_updater_mixin.dart';
