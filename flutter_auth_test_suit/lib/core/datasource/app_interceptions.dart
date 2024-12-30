import 'dart:convert';
import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

import '../../main.dart';
import '../utils/encrypted_key_manager.dart';

const String currentAuthorizationKey = 'key_current_local_authorization';

class AppInterceptors extends Interceptor {
  static bool _isInitialized = false;
  final Logger _logger = Logger();

  AppInterceptors() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (!_isInitialized) {
      final encryptionKey = await EncryptionKeyManager.getEncryptionKey();
      await EncryptedSharedPreferences.initialize(encryptionKey);
      _isInitialized = true;
      _logger.i('EncryptedSharedPreferences initialized with secure key.');
    }
  }

  Future<Map<String, dynamic>?> _getAuthorization() async {
    await _initialize();
    var sharedPref = EncryptedSharedPreferences.getInstance();
    final stringJson = sharedPref.getString(currentAuthorizationKey);
    if (StringUtils.isNullOrEmpty(stringJson)) {
      _logger.w('Authorization token is null or empty.');
      return null;
    }
    try {
      return jsonDecode(stringJson!) as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Failed to decode authorization JSON', error: e);
      return null;
    }
  }

  Future<void> _saveAuthorization(Map<String, dynamic> authData) async {
    await _initialize();
    var sharedPref = EncryptedSharedPreferences.getInstance();
    final stringJson = jsonEncode(authData);
    await sharedPref.setString(currentAuthorizationKey, stringJson);
    _logger.i('Authorization token saved.');
  }

  Future<void> _clearAuthorization() async {
    await _initialize();
    var sharedPref = EncryptedSharedPreferences.getInstance();
    await sharedPref.remove(currentAuthorizationKey);
    _logger.i('Authorization token cleared.');
  }

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final authorization = await _getAuthorization();

      if (authorization == null && !options.path.contains('auth/login/')) {
        final sb = StringBuffer();
        sb.write('Method: ${options.method}\n');
        sb.write('Path: ${options.path}\n');
        sb.write('Params: ${options.queryParameters}\n');
        sb.write('Data: ${options.data}\n');
        debugPrint(sb.toString());
        _logger.w(
          'Call API with Empty access token >> Method: ${options.method} >> URL: ${options.path} >> Body: ${options.data} >> Params: ${options.queryParameters}',
        );
      }

      if (authorization != null && authorization.containsKey('accessToken')) {
        options.headers['Authorization'] =
            "Bearer ${authorization['accessToken']}";
      }

      options.headers.putIfAbsent(
        'Content-Type',
        () => 'application/json-patch+json',
      );
      options.headers.putIfAbsent(
        'Accept',
        () => 'application/json',
      );

      _logger.d(
        'Call API >> Method: ${options.method} >> URL: ${options.path} >> Body: ${options.data} >> Params: ${options.queryParameters}',
      );

      super.onRequest(options, handler);
    } catch (e, stackTrace) {
      _logger.e('Error in onRequest interceptor',
          error: e, stackTrace: stackTrace);
      handler.next(options);
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    super.onError(err, handler);

    final sb = StringBuffer();
    sb.write('Method: ${err.requestOptions.method}\n');
    sb.write('Path: ${err.requestOptions.path}\n');
    sb.write('Params: ${err.requestOptions.queryParameters}\n');
    sb.write('Data: ${err.requestOptions.data}\n');
    sb.write('Error Message: ${err.message}\n');
    if (err.response != null) {
      sb.write('Response Status Code: ${err.response?.statusCode}\n');
      sb.write('Response Data: ${err.response?.data}');
    }
    _logger.e(sb.toString());

    if (err.response?.statusCode == HttpStatus.unauthorized) {
      await _clearAuthorization();
      navigatorKey.currentState?.pushReplacementNamed('/login');
    }
  }

  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    _logger.d('HTTP Response\n'
        'Status: ${response.statusCode}\n'
        'EndPoint: ${response.requestOptions.path}\n'
        'Request Method: ${response.requestOptions.method}\n'
        'Request Data: ${response.requestOptions.data}\n'
        'Request Query Params: ${response.requestOptions.queryParameters}\n'
        'Response Data: ${response.data}');
    super.onResponse(response, handler);
  }

  Future<void> updateAuthorization(
      String accessToken, String refreshToken) async {
    final authData = {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
    await _saveAuthorization(authData);
  }
}
