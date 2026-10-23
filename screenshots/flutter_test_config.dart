// Loads the real fonts (Be Vietnam Pro + Material Icons) before the
// screenshot tests, so the images look like the app on a real phone.
// Run the screenshots with:
//   flutter test screenshots --update-goldens
// Images are written to screenshots/goldens/.

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
  // The icon font ships with the Flutter SDK.
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '';
  await _loadFont('MaterialIcons', ['$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
  await testMain();
}

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (file.existsSync()) {
      loader.addFont(Future.value(ByteData.view(file.readAsBytesSync().buffer)));
    }
  }
  await loader.load();
}
