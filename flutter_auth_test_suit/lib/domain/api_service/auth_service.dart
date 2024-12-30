import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_auth_test_suit/core/datasource/dio_client.dart';
import 'package:flutter_auth_test_suit/data/user_model/user.dart';

import '../../core/exceptions/exception.dart';

class AuthService {
  final DioClient _dioClient;

  AuthService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  Future<User?> login(String username, String password) async {
    try {
      const String endPoint = '/user/login';

      final response = await _dioClient.requestPost(endPoint, data: {
        "username": username,
        "password": password,
        "expiresInMins": 30,
      });
      return User.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        throw NoInternetException();
      } else if (e.type == DioExceptionType.badResponse &&
          e.response?.statusCode == 401) {
        throw InvalidCredentialsException();
      } else {
        throw UnexpectedException();
      }
    } catch (e) {
      throw GeneralException();
    }
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
