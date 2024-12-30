import 'package:flutter/material.dart';
import 'package:flutter_auth_test_suit/presentation/bloc/auth/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _onLogoutButtonPressed(BuildContext context) {
    BlocProvider.of<AuthBloc>(context).add(LogoutRequest());
  }

  @override
  Widget build(BuildContext context) {
    final AuthState state = context.watch<AuthBloc>().state;

    String userEmail = '';
    if (state is Authenticated) {
      userEmail = state.user.email ?? '';
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _onLogoutButtonPressed(context),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome, $userEmail',
          style: const TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
