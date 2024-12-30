import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:basic_utils/basic_utils.dart';

class EncryptionKeyManager {
  static const _storageKey = 'encryption_key';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<String> generateAndStoreKey() async {
    final key = _generateRandomKey(12);
    final encodedKey = base64UrlEncode(key);
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, encodedKey);
    } else {
      await _secureStorage.write(key: _storageKey, value: encodedKey);
    }

    return encodedKey;
  }

  static Future<String> getEncryptionKey() async {
    String? encodedKey;

    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      encodedKey = prefs.getString(_storageKey);
    } else {
      encodedKey = await _secureStorage.read(key: _storageKey);
    }

    if (StringUtils.isNullOrEmpty(encodedKey)) {
      encodedKey = await generateAndStoreKey();
    }

    return encodedKey!;
  }

  static Future<void> deleteEncryptionKey() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } else {
      await _secureStorage.delete(key: _storageKey);
    }
  }

  static List<int> _generateRandomKey(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}
