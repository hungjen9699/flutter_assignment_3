import 'package:dio/dio.dart';

import '../utils/app_config.dart';

class DioClientWithoutToken {
  static const int _receiveTimeout = 60000;
  static const int _connectTimeout = 60000;
  late Dio dio = _createDio();

  static DioClientWithoutToken instance = DioClientWithoutToken._internal();

  factory DioClientWithoutToken() => instance;
  DioClientWithoutToken._internal();

  Dio _createDio() {
    final Dio dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: _connectTimeout),
        receiveTimeout: const Duration(milliseconds: _receiveTimeout),
        baseUrl: AppConfig.instance.apiUrl,
      ),
    );
    return dio;
  }

  Future<Response<T>> requestPost<T>(
    final String path, {
    final dynamic data,
    final Map<String, dynamic>? queryParameters,
  }) {
    return dio.post(
      path,
      data: data ?? <String, dynamic>{},
      queryParameters: queryParameters ?? <String, dynamic>{},
    );
  }

  Future<Response<T>> requestPut<T>(
    final String path, {
    final dynamic data,
    final Map<String, dynamic>? queryParameters,
  }) {
    return dio.put(
      path,
      data: data ?? <String, dynamic>{},
      queryParameters: queryParameters ?? <String, dynamic>{},
    );
  }

  Future<Response<T>> requestDelete<T>(
    final String path, {
    final dynamic data,
    final Map<String, dynamic>? queryParameters,
  }) {
    return dio.delete(
      path,
      data: data ?? <String, dynamic>{},
      queryParameters: queryParameters ?? <String, dynamic>{},
    );
  }

  Future<Response<T>> requestGet<T>(
    final String path, {
    final Map<String, dynamic>? queryParameters,
  }) {
    return dio.get(
      path,
      queryParameters: queryParameters ?? <String, dynamic>{},
    );
  }

  Future<Response<T>> request<T>(
    final String path, {
    Object? data,
    final Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.request(
      path,
      data: data,
      options: options,
      queryParameters: queryParameters ?? <String, dynamic>{},
    );
  }

  Future<List<int>> getContentFileFromUrl(final String url) async {
    final Response response = await Dio().get(
      url,
      options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status != null && status < 500;
          }),
    );

    return response.data;
  }

  Future<List<int>> getContentFileFromPostMethod(
    final String url, {
    final dynamic data,
  }) async {
    final Response response = await dio.post(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
      data: data ?? <String, dynamic>{},
    );

    return response.data;
  }
}
