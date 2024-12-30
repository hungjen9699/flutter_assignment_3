import 'package:bloc/bloc.dart';

import '../../../core/exceptions/exception.dart';
import '../../../data/user_model/user.dart';
import '../../../domain/repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequest>(_onLoginRequested);
    on<LogoutRequest>(_onLogoutRequested);
  }
  Future<void> _onLoginRequested(
      LoginRequest event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final User? user =
          await authRepository.login(event.username, event.password);
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(UnAuthenticated());
      }
    } on AuthRepositoryException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(const AuthError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onLogoutRequested(
      LogoutRequest event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(UnAuthenticated());
    } on AuthRepositoryException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(const AuthError(message: 'An unexpected error occurred'));
    }
  }
}
