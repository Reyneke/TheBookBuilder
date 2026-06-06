import 'dart:convert';

import 'package:book_builder/objects/obj_todo.dart';
import 'package:book_builder/providers/provider_todo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProviderService extends ChangeNotifier {
  static const _serviceKeys = 'serviceKeys';
  static const _themeKey = 'themeKey';
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  final List<String> _keyRing = [];
  List<String> get keyRing => _keyRing;

  void saveToDoList(BuildContext context) async {
    final todoManager = context.read<ProviderToDo>();
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

  void removeFromList(BuildContext context, ObjTodo deletedObject) async {
    final todoManager = context.read<ProviderToDo>();

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
    final todoManager = context.read<ProviderToDo>();
    //resetAllSettings();

    if (todoManager.headerList.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final keyStrings = (prefs.getString(_serviceKeys) ?? "");
      final subKeysString = keyStrings.split(" ");
      for (var key in subKeysString) {
        final toDoString = (prefs.getString(key));
        if (toDoString != null) {
          final toDoMap = jsonDecode(toDoString);
          final todoListItem = ObjHeader.fromMapWithDefaults(toDoMap);
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
}
