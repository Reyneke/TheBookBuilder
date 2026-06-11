import 'dart:convert';

import 'package:book_builder/objects/obj_book_item.dart';
import 'package:book_builder/providers/provider_book_items.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProviderService extends ChangeNotifier {
  static const _serviceKeys = 'serviceKeys';
  static const _themeKey = 'themeKey';
  static const _offlineKey = 'offlineKey';
  static const _bookVaultKey = 'books';
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;
  bool _getUseOnlineDB = false;
  bool get getUseOnlineDB => _getUseOnlineDB;

  final List<String> _keyRing = [];
  List<String> get keyRing => _keyRing;

  final _supabase = Supabase.instance.client;
  SupabaseClient get supabase => _supabase;
  final String _userGroup = 'testers';
  String get userGroup => _userGroup;
  bool _isUserValidated = false;
  bool get isUserValidated => _isUserValidated;
  String _userId = "";
  String get userId => _userId;
  Map<String, dynamic> _userdata = {};
  Map<String, dynamic> get userData => _userdata;

  final Map<String, dynamic> _bookdata = {};
  Map<String, dynamic> get bookdata => _bookdata;
  final String _currentBook = 'test';
  String get currentBook => _currentBook;

  void saveToDoList(BuildContext context) async {
    final todoManager = context.read<ProviderBookItems>();
    if (todoManager.headerList.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();

      //Save all keys
      for (var toDoItem in todoManager.headerList) {
        final String key =
            toDoItem.id.toString() +
            //toDoItem.title +
            toDoItem.createdAt.toIso8601String();
        final toDoMap = toDoItem.toMap();

        await prefs.setString(key, jsonEncode(toDoMap));

        //Add new keys
        if (!_keyRing.contains(key)) {
          _keyRing.add(key);
          await prefs.setString(_serviceKeys, _keyRing.join(" "));
        }
      }
    }
  }

  void removeFromList(BuildContext context, ObjBookItem deletedObject) async {
    final todoManager = context.read<ProviderBookItems>();

    if (todoManager.headerList.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();

      //for (var toDoItem in todoManager.todoList) {
      final String key =
          deletedObject.id.toString() +
          deletedObject.createdAt.toIso8601String();

      if (_keyRing.contains(key)) {
        _keyRing.remove(key);
        await prefs.setString(_serviceKeys, _keyRing.join(" "));
      }

      if (prefs.containsKey(key)) {
        prefs.remove(key);
      }
      //}
    }
  }

  //Nur Aufruf beim AppStart
  void loadToDoList(BuildContext context) async {
    final todoManager = context.read<ProviderBookItems>();
    //resetAllSettings();
    getOnlineOffline();

    if (todoManager.headerList.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final keyStrings = (prefs.getString(_serviceKeys) ?? "");
      final subKeysString = keyStrings.split(" ");
      for (var key in subKeysString) {
        final toDoString = (prefs.getString(key));
        if (toDoString != null) {
          final toDoMap = jsonDecode(toDoString);
          final todoListItem = ObjBookHeader.fromMapWithDefaults(toDoMap);
          todoManager.addHeader(todoListItem);
          // .addItem(todoListItem);
          _keyRing.add(key);
        }
      }
    }
  }

  // Alle Einstellungen zurücksetzen
  Future<void> resetAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _keyRing.clear();
    await prefs.clear();
  }

  void saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  void getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = (prefs.getBool(_themeKey) ?? true);
  }

  void toggleOnlineOffline(bool newStatus) async {
    final prefs = await SharedPreferences.getInstance();
    _getUseOnlineDB = newStatus;
    await prefs.setBool(_offlineKey, newStatus);
    notifyListeners();
  }

  void getOnlineOffline() async {
    final prefs = await SharedPreferences.getInstance();
    _getUseOnlineDB = (prefs.getBool(_themeKey) ?? false);
  }

  void setUserValidated(bool newStatus) {
    _isUserValidated = newStatus;
    notifyListeners();
  }

  Future<Object?> updateUserData() async {
    if (supabase.auth.currentSession != null) {
      try {
        _userId = supabase.auth.currentSession!.user.id;
        _userdata = await supabase
            .from('profiles')
            .select()
            .eq('id', userId)
            .single();
        notifyListeners();
      } /*on PostgrestException catch (error) {
      //if (mounted) context.showSnackBar(error.message, isError: true);
    }*/ catch (error) {
        return error;
        /*if (mounted) {
        context.showSnackBar('Unexpected error occurred', isError: true);
      }*/
      }
    }
    return null;
  }
}
