import 'dart:async';

import 'package:book_builder/main_app.dart';
import 'package:book_builder/providers/provider_service.dart';
import 'package:book_builder/screens/screen_todo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _redirecting = false;
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController =
      TextEditingController();
  late final StreamSubscription<AuthState> _authStateSubscription;

  Future<void> _registerUser() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await context.read<ProviderService>().supabase.auth.signInWithOtp(
        email: _emailController.text.trim(),
        emailRedirectTo: kIsWeb
            ? null
            : 'io.supabase.flutterquickstart://login-callback/',
      );
      if (mounted) {
        context.showSnackBar(
          'Prüfen Sie Ihre Email für einen Link zum Einloggen!',
        );
        _emailController.clear();
      }
    } on AuthException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logIn() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await context.read<ProviderService>().supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        context.showSnackBar('Vielen Dank. Sie werden nun eingeloggt ...');
        _emailController.clear();
      }
    } on AuthException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    _authStateSubscription = context
        .watch<ProviderService>()
        .supabase
        .auth
        .onAuthStateChange
        .listen(
          (data) {
            if (_redirecting) return;
            final session = data.session;
            if (session != null) {
              _redirecting = true;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ScreenTodo()),
              );
            }
          },
          onError: (error) {
            if (error is AuthException) {
              context.showSnackBar(error.message, isError: true);
            } else {
              context.showSnackBar('Unexpected error occurred', isError: true);
            }
          },
        );
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(
        8,
      ), // .symmetric(vertical: 18, horizontal: 12),
      children: [
        const Text("Login"),
        const Text(
          'Folgen Sie dem Link in Ihrer Email, um sich zu registrieren oder geben Sie ihr Kennwort an',
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Passwort'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _logIn,
              child: Text(_isLoading ? 'Logge ein' : 'Einloggen'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _registerUser,
              child: Text(_isLoading ? 'Sende...' : 'Link versenden'),
            ),
          ],
        ),
      ],
    );
  }
}
