import 'dart:convert';
import 'dart:math';

import 'package:book_builder/objects/obj_book_item.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProviderBookItems extends ChangeNotifier {
  final List<ObjBookHeader> _headerList = [];
  List<ObjBookHeader> get headerList => _headerList;

  final Set<ToDoFilter> _filters = <ToDoFilter>{ToDoFilter.alle};
  Set<ToDoFilter> get filters => _filters;

  final Set<Priority> _priofilter = <Priority>{};
  Set<Priority> get priofilter => _priofilter;

  ToDoSort _sortingOption = ToDoSort.prioritaet;
  ToDoSort get sortingOption => _sortingOption;

  // ── Dirty-Tracking für inkrementelle Speicherung ─────────────
  final Set<int> _dirtyHeaderIds = <int>{};
  final Set<String> _dirtySubTopicKeys = <String>{};

  bool get hasDirtyItems =>
      _dirtyHeaderIds.isNotEmpty || _dirtySubTopicKeys.isNotEmpty;

  void markHeaderDirty(int headerId) {
    _dirtyHeaderIds.add(headerId);
    notifyListeners();
  }

  void markSubTopicDirty(int headerId, int subTopicId) {
    _dirtySubTopicKeys.add('${headerId}_$subTopicId');
    notifyListeners();
  }

  void clearDirtyFlags() {
    _dirtyHeaderIds.clear();
    _dirtySubTopicKeys.clear();
    notifyListeners();
  }

  Set<int> get dirtyHeaderIds => Set.unmodifiable(_dirtyHeaderIds);
  Set<String> get dirtySubTopicKeys => Set.unmodifiable(_dirtySubTopicKeys);

  // ── Hilfsmethoden ─────────────────────────────────────────────

  int getItemPosition(List<ObjBookItem> index, ObjBookItem oldItem) {
    return index.indexWhere((element) => element.id == oldItem.id);
  }

  ObjBookHeader getHeaderId(int id) {
    try {
      return _headerList.singleWhere((element) => element.id == id);
    } catch (e) {
      throw StateError(
        'Header mit ID $id wurde nicht gefunden (${_headerList.length} Header vorhanden)',
      );
    }
  }

  ObjBookItem getBookId(int id, ObjBookHeader header) {
    try {
      return header.subTopics.singleWhere((element) => element.id == id);
    } catch (e) {
      throw StateError(
        'BookItem mit ID $id wurde im Header ${header.id} nicht gefunden '
        '(${header.subTopics.length} Items vorhanden)',
      );
    }
  }

  List<ObjBookItem> getSubtopicsForHeader(int headerId) {
    try {
      final header = getHeaderId(headerId);
      return List<ObjBookItem>.from(header.subTopics);
    } catch (e) {
      debugPrint(
        'getSubtopicsForHeader fehlgeschlagen für headerId $headerId: $e',
      );
      return const [];
    }
  }

  // ── Header-Operationen ────────────────────────────────────────

  void addHeader(ObjBookHeader newHeader) {
    final existingIndex = _headerList.indexWhere(
      (element) => element.id == newHeader.id,
    );
    if (existingIndex >= 0) {
      debugPrint(
        'addHeader: Header mit ID ${newHeader.id} existiert bereits, übersprungen',
      );
      return;
    }
    _headerList.add(newHeader);
    markHeaderDirty(newHeader.id);
    notifyListeners();
  }

  void removeHeader(ObjBookHeader oldHeader) {
    final position = getItemPosition(_headerList, oldHeader);
    if (position >= 0) {
      oldHeader.subTopics.clear();
      _headerList.removeAt(position);
      _dirtyHeaderIds.remove(oldHeader.id);
      notifyListeners();
    } else {
      debugPrint('removeHeader: Header mit ID ${oldHeader.id} nicht gefunden');
    }
  }

  void recalculateDoD(int index, int amount) {
    try {
      getHeaderId(index).bookDod += amount;
    } catch (e) {
      debugPrint('recalculateDoD fehlgeschlagen für index $index: $e');
    }
  }

  void recalculateCounter(int index, int amount) {
    try {
      getHeaderId(index).bookCounter += amount;
    } catch (e) {
      debugPrint('recalculateCounter fehlgeschlagen für index $index: $e');
    }
  }

  void addItemToHeader(int index, ObjBookItem newItem) {
    try {
      final header = getHeaderId(index);
      header.subTopics.add(newItem);
      recalculateDoD(index, newItem.bookDod);
      markHeaderDirty(index);
      notifyListeners();
    } catch (e) {
      debugPrint('addItemToHeader fehlgeschlagen für index $index: $e');
    }
  }

  void removeItemFromHeader(int index, ObjBookItem oldItem) {
    try {
      final header = getHeaderId(index);
      final position = getItemPosition(header.subTopics, oldItem);
      if (position >= 0) {
        header.subTopics.removeAt(position);
        recalculateDoD(index, -oldItem.bookDod);
        markHeaderDirty(index);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('removeItemFromHeader fehlgeschlagen für index $index: $e');
    }
  }

  void clearHeaderList(bool getNotifyListeners) {
    _headerList.clear();
    _dirtyHeaderIds.clear();
    _dirtySubTopicKeys.clear();

    if (getNotifyListeners) {
      notifyListeners();
    }
  }

  void clearAllItemsFromHeader(int index) {
    try {
      getHeaderId(index).subTopics.clear();
      markHeaderDirty(index);
      notifyListeners();
    } catch (e) {
      debugPrint('clearAllItemsFromHeader fehlgeschlagen für index $index: $e');
    }
  }

  // ── Update-Operationen (mit Dirty-Tracking) ──────────────────

  void updateCompletion(int id, bool newState) {
    try {
      getHeaderId(id).isCompleted = newState;
      markHeaderDirty(id);
      notifyListeners();
    } catch (e) {
      debugPrint('updateCompletion fehlgeschlagen für id $id: $e');
    }
  }

  void updateCompletionItem(int headerId, int id, bool newState) {
    try {
      final header = getHeaderId(headerId);
      getBookId(id, header).isCompleted = newState;
      markSubTopicDirty(headerId, id);
      notifyListeners();
    } catch (e) {
      debugPrint(
        'updateCompletionItem fehlgeschlagen für headerId $headerId, id $id: $e',
      );
    }
  }

  void updateTitle(int id, String newTitle) {
    try {
      getHeaderId(id).title = newTitle;
      markHeaderDirty(id);
      notifyListeners();
    } catch (e) {
      debugPrint('updateTitle fehlgeschlagen für id $id: $e');
    }
  }

  void updateTitleItem(int headerId, int id, String newTitle) {
    try {
      getBookId(id, getHeaderId(headerId)).title = newTitle;
      markSubTopicDirty(headerId, id);
      notifyListeners();
    } catch (e) {
      debugPrint(
        'updateTitleItem fehlgeschlagen für headerId $headerId, id $id: $e',
      );
    }
  }

  void updateDescription(int id, String newDesc) {
    try {
      getHeaderId(id).description = newDesc;
      markHeaderDirty(id);
      notifyListeners();
    } catch (e) {
      debugPrint('updateDescription fehlgeschlagen für id $id: $e');
    }
  }

  void updateDescriptionItem(int headerId, int id, String newDesc) {
    try {
      getBookId(id, getHeaderId(headerId)).description = newDesc;
      markSubTopicDirty(headerId, id);
      notifyListeners();
    } catch (e) {
      debugPrint(
        'updateDescriptionItem fehlgeschlagen für headerId $headerId, id $id: $e',
      );
    }
  }

  void updateDodCounterItem(int headerId, int id, String newCount) {
    try {
      int newCounter = (int.tryParse(newCount) ?? 0);
      final item = getBookId(id, getHeaderId(headerId));
      int counterValue = newCounter - item.bookCounter;
      item.bookCounter = newCounter;
      recalculateCounter(headerId, counterValue);
      markSubTopicDirty(headerId, id);
      notifyListeners();
    } catch (e) {
      debugPrint(
        'updateDodCounterItem fehlgeschlagen für headerId $headerId, id $id: $e',
      );
    }
  }

  void updateDodItem(int headerId, int id, String newCount) {
    try {
      int newDod = (int.tryParse(newCount) ?? 0);
      final item = getBookId(id, getHeaderId(headerId));
      int dodValue = newDod - item.bookDod;
      item.bookDod = newDod;
      recalculateDoD(headerId, dodValue);
      markSubTopicDirty(headerId, id);
      notifyListeners();
    } catch (e) {
      debugPrint(
        'updateDodItem fehlgeschlagen für headerId $headerId, id $id: $e',
      );
    }
  }

  void updatePriority(int id, Priority newPriority) {
    try {
      getHeaderId(id).priority = newPriority;
      markHeaderDirty(id);
      notifyListeners();
    } catch (e) {
      debugPrint('updatePriority fehlgeschlagen für id $id: $e');
    }
  }

  void updatePriorityItem(int headerId, int id, Priority newPriority) {
    try {
      getBookId(id, getHeaderId(headerId)).priority = newPriority;
      markSubTopicDirty(headerId, id);
      notifyListeners();
    } catch (e) {
      debugPrint(
        'updatePriorityItem fehlgeschlagen für headerId $headerId, id $id: $e',
      );
    }
  }

  void updateCompletionDate(int id, DateTime newDate) {
    try {
      getHeaderId(id).dueDate = newDate;
      markHeaderDirty(id);
      notifyListeners();
    } catch (e) {
      debugPrint('updateCompletionDate fehlgeschlagen für id $id: $e');
    }
  }

  void updateCompletionDateItem(int headerId, int id, DateTime newDate) {
    try {
      getBookId(id, getHeaderId(headerId)).dueDate = newDate;
      markSubTopicDirty(headerId, id);
      notifyListeners();
    } catch (e) {
      debugPrint(
        'updateCompletionDateItem fehlgeschlagen für headerId $headerId, id $id: $e',
      );
    }
  }

  // ── Filter & Sortierung ──────────────────────────────────────

  void addFilter(ToDoFilter newFilter) {
    _filters.add(newFilter);
    notifyListeners();
  }

  void removeFilter(ToDoFilter oldFilter) {
    _filters.remove(oldFilter);
    notifyListeners();
  }

  void addPrioFilter(Priority newFilter) {
    _priofilter.add(newFilter);
    notifyListeners();
  }

  void removePrioFilter(Priority oldFilter) {
    _priofilter.remove(oldFilter);
    notifyListeners();
  }

  void cleanFilters() {
    _filters.clear();
    _priofilter.clear();
    notifyListeners();
  }

  void switchSortingOption(ToDoSort newOption) {
    _sortingOption = newOption;
    notifyListeners();
  }

  int getRandomKey() {
    int key =
        (Random().nextInt(DateTime.now().millisecond) +
        Random().nextInt(DateTime.now().millisecond));
    List<int> bytes = utf8.encode(key.toString());
    Digest sha256Hash = sha256.convert(bytes);
    return sha256Hash.hashCode;
  }
}
