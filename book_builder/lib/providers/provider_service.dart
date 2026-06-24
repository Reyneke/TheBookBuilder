import 'dart:async';
import 'dart:convert';

import 'package:book_builder/main_app.dart';
import 'package:book_builder/objects/obj_book_item.dart';
import 'package:book_builder/providers/provider_book_items.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProviderService extends ChangeNotifier {
  static const _serviceKeys = 'serviceKeys';
  static const _themeKey = 'themeKey';
  static const _bookVaultKey = 'books';
  static const _headerKeyPrefix = 'hdr_';
  static const _subTopicKeyPrefix = 'sub_';
  static const _lockKeyPrefix = 'lock_';
  static const _maxModificationHistory = 32;
  static const _lockTimeout = Duration(minutes: 5);
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
  bool _isCheckingUserValidation = false;
  bool get isCheckingUserValidation => _isCheckingUserValidation;
  String _userId = "";
  String get userId => _userId;
  Map<String, dynamic> _userdata = {};
  Map<String, dynamic> get userData => _userdata;

  List<Map<String, dynamic>> _bookdata = [];
  List<Map<String, dynamic>> get bookdata => _bookdata;
  String _currentBook = 'Lorem Ipsum';
  String get currentBook => _currentBook;
  int currentBookId = 0;

  // ── Lock management ──────────────────────────────────────────
  final Map<int, Timer> _lockTimers = {};
  final Map<int, String> _lockOwners = {};

  Future<bool> acquireLock(int bookId) async {
    if (_userId.isEmpty) return false;
    if (_lockOwners[bookId] == _userId) {
      _lockTimers[bookId]?.cancel();
      _lockTimers[bookId] = Timer(_lockTimeout, () => releaseLock(bookId));
      return true;
    }
    if (_lockOwners.containsKey(bookId)) return false;

    try {
      if (!_getUseOnlineDB) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('$_lockKeyPrefix$bookId', _userId);
      } else {
        await supabase
            .from('books')
            .update({'in_use_by': _userId})
            .eq('id', bookId);
      }
      _lockOwners[bookId] = _userId;
      _lockTimers[bookId] = Timer(_lockTimeout, () => releaseLock(bookId));
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<void> releaseLock(int bookId) async {
    _lockTimers[bookId]?.cancel();
    _lockTimers.remove(bookId);
    _lockOwners.remove(bookId);
    try {
      if (!_getUseOnlineDB) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('$_lockKeyPrefix$bookId');
      } else {
        await supabase
            .from('books')
            .update({'in_use_by': null})
            .eq('id', bookId);
      }
    } catch (error) {
      debugPrint('releaseLock failed: $error');
    }
  }

  bool hasLock(int bookId) => _lockOwners[bookId] == _userId;

  Future<void> releaseAllLocks() async {
    final bookIds = List<int>.from(
      _lockOwners.keys.where((id) => _lockOwners[id] == _userId),
    );
    for (final bookId in bookIds) {
      await releaseLock(bookId);
    }
  }

  // ── Key helpers ──────────────────────────────────────────────

  String _makeHeaderKey(ObjBookItem header) =>
      '$_headerKeyPrefix${header.id}_${header.createdAt.toIso8601String()}';

  String _makeSubTopicKey(int headerId, ObjBookItem subTopic) =>
      '$_subTopicKeyPrefix${headerId}_${subTopic.id}_${subTopic.createdAt.toIso8601String()}';

  bool _isHeaderKey(String key) => key.startsWith(_headerKeyPrefix);

  bool _isSubTopicKey(String key) => key.startsWith(_subTopicKeyPrefix);

  int? _headerIdFromSubKey(String key) {
    if (!_isSubTopicKey(key)) return null;
    final withoutPrefix = key.substring(_subTopicKeyPrefix.length);
    final parts = withoutPrefix.split('_');
    if (parts.isEmpty) return null;
    return int.tryParse(parts[0]);
  }

  int _headerIdFromDbId(int dbId) {
    if (dbId >= 0) return dbId;
    return (-dbId) >> 32;
  }

  int _subTopicDbId(int headerId, int subTopicId) {
    final maskedHeader = headerId & 0xFFFFFFFF;
    final maskedSub = subTopicId & 0xFFFFFFFF;
    return -((maskedHeader << 32) | maskedSub);
  }

  List<dynamic>? _appendToModificationList(
    List<dynamic> currentList,
    dynamic newEntry,
  ) {
    final list = List<dynamic>.from(currentList);
    list.add(newEntry);
    if (list.length > _maxModificationHistory) {
      return null;
    }
    return list;
  }

  Future<void> upsertBook(Map<String, dynamic> bookData) async {
    try {
      await supabase
          .from('books')
          .upsert(
            bookData,
            onConflict: 'id',
          );
    } catch (error) {
      debugPrint('Upsert fehlgeschlagen: $error');
      throw Exception('Upsert fehlgeschlagen: $error');
    }
  }

  // ── Incremental Save ─────────────────────────────────────────
  void saveToDoList(BuildContext context) async {
    final todoManager = context.read<ProviderBookItems>();
    if (!todoManager.hasDirtyItems) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // ── Dirty Headers speichern ──────────────────────────────
      for (final headerId in todoManager.dirtyHeaderIds) {
        final header = todoManager.getHeaderId(headerId);
        final headerKey = _makeHeaderKey(header);
        final headerMap = header.toMap()..remove('subTopics');
        headerMap['_bookTitel'] = _currentBook;

        if (!getUseOnlineDB) {
          await prefs.setString(headerKey, jsonEncode(headerMap));
        } else {
          final now = DateTime.now().toIso8601String().split('T').first;
          final bookId = header.id;

          List<dynamic>? lastModifiedAt;
          List<dynamic>? lastModifiedBy;
          try {
            final existing = await supabase
                .from('books')
                .select('last_modified_at, last_modified_by')
                .eq('id', bookId)
                .maybeSingle();
            if (existing != null) {
              lastModifiedAt = existing['last_modified_at'] as List<dynamic>?;
              lastModifiedBy = existing['last_modified_by'] as List<dynamic>?;
            }
          } catch (_) {}

          final updatedModifiedAt = _appendToModificationList(
            lastModifiedAt ?? [],
            now,
          );
          final updatedModifiedBy = _appendToModificationList(
            lastModifiedBy ?? [],
            _userId,
          );

          await upsertBook({
            'id': bookId,
            'titel': currentBook,
            'team': userGroup,
            'chapters': jsonEncode(headerMap),
            'sub_chapters': null,
            'last_modified_at': updatedModifiedAt,
            'last_modified_by': updatedModifiedBy,
          });
        }

        if (!_keyRing.contains(headerKey)) {
          _keyRing.add(headerKey);
        }
      }

      // ── Dirty Sub-Topics speichern ──────────────────────────
      for (final subKey in todoManager.dirtySubTopicKeys) {
        final parts = subKey.split('_');
        final headerId = int.tryParse(parts[0]) ?? 0;
        final subTopicId = int.tryParse(parts[1]) ?? 0;

        final header = todoManager.getHeaderId(headerId);
        final subTopic = header.subTopics.firstWhere(
          (s) => s.id == subTopicId,
          orElse: () => header.subTopics.isNotEmpty
              ? header.subTopics.first
              : ObjBookItem(
                  id: 0,
                  title: '',
                  description: '',
                  isCompleted: false,
                  createdAt: DateTime.now(),
                  dueDate: DateTime.now(),
                  priority: Priority.low,
                  isHeader: false,
                  headerId: headerId,
                  bookDod: 0,
                  bookCounter: 0,
                ),
        );

        final subTopicKey = _makeSubTopicKey(headerId, subTopic);
        final subMap = subTopic.toMap();
        subMap['_bookTitel'] = _currentBook;
        subMap['_parentHeaderId'] = headerId;

        if (!getUseOnlineDB) {
          await prefs.setString(subTopicKey, jsonEncode(subMap));
        } else {
          final bookId = _subTopicDbId(headerId, subTopic.id);

          List<dynamic>? lastModifiedAt;
          List<dynamic>? lastModifiedBy;
          try {
            final existing = await supabase
                .from('books')
                .select('last_modified_at, last_modified_by')
                .eq('id', bookId)
                .maybeSingle();
            if (existing != null) {
              lastModifiedAt = existing['last_modified_at'] as List<dynamic>?;
              lastModifiedBy = existing['last_modified_by'] as List<dynamic>?;
            }
          } catch (_) {}

          final now = DateTime.now().toIso8601String().split('T').first;
          final updatedModifiedAt = _appendToModificationList(
            lastModifiedAt ?? [],
            now,
          );
          final updatedModifiedBy = _appendToModificationList(
            lastModifiedBy ?? [],
            _userId,
          );

          await upsertBook({
            'id': bookId,
            'titel': currentBook,
            'team': userGroup,
            'chapters': jsonEncode(headerId),
            'sub_chapters': jsonEncode(subMap),
            'last_modified_at': updatedModifiedAt,
            'last_modified_by': updatedModifiedBy,
          });
        }

        if (!_keyRing.contains(subTopicKey)) {
          _keyRing.add(subTopicKey);
        }
      }

      await prefs.setString(_serviceKeys, _keyRing.join(" "));
      todoManager.clearDirtyFlags();
    } catch (error) {
      debugPrint('saveToDoList fehlgeschlagen: $error');
      if (context.mounted) {
        context.showSnackBar(
          'Fehler beim Speichern: $error',
          isError: true,
        );
      }
    }
  }

  // ── Delete ───────────────────────────────────────────────────

  Future<void> deleteItem(int bookId) async {
    try {
      await supabase.from('books').delete().eq('id', bookId);
    } catch (error) {
      debugPrint('Fehler beim Löschen: $error');
    }
  }

  void removeFromList(BuildContext context, ObjBookItem deletedObject) async {
    final todoManager = context.read<ProviderBookItems>();

    try {
      if (todoManager.headerList.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();

        if (deletedObject.isHeader) {
          final headerKey = _makeHeaderKey(deletedObject);

          final subKeysToRemove = _keyRing
              .where((k) => _headerIdFromSubKey(k) == deletedObject.id)
              .toList();

          for (final subKey in subKeysToRemove) {
            if (getUseOnlineDB) {
              final withoutPrefix = subKey.substring(_subTopicKeyPrefix.length);
              final parts = withoutPrefix.split('_');
              final subId = parts.length >= 2 ? int.tryParse(parts[1]) : null;
              if (subId != null) {
                await deleteItem(_subTopicDbId(deletedObject.id, subId));
              }
            } else {
              if (prefs.containsKey(subKey)) {
                await prefs.remove(subKey);
              }
            }
            _keyRing.remove(subKey);
          }

          if (_keyRing.contains(headerKey)) {
            _keyRing.remove(headerKey);
            if (getUseOnlineDB) {
              final allBooks = await getAllBooks();
              for (var book in allBooks) {
                final id = book['id'] as int? ?? 0;
                if (id < 0 && _headerIdFromDbId(id) == deletedObject.id) {
                  await deleteItem(id);
                }
              }
              await deleteItem(deletedObject.id);
            } else {
              if (prefs.containsKey(headerKey)) {
                await prefs.remove(headerKey);
              }
            }
          }

          await prefs.setString(_serviceKeys, _keyRing.join(" "));
        } else {
          ObjBookHeader parentHeader;
          try {
            parentHeader = todoManager.headerList.firstWhere(
              (h) => h.subTopics.contains(deletedObject),
            );
          } catch (_) {
            try {
              parentHeader = todoManager.getHeaderId(deletedObject.headerId);
            } catch (_) {
              debugPrint(
                'removeFromList: Parent-Header für sub-topic '
                '${deletedObject.id} nicht gefunden',
              );
              return;
            }
          }

          final subKey = _makeSubTopicKey(parentHeader.id, deletedObject);

          if (_keyRing.contains(subKey)) {
            _keyRing.remove(subKey);
            await prefs.setString(_serviceKeys, _keyRing.join(" "));
          }

          if (getUseOnlineDB) {
            await deleteItem(
              _subTopicDbId(parentHeader.id, deletedObject.id),
            );
          } else {
            if (prefs.containsKey(subKey)) {
              await prefs.remove(subKey);
            }
          }
        }
      }
    } catch (error) {
      debugPrint('removeFromList fehlgeschlagen: $error');
      if (context.mounted) {
        context.showSnackBar(
          'Fehler beim Löschen: $error',
          isError: true,
        );
      }
    }
  }

  // ── Load ─────────────────────────────────────────────────────

  void loadToDoList(BuildContext context) async {
    final todoManager = context.read<ProviderBookItems>();
    try {
      await loadLastEditedBook();

      if (todoManager.headerList.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final keyStrings = (prefs.getString(_serviceKeys) ?? "");
        final subKeysString = keyStrings.isNotEmpty
            ? keyStrings.split(" ")
            : <String>[];

        if (_getUseOnlineDB) {
          _bookdata = await getAllBooks();

          if (_bookdata.isNotEmpty) {
            // First pass: load all headers
            for (var item in _bookdata) {
              try {
                final chaptersData = item['chapters'];
                if (chaptersData == null) continue;

                final decoded = jsonDecode(chaptersData as String);
                if (decoded is Map<String, dynamic>) {
                  final headerItem = ObjBookHeader.fromMapWithDefaults(decoded);
                  todoManager.addHeader(headerItem);
                }
              } catch (e) {
                debugPrint('Fehler beim Laden eines Headers aus DB: $e');
              }
            }

            // Sort headers by creation timestamp to ensure correct order
            todoManager.headerList.sort(
              (a, b) => a.createdAt.compareTo(b.createdAt),
            );

            // Second pass: load all sub-topics (headers now guaranteed to exist)
            for (var item in _bookdata) {
              try {
                final chaptersData = item['chapters'];
                if (chaptersData == null) continue;

                final decoded = jsonDecode(chaptersData as String);
                if (decoded is num) {
                  final headerId = decoded.toInt();
                  final subChapters = item['sub_chapters'];
                  if (subChapters == null) continue;
                  final subMap =
                      jsonDecode(subChapters as String) as Map<String, dynamic>;
                  final subItem = ObjBookItem.fromMapWithDefaults(subMap);
                  try {
                    final parent = todoManager.getHeaderId(headerId);
                    final exists = parent.subTopics.any(
                      (s) => s.id == subItem.id,
                    );
                    if (!exists) {
                      parent.subTopics.add(subItem);
                    }
                  } catch (_) {
                    debugPrint(
                      'Fehler: Header $headerId nicht gefunden für Sub-Topic',
                    );
                  }
                }
              } catch (e) {
                debugPrint('Fehler beim Laden eines Sub-Topics aus DB: $e');
              }
            }

            todoManager.notifyListeners();

            _keyRing.clear();
            for (var key in subKeysString) {
              if (key.isNotEmpty) {
                _keyRing.add(key);
              }
            }
          }
        } else {
          final headerKeys = <String>[];
          final subTopicKeys = <String>[];

          for (var key in subKeysString) {
            if (key.isEmpty) continue;
            if (_isHeaderKey(key)) {
              headerKeys.add(key);
            } else if (_isSubTopicKey(key)) {
              subTopicKeys.add(key);
            }
            _keyRing.add(key);
          }

          for (var key in headerKeys) {
            try {
              final jsonString = prefs.getString(key);
              if (jsonString != null && jsonString.isNotEmpty) {
                final Map<String, dynamic> headerMap =
                    jsonDecode(jsonString) as Map<String, dynamic>;
                final bookTitel = headerMap['_bookTitel'] as String? ?? '';
                if (bookTitel.isNotEmpty && bookTitel != _currentBook) {
                  continue;
                }
                final headerItem = ObjBookHeader.fromMapWithDefaults(headerMap);
                todoManager.addHeader(headerItem);
              }
            } catch (e) {
              debugPrint('Fehler beim Laden eines Headers aus SharedPrefs: $e');
            }
          }

          for (var key in subTopicKeys) {
            try {
              final jsonString = prefs.getString(key);
              if (jsonString != null && jsonString.isNotEmpty) {
                final Map<String, dynamic> subMap =
                    jsonDecode(jsonString) as Map<String, dynamic>;
                final bookTitel = subMap['_bookTitel'] as String? ?? '';
                if (bookTitel.isNotEmpty && bookTitel != _currentBook) {
                  continue;
                }
                final subItem = ObjBookItem.fromMapWithDefaults(subMap);
                final parentId = _headerIdFromSubKey(key) ?? 0;
                try {
                  final parent = todoManager.getHeaderId(parentId);
                  parent.subTopics.add(subItem);
                } catch (_) {
                  // Header not found – skip orphaned sub-topic
                }
              }
            } catch (e) {
              debugPrint(
                'Fehler beim Laden eines Sub-Topics aus SharedPrefs: $e',
              );
            }
          }
          todoManager.notifyListeners();
        }
      }
    } catch (error) {
      debugPrint('loadToDoList fehlgeschlagen: $error');
      if (context.mounted) {
        context.showSnackBar('Fehler beim Laden: $error', isError: true);
      }
    }
  }

  // ── Book queries ─────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getAllBooks() async {
    try {
      final books = await supabase
          .from('books')
          .select()
          .eq('titel', currentBook)
          .order('created_at', ascending: true);
      return books;
    } catch (error) {
      debugPrint('Konnte Bücher nicht laden: $error');
      throw Exception('Konnte Bücher nicht laden: $error');
    }
  }

  Future<List<String>> getAllUsers() async {
    try {
      final users = await supabase
          .from('profiles')
          .select('username')
          .order('username', ascending: true);

      return users
          .map((user) => user['username'] as String)
          .where((username) => username.isNotEmpty)
          .toList();
    } catch (error) {
      debugPrint('Konnte Benutzer nicht laden: $error');
      return [];
    }
  }

  Future<PostgrestList?> getBookTitles(BuildContext context) async {
    try {
      final books = await supabase
          .from('books')
          .select('titel')
          .order('titel', ascending: true);

      final seen = <String>{};
      final distinctBooks = <Map<String, dynamic>>[];
      for (var book in books) {
        final titel = book['titel'] as String? ?? '';
        if (seen.add(titel)) {
          distinctBooks.add({'titel': titel});
        }
      }
      return distinctBooks;
    } catch (error) {
      debugPrint('Konnte Buchtitel nicht laden: $error');
      if (context.mounted) {
        context.showSnackBar('Konnte Buchtitel nicht laden: $error');
      }
    }
    return null;
  }

  // ── Book name ────────────────────────────────────────────────

  void setNewBookName(String newName, BuildContext context) async {
    final todoManager = context.read<ProviderBookItems>();
    if (newName.trim().isEmpty) {
      if (context.mounted) {
        context.showSnackBar('Buchname darf nicht leer sein', isError: true);
      }
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentBook = newName.trim();
      await prefs.setString(_bookVaultKey, _currentBook);
      notifyListeners();
      todoManager.clearHeaderList(true);
    } catch (error) {
      debugPrint('setNewBookName fehlgeschlagen: $error');
      if (context.mounted) {
        context.showSnackBar(
          'Fehler beim Setzen des Buchnamens: $error',
          isError: true,
        );
      }
    }
  }

  Future<void> loadLastEditedBook() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentBook = (prefs.getString(_bookVaultKey) ?? "New Book");
    } catch (error) {
      debugPrint('loadLastEditedBook fehlgeschlagen: $error');
      _currentBook = "New Book";
    }
  }

  // ── Settings ─────────────────────────────────────────────────

  Future<void> resetAllSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _keyRing.clear();
      await releaseAllLocks();
      await prefs.clear();
    } catch (error) {
      debugPrint('resetAllSettings fehlgeschlagen: $error');
    }
  }

  void saveTheme(bool isDarkMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDarkMode);
    } catch (error) {
      debugPrint('saveTheme fehlgeschlagen: $error');
    }
  }

  void getTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = (prefs.getBool(_themeKey) ?? true);
    } catch (error) {
      debugPrint('getTheme fehlgeschlagen: $error');
      _isDarkMode = true;
    }
  }

  void toggleOnlineOffline(bool newStatus, BuildContext context) async {
    final todoManager = context.read<ProviderBookItems>();
    try {
      if (newStatus != _getUseOnlineDB) {
        _getUseOnlineDB = newStatus;
        if (todoManager.headerList.isNotEmpty) {
          todoManager.clearHeaderList(false);
        }
      }

      if ((!_getUseOnlineDB) && (supabase.auth.currentSession != null)) {
        await supabase.auth.signOut();
      }
      notifyListeners();
    } catch (error) {
      debugPrint('toggleOnlineOffline fehlgeschlagen: $error');
    }
  }

  // ── User data ────────────────────────────────────────────────

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
        _isCheckingUserValidation = true;
        notifyListeners();
        _userId = supabase.auth.currentSession!.user.id;
        _userdata = await supabase
            .from('profiles')
            .select()
            .eq('id', userId)
            .single();
        _isCheckingUserValidation = false;
        notifyListeners();
      } catch (error) {
        _isCheckingUserValidation = false;
        notifyListeners();
        debugPrint('updateUserData fehlgeschlagen: $error');
        return error;
      }
    }
    return null;
  }

  Future<bool> checkUserEnabled(String userId) async {
    try {
      final result = await supabase
          .from('profiles')
          .select('is_enabled')
          .eq('id', userId)
          .maybeSingle();

      if (result != null) {
        return result['is_enabled'] as bool? ?? false;
      }
      return false;
    } catch (error) {
      debugPrint('checkUserEnabled fehlgeschlagen: $error');
      return false;
    }
  }
}
