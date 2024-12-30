import 'package:flutter_auth_test_suit/domain/repository/auth_repository.dart';
import 'package:flutter_auth_test_suit/presentation/bloc/auth/auth_bloc.dart';
import 'package:get_it/get_it.dart';

import '../domain/api_service/auth_service.dart';

final GetIt getIt = GetIt.instance;

class Injection {
  static final Injection _instance = Injection._internal();

  factory Injection() => _instance;

  Injection._internal();

  void setupInjection() {
    getIt.registerLazySingleton<AuthService>(() => AuthService());
    getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepository(authService: getIt<AuthService>()));
    getIt.registerFactory<AuthBloc>(
        () => AuthBloc(authRepository: getIt<AuthRepository>()));
  }
}
