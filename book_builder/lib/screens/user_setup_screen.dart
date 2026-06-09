import 'dart:convert';

import 'package:book_builder/main_app.dart';
import 'package:book_builder/providers/provider_service.dart';
import 'package:book_builder/screens/login_screen.dart';
import 'package:book_builder/widgets/app_user_avatar.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserSetupScreen extends StatefulWidget {
  const UserSetupScreen({super.key});

  @override
  State<UserSetupScreen> createState() => _UserSetupScreenState();
}

class _UserSetupScreenState extends State<UserSetupScreen> {
  final _usernameController = TextEditingController();
  final _useremailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _passwordController = TextEditingController();
  final _oldpasswordController = TextEditingController();

  String? _avatarUrl;
  var _loading = true;

  /// Called once a user id is received within `onAuthenticated()`
  Future<void> _getProfile() async {
    setState(() {
      _loading = true;
    });
    try {
      final userId = context
          .read<ProviderService>()
          .supabase
          .auth
          .currentSession!
          .user
          .id;
      final data = await context
          .read<ProviderService>()
          .supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      _usernameController.text = (data['username'] ?? '') as String;
      _websiteController.text = (data['website'] ?? '') as String;
      _avatarUrl = (data['avatar_url'] ?? '') as String;
    } on PostgrestException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _updatePasswordAndEmail() async {
    setState(() {
      _loading = true;
    });
    final userEmail = _useremailController.text.trim();
    final oldUserPassword = _oldpasswordController.text.trim();
    final userPassword = _passwordController.text.trim();

    try {
      if ((sha1.convert(utf8.encode(userPassword))) ==
          (sha1.convert(utf8.encode(oldUserPassword)))) {
        await context.read<ProviderService>().supabase.auth.updateUser(
          UserAttributes(email: userEmail, password: userPassword),
        );
      } else {
        if (mounted) {
          context.showSnackBar('Wrong password', isError: true);
        }
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  /// Called when user taps `Update` button
  Future<void> _updateProfile() async {
    setState(() {
      _loading = true;
    });
    final userName = _usernameController.text.trim();
    final website = _websiteController.text.trim();
    final user = context.read<ProviderService>().supabase.auth.currentUser;
    final updates = {
      'id': user!.id,
      'username': userName,
      'website': website,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      await context
          .read<ProviderService>()
          .supabase
          .from('profiles')
          .upsert(updates);
      if (mounted) context.showSnackBar('Successfully updated profile!');
    } on PostgrestException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  /// Called when image has been uploaded to Supabase storage from within Avatar widget
  Future<void> _onUpload(String imageUrl) async {
    try {
      final userId = context
          .read<ProviderService>()
          .supabase
          .auth
          .currentUser!
          .id;
      await context.read<ProviderService>().supabase.from('profiles').upsert({
        'id': userId,
        'avatar_url': imageUrl,
      });
      if (mounted) {
        const SnackBar(
          content: Text('Updated your profile image!'),
        );
      }
    } on PostgrestException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _avatarUrl = imageUrl;
    });
  }

  Future<void> _signOut() async {
    try {
      await context.read<ProviderService>().supabase.auth.signOut();
    } on AuthException catch (error) {
      if (mounted) context.showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }
    } finally {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    }
    _updatePasswordAndEmail();
  }

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _useremailController.dispose();
    _websiteController.dispose();
    _passwordController.dispose();
    _oldpasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(
        8,
      ), // .symmetric(vertical: 18, horizontal: 12),
      children: [
        const Text('Profile'),
        const SizedBox(height: 8),
        AppUserAvatar(
          imageUrl: _avatarUrl,
          onUpload: _onUpload,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _usernameController,
          decoration: const InputDecoration(labelText: 'User Name'),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _useremailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _websiteController,
          decoration: const InputDecoration(labelText: 'Website'),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _oldpasswordController,
          decoration: const InputDecoration(labelText: 'altes Passwort'),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'neues Passwort'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _loading ? null : _updateProfile,
          child: Text(_loading ? 'Saving...' : 'Update'),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: _signOut, child: const Text('Sign Out')),
      ],
    );
  }
}
