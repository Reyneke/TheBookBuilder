import 'dart:async';
import 'dart:convert';

import 'package:book_builder/main_app.dart';
import 'package:book_builder/providers/provider_service.dart';
import 'package:crypto/crypto.dart';
//import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:hcaptcha/hcaptcha.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final bool _isLoggingIn = false;
  bool _redirecting = false;
  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController =
      TextEditingController();
  late final StreamSubscription<AuthState> _authStateSubscription;
  final _formKey = GlobalKey<FormState>();
  String? captchaToken;

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
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
  }

  /* Site:--
fcce8250-ad2c-488a-b59a-c7263e62a634
Secret: ES_5dbc3e7f0c294bdd8e4d56e95e0bb074 

cloudflare site: 0x4AAAAAADiJzHJOzaHwl_39
cloduflare key: 0x4AAAAAADiJzJdDkYF08ILzcU63S74o9W4
*/

  Future<void> _signUpWithEmail(/*String email, String password*/) async {
    //Map? captchaDetails;
    if (_formKey.currentState!.validate()) {
      /*try {
        captchaDetails = await HCaptcha.show(context);
      } catch (e) {
        if (mounted) {
          context.showSnackBar("Fehler: $e", isError: true);
        }
      }*/

      // validated
      //if (captchaToken != null) {
      // now use captchaDetails['code']
      final userPassword = _passwordController.text.trim();
      List<int> bytes = utf8.encode(userPassword);
      Digest sha256Hash = sha256.convert(bytes);
      try {
        await context.read<ProviderService>().supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: sha256Hash.toString(), //_passwordController.text.trim(),
          //captchaToken: captchaToken,
        );
        if (mounted) {
          context.showSnackBar(
            "Registrierung erfolgreich! Bestätigungs-E-Mail wurde gesendet.",
            isError: false,
          );
        }
      } on AuthException catch (e) {
        if (mounted) {
          context.showSnackBar("Fehler: ${e.message}", isError: true);
        }
      }
      //}
    }
  }

  Future<void> _logIn() async {
    //Map? captchaDetails;
    /*try {
      captchaDetails = await HCaptcha.show(context);
    } catch (e) {
      if (mounted) {
        context.showSnackBar("Fehler: $e", isError: true);
      }
    }*/

    // validated
    //if (captchaToken != null) {
    // now use captchaDetails['code']
    try {
      setState(() {
        _isLoading = true;
      });
      final userPassword = _passwordController.text.trim();
      List<int> bytes = utf8.encode(userPassword);
      Digest sha256Hash = sha256.convert(bytes);
      await context.read<ProviderService>().supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: sha256Hash.toString(), //_passwordController.text.trim(),
        //captchaToken: captchaToken,
      );
      if (mounted) {
        context.showSnackBar('Vielen Dank. Sie werden nun eingeloggt ...');
        _emailController.clear();
        _passwordController.clear();
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
    //}
  }

  @override
  void initState() {
    _authStateSubscription = context
        .read<ProviderService>()
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
                MaterialPageRoute(builder: (context) => MainApp()),
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
    //HCaptcha.init(siteKey: 'fcce8250-ad2c-488a-b59a-c7263e62a634');
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
    // Turnstile widget configuration
    /*final TurnstileOptions options = TurnstileOptions(
      size: TurnstileSize.normal,
      theme: TurnstileTheme.light,
      language: 'de',
      retryAutomatically: false,
      refreshTimeout: TurnstileRefreshTimeout.manual,
    );*/

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(
          8,
        ), // .symmetric(vertical: 18, horizontal: 12),
        children: [
          const Text("Login"),
          const Text(
            'Loggen Sie sich bitte via Passwort ein oder klicken sie auf Registrieren um einen Anmeldelink zu bekommen.',
          ),
          const SizedBox(height: 8),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bitte geben Sie eine Emailadresse ein.';
              }

              if (!value.contains('@') && !value.contains('.')) {
                return 'Bitte geben Sie eine gültige Emailadresse ein.';
              }

              return null;
            },
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 8),
          TextFormField(
            //key: _formKey,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bitte geben Sie ein Passwort an.';
              }

              if (value.length < 8) {
                return 'Bitte wählen Sie ein Passwort, dass länger, als 8 Zeichen ist.';
              }
              return null;
            },
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Passwort'),
          ),
          /*const SizedBox(height: 8),
          CloudflareTurnstile(
            siteKey: '0x4AAAAAADiJzHJOzaHwl_39', //Change with your site key
            baseUrl: 'io.supabase.flutterquickstart',
            onTokenReceived: (token) {
              //print(token);
              captchaToken = token;
            },
          ),*/
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: _isLoggingIn ? null : _logIn,
                child: Text(_isLoggingIn ? 'Logge ein' : 'Einloggen'),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _registerUser,
                child: Text(_isLoading ? 'Erstelle...' : 'Link versenden'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
