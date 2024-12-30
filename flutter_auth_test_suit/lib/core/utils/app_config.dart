import 'dart:convert';

import 'package:flutter/services.dart';

class AppConfig {
  final Map<String, dynamic> json;
  static AppConfig? _instance;
  static const String _keyWebAppDomain = 'webAppDomain';
  static const String _keyApiUrl = 'apiUrl';

  factory AppConfig(
    Map<String, dynamic> json, {
    bool showMoney = true,
  }) =>
      _instance ??= AppConfig._internal(
        json,
      );

  AppConfig._internal(
    this.json,
  );

  static AppConfig get instance {
    if (_instance == null) {
      throw Exception();
    }
    return _instance!;
  }

  String get webAppDomain => (json[_keyWebAppDomain] ?? '') as String;
  String get apiUrl => (json[_keyApiUrl] ?? '') as String;
}

class ConfigReader {
  static Future<Map<String, dynamic>> readConfigFile() async {
    final String response =
        await rootBundle.loadString('assets/configs/config.json');
    return jsonDecode(response);
  }
}
