import 'package:flutter_auth_test_suit/core/exceptions/exception.dart';
import 'package:flutter_auth_test_suit/data/user_model/user.dart';
import 'package:flutter_auth_test_suit/domain/api_service/auth_service.dart';
import 'package:flutter_auth_test_suit/domain/repository/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late MockAuthService mockAuthService;
  late AuthRepository authRepository;

  setUp(() {
    mockAuthService = MockAuthService();
    authRepository = AuthRepository(authService: mockAuthService);
  });

  group('AuthRepository Tests', () {
    const testUser = User(
      id: 1,
      username: 'emilys',
      firstName: 'Emily',
      lastName: 'Johnson',
      gender: 'gender',
      image: 'image',
      email: 'emily.johnson@x.dummyjson.com',
    );

    test('should return User on successful login', () async {
      when(() => mockAuthService.login(any(), any()))
          .thenAnswer((_) async => testUser);
      final user = await authRepository.login('emilys', 'emilyspass');
      expect(user, equals(testUser));
      verify(() => mockAuthService.login('emilys', 'emilyspass')).called(1);
    });

    test(
        'should throw AuthRepositoryException when login with invalid credentials',
        () async {
      when(() => mockAuthService.login(any(), any()))
          .thenThrow(InvalidCredentialsException('Invalid credentials'));
      expect(
        () => authRepository.login('invalidUser', 'invalidPass'),
        throwsA(
          isA<AuthRepositoryException>().having(
            (e) => e.message,
            'message',
            'Invalid credentials',
          ),
        ),
      );

      verify(() => mockAuthService.login('invalidUser', 'invalidPass'))
          .called(1);
    });

    test('should throw AuthRepositoryException when there is no internet',
        () async {
      when(() => mockAuthService.login(any(), any()))
          .thenThrow(NoInternetException('No Internet Connection'));
      expect(
        () => authRepository.login('emilys', 'emilyspass'),
        throwsA(
          isA<AuthRepositoryException>().having(
            (e) => e.message,
            'message',
            'No Internet Connection',
          ),
        ),
      );

      verify(() => mockAuthService.login('emilys', 'emilyspass')).called(1);
    });

    test('should throw AuthRepositoryException when an unexpected error occurs',
        () async {
      when(() => mockAuthService.login(any(), any()))
          .thenThrow(UnexpectedException('Unexpected error'));
      expect(
        () => authRepository.login('emilys', 'emilyspass'),
        throwsA(
          isA<AuthRepositoryException>().having(
            (e) => e.message,
            'message',
            'Unexpected error',
          ),
        ),
      );

      verify(() => mockAuthService.login('emilys', 'emilyspass')).called(1);
    });

    test('should throw AuthRepositoryException when a general error occurs',
        () async {
      when(() => mockAuthService.login(any(), any()))
          .thenThrow(GeneralException('General error'));
      expect(
        () => authRepository.login('emilys', 'emilyspass'),
        throwsA(
          isA<AuthRepositoryException>().having(
            (e) => e.message,
            'message',
            'General error',
          ),
        ),
      );

      verify(() => mockAuthService.login('emilys', 'emilyspass')).called(1);
    });

    test(
        'should throw AuthRepositoryException when an unknown exception occurs',
        () async {
      when(() => mockAuthService.login(any(), any()))
          .thenThrow(Exception('Unknown exception'));

      expect(
        () => authRepository.login('emilys', 'emilyspass'),
        throwsA(
          isA<AuthRepositoryException>().having(
            (e) => e.message,
            'message',
            'An unexpected error occurred',
          ),
        ),
      );

      verify(() => mockAuthService.login('emilys', 'emilyspass')).called(1);
    });

    test('should complete logout successfully', () async {
      when(() => mockAuthService.logout()).thenAnswer((_) async {});
      await authRepository.logout();
      verify(() => mockAuthService.logout()).called(1);
    });

    test('should throw AuthRepositoryException when logout fails', () async {
      when(() => mockAuthService.logout())
          .thenThrow(Exception('Logout failed'));
      expect(
        () => authRepository.logout(),
        throwsA(
          isA<AuthRepositoryException>().having(
            (e) => e.message,
            'message',
            'Failed to logout',
          ),
        ),
      );

      verify(() => mockAuthService.logout()).called(1);
    });
  });
}
