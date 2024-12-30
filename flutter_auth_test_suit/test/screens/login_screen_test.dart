import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_test_suit/main.dart';
import 'package:flutter_auth_test_suit/presentation/bloc/auth/auth.dart';
import 'package:flutter_auth_test_suit/presentation/screens/home_screen.dart';
import 'package:flutter_auth_test_suit/presentation/screens/login_screen.dart';
import 'package:flutter_auth_test_suit/presentation/screens/sign_up_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class AuthStateFake extends Fake implements AuthState {}

class AuthEventFake extends Fake implements AuthEvent {}

void main() {
  late AuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(AuthStateFake());
    registerFallbackValue(AuthEventFake());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  tearDown(() {
    mockAuthBloc.close();
  });

  Widget createScreenUnderTest() {
    return BlocProvider<AuthBloc>.value(
      value: mockAuthBloc,
      child: MaterialApp(
        title: 'Flutter Auth Bloc',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        navigatorKey: navigatorKey,
        routes: {
          '/': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/signup': (context) => const SignUpScreen(),
        },
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('renders all widgets correctly', (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(UnAuthenticated());

      await tester.pumpWidget(createScreenUnderTest());

      expect(find.text('Welcome,'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text("Don't have an account? Sign up"), findsOneWidget);
    });

    testWidgets('shows validation error when username is empty',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(UnAuthenticated());

      await tester.pumpWidget(createScreenUnderTest());
      final usernameField = find.byKey(const Key('username_text_field'));
      final loginButton = find.byType(ElevatedButton);
      await tester.enterText(usernameField, '');
      await tester.tap(loginButton);
      await tester.pump();

      expect(find.text('Username cannot be empty'), findsOneWidget);
    });

    testWidgets('shows validation error when password is empty',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(UnAuthenticated());

      await tester.pumpWidget(createScreenUnderTest());
      final passwordField = find.byKey(const Key('password_text_field'));
      final loginButton = find.byType(ElevatedButton);
      await tester.enterText(passwordField, '');
      await tester.tap(loginButton);
      await tester.pump();

      expect(find.text('Password cannot be empty'), findsOneWidget);
    });

    testWidgets('triggers LoginRequest when form is valid',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(UnAuthenticated());

      await tester.pumpWidget(createScreenUnderTest());
      final usernameField = find.byKey(const Key('username_text_field'));
      final passwordField = find.byKey(const Key('password_text_field'));
      final loginButton = find.byType(ElevatedButton);
      await tester.enterText(usernameField, 'emilys');
      await tester.enterText(passwordField, 'emilyspass');
      await tester.tap(loginButton);
      await tester.pump();

      verify(() => mockAuthBloc.add(
              const LoginRequest(username: 'emilys', password: 'emilyspass')))
          .called(1);
    });

    testWidgets('shows CircularProgressIndicator when AuthLoading state',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(AuthLoading());
      await tester.pumpWidget(createScreenUnderTest());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows SnackBar when AuthError state occurs',
        (WidgetTester tester) async {
      whenListen(
        mockAuthBloc,
        Stream<AuthState>.fromIterable(
            [const AuthError(message: 'Login failed')]),
        initialState: UnAuthenticated(),
      );

      await tester.pumpWidget(createScreenUnderTest());
      await tester.pump();

      expect(find.text('Login failed'), findsOneWidget);
    });

    testWidgets('navigates to SignUpScreen when Sign Up link is tapped',
        (WidgetTester tester) async {
      when(() => mockAuthBloc.state).thenReturn(UnAuthenticated());

      await tester.pumpWidget(createScreenUnderTest());

      final signUpLink = find.text("Don't have an account? Sign up");
      expect(signUpLink, findsOneWidget);

      await tester.tap(signUpLink);
      await tester.pumpAndSettle();

      expect(find.byType(SignUpScreen), findsOneWidget);
    });
  });
}
