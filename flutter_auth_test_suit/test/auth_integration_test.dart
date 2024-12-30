import 'package:flutter_auth_test_suit/core/exceptions/exception.dart';
import 'package:flutter_auth_test_suit/core/utils/app_config.dart';
import 'package:flutter_auth_test_suit/data/user_model/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_auth_test_suit/domain/api_service/auth_service.dart';
import 'package:flutter_auth_test_suit/domain/repository/auth_repository.dart';
import 'package:flutter_auth_test_suit/presentation/bloc/auth/auth_bloc.dart';
import 'package:flutter_auth_test_suit/presentation/bloc/auth/auth_event.dart';
import 'package:flutter_auth_test_suit/presentation/bloc/auth/auth_state.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthService mockAuthService;
  late AuthRepository authRepository;
  late AuthBloc authBloc;

  setUp(() async {
    final jsonMap = await ConfigReader.readConfigFile();
    AppConfig(jsonMap);

    mockAuthService = MockAuthService();
    authRepository = AuthRepository(authService: mockAuthService);
    authBloc = AuthBloc(authRepository: authRepository);

    final getIt = GetIt.instance;
    if (!getIt.isRegistered<AuthService>()) {
      getIt.registerSingleton<AuthService>(mockAuthService);
    }
    if (!getIt.isRegistered<AuthRepository>()) {
      getIt.registerSingleton<AuthRepository>(authRepository);
    }
    if (!getIt.isRegistered<AuthBloc>()) {
      getIt.registerSingleton<AuthBloc>(authBloc);
    }
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  group('Authentication Integration Tests', () {
    const testUser = User(
      id: 1,
      username: 'emilys',
      firstName: 'Emily',
      lastName: 'Johnson',
      gender: 'gender',
      image: 'image',
      email: 'emily.johnson@x.dummyjson.com',
    );

    test('Login success flow', () async {
      const testUsername = 'emilys';
      const testPassword = 'emilyspass';

      when(() => mockAuthService.login(testUsername, testPassword))
          .thenAnswer((_) async => testUser);

      authBloc.add(
          const LoginRequest(username: testUsername, password: testPassword));

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          AuthLoading(),
          const Authenticated(user: testUser),
        ]),
      );

      verify(() => mockAuthService.login(testUsername, testPassword)).called(1);
    });

    test('Login failure flow with InvalidCredentialsException', () async {
      const testUsername = 'wrong@test.com';
      const testPassword = 'wrongpassword';

      when(() => mockAuthService.login(testUsername, testPassword))
          .thenThrow(InvalidCredentialsException('Invalid credentials'));
      authBloc.add(
          const LoginRequest(username: testUsername, password: testPassword));

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          AuthLoading(),
          const AuthError(message: 'Invalid credentials'),
        ]),
      );

      verify(() => mockAuthService.login(testUsername, testPassword)).called(1);
    });

    test('Login failure flow with NoInternetException', () async {
      const testUsername = 'emilys';
      const testPassword = 'emilyspass';

      when(() => mockAuthService.login(testUsername, testPassword))
          .thenThrow(NoInternetException('No Internet Connection'));

      authBloc.add(
          const LoginRequest(username: testUsername, password: testPassword));

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          AuthLoading(),
          const AuthError(message: 'No Internet Connection'),
        ]),
      );

      verify(() => mockAuthService.login(testUsername, testPassword)).called(1);
    });

    test('Login failure flow with UnexpectedException', () async {
      const testUsername = 'emilys';
      const testPassword = 'emilyspass';

      when(() => mockAuthService.login(testUsername, testPassword))
          .thenThrow(UnexpectedException('Unexpected error occurred'));

      authBloc.add(
          const LoginRequest(username: testUsername, password: testPassword));

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          AuthLoading(),
          const AuthError(message: 'Unexpected error occurred'),
        ]),
      );

      verify(() => mockAuthService.login(testUsername, testPassword)).called(1);
    });

    test('Login failure flow with GeneralException', () async {
      const testUsername = 'emilys';
      const testPassword = 'emilyspass';

      when(() => mockAuthService.login(testUsername, testPassword))
          .thenThrow(GeneralException('General error'));

      authBloc.add(
          const LoginRequest(username: testUsername, password: testPassword));

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          AuthLoading(),
          const AuthError(message: 'General error'),
        ]),
      );

      verify(() => mockAuthService.login(testUsername, testPassword)).called(1);
    });

    test('Login failure flow with an unknown exception', () async {
      const testUsername = 'emilys';
      const testPassword = 'emilyspass';

      when(() => mockAuthService.login(testUsername, testPassword))
          .thenThrow(Exception('Unknown exception'));

      authBloc.add(
          const LoginRequest(username: testUsername, password: testPassword));

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          AuthLoading(),
          const AuthError(message: 'An unexpected error occurred'),
        ]),
      );

      verify(() => mockAuthService.login(testUsername, testPassword)).called(1);
    });

    test('Logout success flow', () async {
      when(() => mockAuthService.logout()).thenAnswer((_) async => {});

      authBloc.add(LogoutRequest());

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          AuthLoading(),
          UnAuthenticated(),
        ]),
      );

      verify(() => mockAuthService.logout()).called(1);
    });

    test('Logout failure flow with AuthRepositoryException', () async {
      when(() => mockAuthService.logout())
          .thenThrow(AuthRepositoryException('Failed to logout'));

      authBloc.add(LogoutRequest());
      await expectLater(
        authBloc.stream,
        emitsInOrder([
          AuthLoading(),
          const AuthError(message: 'Failed to logout'),
        ]),
      );

      verify(() => mockAuthService.logout()).called(1);
    });

    test('Logout failure flow with an unknown exception', () async {
      when(() => mockAuthService.logout())
          .thenThrow(Exception('Unknown logout exception'));

      authBloc.add(LogoutRequest());

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          AuthLoading(),
          const AuthError(message: 'An unexpected error occurred'),
        ]),
      );

      verify(() => mockAuthService.logout()).called(1);
    });
  });
}
