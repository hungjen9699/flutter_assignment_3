import 'package:flutter_auth_test_suit/core/exceptions/exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_auth_test_suit/data/user_model/user.dart';
import 'package:flutter_auth_test_suit/domain/repository/auth_repository.dart';
import 'package:flutter_auth_test_suit/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter_auth_test_suit/presentation/bloc/auth/auth_event.dart';
import 'package:flutter_auth_test_suit/presentation/bloc/auth/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;

  setUpAll(() {});

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  group('AuthBloc Tests', () {
    const testUser = User(
      id: 1,
      username: 'emilys',
      firstName: 'Emily',
      lastName: 'Johnson',
      gender: 'gender',
      image: 'image',
      email: 'emily.johnson@x.dummyjson.com',
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when login is successful',
      build: () {
        when(() => mockAuthRepository.login('emilys', 'emilyspass'))
            .thenAnswer((_) async => testUser);
        return authBloc;
      },
      act: (bloc) => bloc
          .add(const LoginRequest(username: 'emilys', password: 'emilyspass')),
      expect: () => [
        AuthLoading(),
        const Authenticated(user: testUser),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.login('emilys', 'emilyspass'))
            .called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails with InvalidCredentialsException',
      build: () {
        when(() => mockAuthRepository.login('emilys', 'wrongpass'))
            .thenThrow(AuthRepositoryException('Invalid credentials'));
        return authBloc;
      },
      act: (bloc) => bloc
          .add(const LoginRequest(username: 'emilys', password: 'wrongpass')),
      expect: () => [
        AuthLoading(),
        const AuthError(message: 'Invalid credentials'),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.login('emilys', 'wrongpass')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails with NoInternetException',
      build: () {
        when(() => mockAuthRepository.login('emilys', 'emilyspass'))
            .thenThrow(AuthRepositoryException('No Internet Connection'));
        return authBloc;
      },
      act: (bloc) => bloc
          .add(const LoginRequest(username: 'emilys', password: 'emilyspass')),
      expect: () => [
        AuthLoading(),
        const AuthError(message: 'No Internet Connection'),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.login('emilys', 'emilyspass'))
            .called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails with UnexpectedException',
      build: () {
        when(() => mockAuthRepository.login('emilys', 'emilyspass'))
            .thenThrow(AuthRepositoryException('Unexpected error occurred'));
        return authBloc;
      },
      act: (bloc) => bloc
          .add(const LoginRequest(username: 'emilys', password: 'emilyspass')),
      expect: () => [
        AuthLoading(),
        const AuthError(message: 'Unexpected error occurred'),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.login('emilys', 'emilyspass'))
            .called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails with GeneralException',
      build: () {
        when(() => mockAuthRepository.login('emilys', 'emilyspass'))
            .thenThrow(AuthRepositoryException('General error'));
        return authBloc;
      },
      act: (bloc) => bloc
          .add(const LoginRequest(username: 'emilys', password: 'emilyspass')),
      expect: () => [
        AuthLoading(),
        const AuthError(message: 'General error'),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.login('emilys', 'emilyspass'))
            .called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails with an unknown exception',
      build: () {
        when(() => mockAuthRepository.login('emilys', 'emilyspass'))
            .thenThrow(Exception('Unknown exception'));
        return authBloc;
      },
      act: (bloc) => bloc
          .add(const LoginRequest(username: 'emilys', password: 'emilyspass')),
      expect: () => [
        AuthLoading(),
        const AuthError(message: 'An unexpected error occurred'),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.login('emilys', 'emilyspass'))
            .called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, UnAuthenticated] when logout is successful',
      build: () {
        when(() => mockAuthRepository.logout()).thenAnswer((_) async => {});
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequest()),
      expect: () => [
        AuthLoading(),
        UnAuthenticated(),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.logout()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when logout fails with AuthRepositoryException',
      build: () {
        when(() => mockAuthRepository.logout())
            .thenThrow(AuthRepositoryException('Failed to logout'));
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequest()),
      expect: () => [
        AuthLoading(),
        const AuthError(message: 'Failed to logout'),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.logout()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when logout fails with an unknown exception',
      build: () {
        when(() => mockAuthRepository.logout())
            .thenThrow(Exception('Unknown logout exception'));
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequest()),
      expect: () => [
        AuthLoading(),
        const AuthError(message: 'An unexpected error occurred'),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.logout()).called(1);
      },
    );
  });
}
