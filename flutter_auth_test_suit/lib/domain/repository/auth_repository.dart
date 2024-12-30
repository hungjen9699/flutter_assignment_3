import 'package:flutter_auth_test_suit/data/user_model/user.dart';

import '../../core/exceptions/exception.dart';
import '../api_service/auth_service.dart';

class AuthRepository {
  final AuthService authService;

  AuthRepository({required this.authService});

  Future<User?> login(String username, String password) async {
    try {
      return await authService.login(username, password);
    } on NoInternetException catch (e) {
      throw AuthRepositoryException(e.message);
    } on InvalidCredentialsException catch (e) {
      throw AuthRepositoryException(e.message);
    } on UnexpectedException catch (e) {
      throw AuthRepositoryException(e.message);
    } on GeneralException catch (e) {
      throw AuthRepositoryException(e.message);
    } catch (e) {
      throw AuthRepositoryException('An unexpected error occurred');
    }
  }

  Future<void> logout() async {
    try {
      await authService.logout();
    } on NoInternetException catch (e) {
      throw AuthRepositoryException(e.message);
    } catch (e) {
      throw AuthRepositoryException('An unexpected error occurred');
    }
  }
}
