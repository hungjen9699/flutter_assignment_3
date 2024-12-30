import 'package:flutter/material.dart';
import 'package:flutter_auth_test_suit/core/utils/app_config.dart';
import 'package:flutter_auth_test_suit/presentation/screens/sign_up_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'injection/injection.dart';
import 'presentation/bloc/auth/auth.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final jsonMap = await ConfigReader.readConfigFile();
  AppConfig(
    jsonMap,
  );
  Injection().setupInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            navigatorKey.currentState?.pushReplacementNamed('/home');
          } else if (state is UnAuthenticated) {
            navigatorKey.currentState?.pushReplacementNamed('/');
          }
        },
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
      ),
    );
  }
}
