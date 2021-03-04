// Copyright 2021 mathru. All rights reserved.

/// Package to use [model_notifier] for Firebase.
///
/// To use, import `package:firebase_model_notifier/firebase_model_notifier.dart`.
///
/// [mathru.net]: https://mathru.net
/// [YouTube]: https://www.youtube.com/c/mathrunetchannel
library firebase_model_notifier;

import 'dart:async';
import 'dart:io';
import 'dart:math';

import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:katana/katana.dart";
import "package:cloud_functions/cloud_functions.dart";
import "package:katana_firebase/katana_firebase.dart";
import "package:model_notifier/model_notifier.dart";
export "package:model_notifier/model_notifier.dart";
export "package:cloud_firestore/cloud_firestore.dart";
export 'package:firebase_auth/firebase_auth.dart';

part 'src/extensions.dart';
part 'firestore/firestore_query.dart';
part 'firestore/firestore_document_model.dart';
part 'firestore/firestore_collection_model.dart';
part 'firestore/firestore_search_query_mixin.dart';
part 'firestore/firestore_search_updater_mixin.dart';
part 'firestore/firestore_localize_mixin.dart';
part 'firestore/firestore_document_meta_mixin.dart';
part 'firestore/firestore_counter_updater_mixin.dart';
part 'firestore/firestore_dynamic_document_model.dart';
part 'firestore/firestore_dynamic_collection_model.dart';
part 'firestore/firestore_dynamic_searchable_document_model.dart';
part 'firestore/firestore_dynamic_searchable_collection_model.dart';
part 'firestore/firestore_dynamic_counter_collection_model.dart';

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

part 'storage/firebase_storage_core.dart';
part 'storage/firebase_storage_model.dart';
