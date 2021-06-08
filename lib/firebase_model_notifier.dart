// Copyright 2021 mathru. All rights reserved.

/// Package to use [model_notifier] for Firebase.
///
/// To use, import `package:firebase_model_notifier/firebase_model_notifier.dart`.
///
/// [mathru.net]: https://mathru.net
/// [YouTube]: https://www.youtube.com/c/mathrunetchannel
library firebase_model_notifier;

import 'dart:async';
import 'dart:math';

// ignore: unused_import
import 'package:firebase_core/firebase_core.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:katana/katana.dart";
import "package:katana/katana.dart" as katana;
import "package:cloud_functions/cloud_functions.dart";
import "package:katana_firebase/katana_firebase.dart";
import "package:model_notifier/model_notifier.dart";
export "package:firebase_auth/firebase_auth.dart" show ActionCodeSettings;
export "package:model_notifier/model_notifier.dart";
export "package:cloud_firestore/cloud_firestore.dart";
export 'package:firebase_auth/firebase_auth.dart';

export 'storage/others/others.dart'
    if (dart.library.io) 'storage/mobile/mobile.dart'
    if (dart.library.js) 'storage/web/web.dart'
    if (dart.library.html) 'storage/web/web.dart';

part 'src/extensions.dart';
part 'firestore/functions.dart';
part 'firestore/extensions.dart';
part 'firestore/firestore_counter_updater_interval.dart';
part 'firestore/firestore_utility.dart';
part 'firestore/firestore_transaction.dart';
part 'firestore/firestore_query.dart';
part 'firestore/firestore_document_model.dart';
part 'firestore/firestore_collection_model.dart';
part 'firestore/firestore_collection_query_mixin.dart';
part 'firestore/firestore_search_query_mixin.dart';
part 'firestore/firestore_search_updater_mixin.dart';
part 'firestore/firestore_localize_mixin.dart';
part 'firestore/firestore_document_meta_mixin.dart';
part 'firestore/firestore_dynamic_document_model.dart';
part 'firestore/firestore_dynamic_collection_model.dart';
part 'firestore/firestore_dynamic_searchable_collection_model.dart';

part 'auth/firebase_auth_model.dart';
part 'auth/functions.dart';
part 'auth/auth_provider_options.dart';
part 'auth/anonymously_auth.dart';
part 'auth/sms_auth.dart';
part 'auth/email_and_password_auth.dart';
part 'auth/firebase_auth_core.dart';

part 'widget/ui_sms_form_dialog.dart';
part 'widget/ui_email_and_password_form_dialog.dart';

part 'functions/firebase_functions_model.dart';
part 'functions/firebase_functions_document_model.dart';
part 'functions/firebase_functions_collection_model.dart';
part 'functions/firebase_functions_dynamic_model.dart';
part 'functions/firebase_functions_dynamic_document_model.dart';
part 'functions/firebase_functions_dynamic_collection_model.dart';
