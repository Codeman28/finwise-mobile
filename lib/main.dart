// main.dart
// ---------------------------------------------------------------------------
// Where the app starts.
//
//   1. Flutter prepares the engine (ensureInitialized).
//   2. We show FinWiseApp, which first displays a loading screen while the
//      saved data is read from the phone, then the real app.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'data/storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Draw behind the status bar / gesture bar for a modern edge-to-edge look
  // on both Android and iOS.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(FinWiseApp(storage: PhoneStorage()));
}
