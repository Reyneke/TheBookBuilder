import 'dart:convert';

import 'package:book_builder/main_app.dart';
import 'package:book_builder/objects/obj_book_item.dart';
import 'package:book_builder/providers/provider_book_items.dart';
import 'package:crypto/crypto.dart';
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
  bool _getUserSetup = false;
  bool get getUserSetup => _getUserSetup;
  final String _userGroup = 'testers';
  String get userGroup => _userGroup;
  bool _isUserValidated = false;
  bool get isUserValidated => _isUserValidated;
  String _userId = "";
  String get userId => _userId;
  Map<String, dynamic> _userdata = {};
  Map<String, dynamic> get userData => _userdata;

  List<Map<String, dynamic>> _bookdata = [];
  List<Map<String, dynamic>> get bookdata => _bookdata;
  String _currentBook = 'Lorem Ipsum';
  String get currentBook => _currentBook;
  int currentBookId = 0;

  Future<void> upsertBook(Map<String, dynamic> bookData) async {
    try {
      // Die Primärschlüssel-Spalte(n) müssen im Objekt enthalten sein
      await supabase
          .from('books')
          .upsert(
            bookData,
            onConflict: 'id',
          ); // 'id' ist die Primärschlüssel-Spalte
    } catch (error) {
      //print('Upsert fehlgeschlagen: $error');
      throw ('Upsert fehlgeschlagen: $error');
    }
  }

  /// Saves EVERY item (header + subtopic) individually as its own "line"
  /// in the key-value store (SharedPreferences or Supabase).
  void saveToDoList(BuildContext context) async {
    final todoManager = context.read<ProviderBookItems>();
    final prefs = await SharedPreferences.getInstance();

    if (todoManager.allItems.isEmpty) return;

    for (var item in todoManager.allItems) {
      final String key = item.id.toString() + item.createdAt.toIso8601String();
      final itemMap = item.toMap();

      if (!getUseOnlineDB) {
        await prefs.setString(key, jsonEncode(itemMap));
      } else {
        List<int> bytes = utf8.encode(key);
        Digest sha256Hash = sha256.convert(bytes);
        await upsertBook({
          'id': item.id,
          'titel': currentBook,
          'team': userGroup,
          'chapters': jsonEncode(itemMap),
        });
      }

      // Add new keys
      if (!_keyRing.contains(key)) {
        _keyRing.add(key);
        await prefs.setString(_serviceKeys, _keyRing.join(" "));
      }
    }
  }

  Future<void> deleteItem(int bookId) async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.from('books').delete().eq('id', bookId);
    } catch (error) {
      //print('Fehler beim Löschen: $error');
    }
  }

  void removeFromList(BuildContext context, ObjBookItem deletedObject) async {
    final todoManager = context.read<ProviderBookItems>();

    if (todoManager.allItems.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    // If it's a header, remove all its subtopics too.
    if (deletedObject.isHeader) {
      final subtopics = todoManager.getSubtopicsForHeader(deletedObject.id);
      for (var sub in subtopics) {
        final String subKey =
            sub.id.toString() + sub.createdAt.toIso8601String();
        if (_keyRing.contains(subKey)) {
          _keyRing.remove(subKey);
          await prefs.setString(_serviceKeys, _keyRing.join(" "));
        }
        if (getUseOnlineDB) {
          await deleteItem(sub.id);
        } else {
          if (prefs.containsKey(subKey)) {
            prefs.remove(subKey);
          }
        }
      }
    }

    final String key =
        deletedObject.id.toString() + deletedObject.createdAt.toIso8601String();

    if (_keyRing.contains(key)) {
      _keyRing.remove(key);
      await prefs.setString(_serviceKeys, _keyRing.join(" "));
    }

    if (getUseOnlineDB) {
      await deleteItem(deletedObject.id);
    } else {
      if (prefs.containsKey(key)) {
        prefs.remove(key);
      }
    }
  }

  //Nur Aufruf beim AppStart
  void loadToDoList(BuildContext context) async {
    final todoManager = context.read<ProviderBookItems>();
    //resetAllSettings();
    //getOnlineOffline();
    await loadLastEditedBook();

    if (todoManager.allItems.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final keyStrings = (prefs.getString(_serviceKeys) ?? "");
      final subKeysString = keyStrings.split(" ");

      if (_getUseOnlineDB) {
        _bookdata = await getAllBooks();

        if (_bookdata.isNotEmpty) {
          for (var item in _bookdata) {
            final itemMap = jsonDecode(item['chapters']);
            final isHeader = itemMap['isHeader'] == true;
            if (isHeader) {
              final headerItem = ObjBookHeader.fromMapWithDefaults(itemMap);
              todoManager.addHeaderWithSubtopics(headerItem);
            } else {
              final todoListItem = ObjBookItem.fromMapWithDefaults(itemMap);
              todoManager.addItem(todoListItem);
            }
          }
          for (var key in subKeysString) {
            _keyRing.add(key);
          }
        }
      } else {
        for (var key in subKeysString) {
          final itemString = (prefs.getString(key));
          if (itemString != null) {
            final itemMap = jsonDecode(itemString);
            final isHeader = itemMap['isHeader'] == true;
            if (isHeader) {
              final headerItem = ObjBookHeader.fromMapWithDefaults(itemMap);
              todoManager.addHeaderWithSubtopics(headerItem);
            } else {
              final todoListItem = ObjBookItem.fromMapWithDefaults(itemMap);
              todoManager.addItem(todoListItem);
            }
            _keyRing.add(key);
          }
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> getAllBooks() async {
    final supabase = Supabase.instance.client;

    try {
      final books = await supabase
          .from('books')
          .select() // Alle Spalten abrufen
          .eq('titel', currentBook);
      //.order('titel', ascending: true); // Optional: nach Titel sortieren

      return books;
    } catch (error) {
      //print('Fehler beim Abrufen der Bücher: $error');
      throw Exception('Konnte Bücher nicht laden: $error');
    }
  }

  Future<PostgrestList?> getBookTitles(BuildContext context) async {
    final supabase = Supabase.instance.client;

    try {
      final books = await supabase
          .from('books')
          .select() // Alle Spalten abrufen
          .order('titel', ascending: true);
      //.single(); // Optional: nach Titel sortieren

      return books;
    } catch (error) {
      //print('Fehler beim Abrufen der Bücher: $error');
      if (context.mounted) {
        context.showSnackBar('Konnte Buchtitel nicht laden: $error');
      }
    }
    return null;
  }

  void setNewBookName(String newName, BuildContext context) async {
    final todoManager = context.read<ProviderBookItems>();
    final prefs = await SharedPreferences.getInstance();
    _currentBook = newName;
    await prefs.setString(_bookVaultKey, _currentBook);
    notifyListeners();

    todoManager.clearHeaderList(true);
  }

  Future<void> loadLastEditedBook() async {
    final prefs = await SharedPreferences.getInstance();
    _currentBook = (prefs.getString(_bookVaultKey) ?? "New Book");
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

  void toggleOnlineOffline(bool newStatus, BuildContext context) async {
    //final prefs = await SharedPreferences.getInstance();
    final todoManager = context.read<ProviderBookItems>();
    if (newStatus != _getUseOnlineDB) {
      _getUseOnlineDB = newStatus;
      //await prefs.setBool(_offlineKey, newStatus);
      if (todoManager.allItems.isNotEmpty) {
        todoManager.clearHeaderList(false);
      }
    }

    if ((!_getUseOnlineDB) && (supabase.auth.currentSession != null)) {
      await supabase.auth.signOut();
    }
    notifyListeners();
  }

  /*void getOnlineOffline() async {
    final prefs = await SharedPreferences.getInstance();
    _getUseOnlineDB = (prefs.getBool(_offlineKey) ?? false);
    //notifyListeners();
  }*/

  //User Daten hier
  void setUserValidated(bool newStatus) {
    _isUserValidated = newStatus;
    notifyListeners();
  }

  void setUserSetup(bool newStatus) {
    _getUserSetup = newStatus;
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
