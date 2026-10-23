// storage.dart
// ---------------------------------------------------------------------------
// Saving data on the phone.
//
// We use `shared_preferences`: a tiny key-value store that works on both
// Android (SharedPreferences) and iOS (NSUserDefaults). All of FinWise's data
// is small, so we store it as ONE JSON text under one key.
//
// Storage is an abstract class so tests can use MemoryStorage instead of the
// real phone storage.
// ---------------------------------------------------------------------------

import 'package:shared_preferences/shared_preferences.dart';

abstract class Storage {
  Future<String?> read();
  Future<void> write(String data);
}

/// Real storage on the device.
class PhoneStorage implements Storage {
  static const _key = 'finwise_data_v1';

  @override
  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  @override
  Future<void> write(String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, data);
  }
}

/// Keeps data in memory only - used by tests.
class MemoryStorage implements Storage {
  MemoryStorage([this.data]);

  String? data;

  @override
  Future<String?> read() async => data;

  @override
  Future<void> write(String newData) async {
    data = newData;
  }
}
