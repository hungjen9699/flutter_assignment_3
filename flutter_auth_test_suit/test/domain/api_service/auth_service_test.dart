import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_test_suit/core/datasource/dio_client.dart';
import 'package:flutter_auth_test_suit/core/exceptions/exception.dart';
import 'package:flutter_auth_test_suit/core/utils/app_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_auth_test_suit/domain/api_service/auth_service.dart';
import 'package:flutter_auth_test_suit/data/user_model/user.dart';
import 'package:mocktail/mocktail.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  late AuthService authService;
  late MockDioClient mockDioClient;

  setUp(() async {
    final jsonMap = await ConfigReader.readConfigFile();
    AppConfig(
      jsonMap,
    );
    mockDioClient = MockDioClient();
    authService = AuthService(dioClient: mockDioClient);
  });

  group('AuthService', () {
    const endPoint = '/user/login';
    const username = 'emilys';
    const password = 'emilyspass';
    const wrongPassword = 'wrongpassword';

    test('should return a User when login credentials are correct', () async {
      final mockResponse = Response(
        requestOptions: RequestOptions(path: endPoint),
        statusCode: 200,
        data: {
          'id': 1,
          'username': username,
        },
      );

      when(() => mockDioClient.requestPost(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => mockResponse);

      final user = await authService.login(username, password);

      expect(user, isA<User>());
      expect(user?.id, 1);
      expect(user?.username, username);

      verify(() => mockDioClient.requestPost(
            endPoint,
            data: {
              "username": username,
              "password": password,
              "expiresInMins": 30,
            },
          )).called(1);
    });

    test(
      'should throw InvalidCredentialsException when login with wrong password',
      () async {
        when(() => mockDioClient.requestPost(
              any(),
              data: any(named: 'data'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(path: endPoint),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: endPoint),
            statusCode: 401,
            data: {'message': 'Unauthorized'},
          ),
        ));
        expect(
          () => authService.login(username, wrongPassword),
          throwsA(isA<InvalidCredentialsException>()),
        );
        verify(() => mockDioClient.requestPost(
              endPoint,
              data: {
                "username": username,
                "password": wrongPassword,
                "expiresInMins": 30,
              },
            )).called(1);
      },
    );

    test('should throw NoInternetException when there is no internet',
        () async {
      when(() => mockDioClient.requestPost(
            any(),
            data: any(named: 'data'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: endPoint),
        type: DioExceptionType.connectionError,
        error: 'No Internet',
      ));

      expect(
        () => authService.login(username, password),
        throwsA(isA<NoInternetException>()),
      );
      verify(() => mockDioClient.requestPost(
            endPoint,
            data: {
              "username": username,
              "password": password,
              "expiresInMins": 30,
            },
          )).called(1);
    });

    test('should throw UnexpectedException when an unexpected error occurs',
        () async {
      when(() => mockDioClient.requestPost(
            any(),
            data: any(named: 'data'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: endPoint),
        type: DioExceptionType.unknown,
        error: 'Some unknown error',
      ));

      expect(
        () => authService.login(username, password),
        throwsA(isA<UnexpectedException>()),
      );

      verify(() => mockDioClient.requestPost(
            endPoint,
            data: {
              "username": username,
              "password": password,
              "expiresInMins": 30,
            },
          )).called(1);
    });

    test('should throw GeneralException when a general error occurs', () async {
      when(() => mockDioClient.requestPost(
            any(),
            data: any(named: 'data'),
          )).thenThrow(Exception('Some general exception'));

      expect(
        () => authService.login(username, password),
        throwsA(isA<GeneralException>()),
      );

      verify(() => mockDioClient.requestPost(
            endPoint,
            data: {
              "username": username,
              "password": password,
              "expiresInMins": 30,
            },
          )).called(1);
    });

    test('should complete logout without errors', () async {
      await authService.logout();

      expect(true, isTrue);
    });
  });
}
