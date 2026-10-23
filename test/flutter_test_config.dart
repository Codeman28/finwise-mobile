// flutter_test_config.dart
// ---------------------------------------------------------------------------
// Flutter runs this file automatically before every test in this folder.
//
// By default, widget tests draw text with a special test font where every
// letter is a wide square. We load the app's real font (Be Vietnam Pro) and
// Material Icons instead, so layout tests measure text like a real phone.
// ---------------------------------------------------------------------------

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await _loadFont('BeVietnamPro', [
    'assets/fonts/BeVietnamPro-Regular.ttf',
    'assets/fonts/BeVietnamPro-Medium.ttf',
    'assets/fonts/BeVietnamPro-SemiBold.ttf',
    'assets/fonts/BeVietnamPro-Bold.ttf',
    'assets/fonts/BeVietnamPro-ExtraBold.ttf',
  ]);
  await testMain();
}

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final bytes = File(path).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}
