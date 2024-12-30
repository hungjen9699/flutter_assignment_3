import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/image_constant.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginButtonPressed() {
    setState(() => _autoValidateMode = AutovalidateMode.onUserInteraction);

    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginRequest(
              username: _usernameController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }

  String? _validateusername(String? value) {
    if (value == null || value.isEmpty) return 'Username cannot be empty';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password cannot be empty';
    return value.length >= 8 ? null : 'Password must be at least 8 characters';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidateMode,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                _buildLoginIllustration(context),
                const SizedBox(height: 20),
                const Text(
                  'Welcome,',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 30),
                _buildusernameField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 24),
                _buildLoginButton(),
                const SizedBox(height: 16),
                _buildSignUpLink(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginIllustration(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 4,
      child: Image.asset(
        key: const Key('login_illustration'),
        ImageConstants.loginIllustration,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildusernameField() {
    return TextFormField(
      key: const Key('username_text_field'),
      controller: _usernameController,
      decoration: _buildInputDecoration('username'),
      validator: _validateusername,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      key: const Key('password_text_field'),
      controller: _passwordController,
      decoration: _buildInputDecoration('Password'),
      obscureText: true,
      validator: _validatePassword,
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const CircularProgressIndicator();
        }
        return SizedBox(
          width: 100,
          child: ElevatedButton(
            onPressed: _onLoginButtonPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffff7568),
              foregroundColor: Colors.white,
            ),
            child: const Text('Login'),
          ),
        );
      },
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, '/signup'),
      child: const Text("Don't have an account? Sign up"),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
