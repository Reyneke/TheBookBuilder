import 'dart:convert';
import 'dart:math';

import 'package:book_builder/objects/obj_book_item.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class ProviderBookItems extends ChangeNotifier {
  /// Flat list of ALL items (headers and subtopics) stored linewise.
  /// Each item is an independent "line." Headers and their subtopics are
  /// linked via [ObjBookItem.headerId] rather than object nesting.
  final List<ObjBookItem> _allItems = [];

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// Returns all items (flat list).
  List<ObjBookItem> get allItems => List.unmodifiable(_allItems);

  /// Returns only header items.
  List<ObjBookHeader> get headerList =>
      _allItems.whereType<ObjBookHeader>().toList();

  /// Returns all subtopics (non-header items) for the given header id.
  List<ObjBookItem> getSubtopicsForHeader(int headerId) {
    return _allItems
        .where((item) => !item.isHeader && item.headerId == headerId)
        .toList();
  }

  final Set<ToDoFilter> _filters = <ToDoFilter>{ToDoFilter.alle};
  Set<ToDoFilter> get filters => _filters;

  final Set<Priority> _priofilter = <Priority>{};
  Set<Priority> get priofilter => _priofilter;

  ToDoSort _sortingOption = ToDoSort.prioritaet;
  ToDoSort get sortingOption => _sortingOption;

  // ---------------------------------------------------------------------------
  // Lookup helpers
  // ---------------------------------------------------------------------------

  int getItemPosition(List<ObjBookItem> list, ObjBookItem oldItem) {
    return list.indexWhere((element) => element.id == oldItem.id);
  }

  /// Finds any item by its [id].
  ObjBookItem getItemById(int id) {
    return _allItems.singleWhere((element) => element.id == id);
  }

  /// Finds a header by its [id].
  ObjBookHeader getHeaderId(int id) {
    return _allItems.singleWhere(
          (element) => element.id == id && element.isHeader,
        )
        as ObjBookHeader;
  }

  /// Finds a subtopic by its [id] within the given [header].
  /// Note: the [header] parameter is kept for backwards compatibility but
  /// lookup is now done from the flat list.
  ObjBookItem getBookId(int id, ObjBookHeader header) {
    return _allItems.singleWhere((element) => element.id == id);
  }

  // ---------------------------------------------------------------------------
  // Mutators – linewise (single item at a time)
  // ---------------------------------------------------------------------------

  /// Adds a single item (header or subtopic) to the flat list.
  void addItem(ObjBookItem newItem) {
    _allItems.add(newItem);
    notifyListeners();
  }

  /// Removes a single item from the flat list.
  void removeItem(ObjBookItem oldItem) {
    _allItems.remove(oldItem);
    notifyListeners();
  }

  /// Adds a header and all its subtopics from the legacy nested structure.
  /// Used when loading old data that still uses the nested [subTopics] list.
  void addHeaderWithSubtopics(ObjBookHeader header) {
    _allItems.add(header);
    for (var sub in header.subTopics) {
      _allItems.add(sub);
    }
    notifyListeners();
  }

  void addHeader(ObjBookHeader newHeader) {
    // Flatten: only add the header itself, not its subTopics (they should be
    // added individually via [addItem] or [addItemToHeader]).
    _allItems.add(newHeader);
    notifyListeners();
  }

  void removeHeader(ObjBookHeader oldHeader) {
    _allItems.removeWhere((item) => item.headerId == oldHeader.id);
    _allItems.remove(oldHeader);
    notifyListeners();
  }

  void recalculateDoD(int index, int amount) {
    getHeaderId(index).bookDod += amount;
  }

  void recalculateCounter(int index, int amount) {
    getHeaderId(index).bookCounter += amount;
  }

  void addItemToHeader(int headerId, ObjBookItem newItem) {
    _allItems.add(newItem);
    recalculateDoD(headerId, newItem.bookDod);
    notifyListeners();
  }

  void removeItemFromHeader(int headerId, ObjBookItem oldItem) {
    _allItems.remove(oldItem);
    recalculateDoD(headerId, -oldItem.bookDod);
    notifyListeners();
  }

  void clearHeaderList(bool getNotifyListeners) {
    _allItems.clear();
    if (getNotifyListeners) {
      notifyListeners();
    }
  }

  void clearAllItemsFromHeader(int headerId) {
    _allItems.removeWhere(
      (item) => item.headerId == headerId && !item.isHeader,
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Field updaters
  // ---------------------------------------------------------------------------

  void updateCompletion(int id, bool newState) {
    getHeaderId(id).isCompleted = newState;
    notifyListeners();
  }

  void updateCompletionItem(int headerId, int id, bool newState) {
    getItemById(id).isCompleted = newState;
    notifyListeners();
  }

  void updateTitle(int id, String newTitle) {
    getHeaderId(id).title = newTitle;
    notifyListeners();
  }

  void updateTitleItem(int headerId, int id, String newTitle) {
    getItemById(id).title = newTitle;
    notifyListeners();
  }

  void updateDescription(int id, String newDesc) {
    getHeaderId(id).description = newDesc;
    notifyListeners();
  }

  void updateDescriptionItem(int headerId, int id, String newDesc) {
    getItemById(id).description = newDesc;
    notifyListeners();
  }

  void updateDodCounterItem(int headerId, int id, String newCount) {
    int newCounter = (int.tryParse(newCount) ?? 0);
    final item = getItemById(id);
    int counterValue = newCounter - item.bookCounter;
    item.bookCounter = newCounter;
    recalculateCounter(headerId, counterValue);
    notifyListeners();
  }

  void updateDodItem(int headerId, int id, String newCount) {
    int newDod = (int.tryParse(newCount) ?? 0);
    final item = getItemById(id);
    int dodValue = newDod - item.bookDod;
    item.bookDod = newDod;
    recalculateDoD(headerId, dodValue);
    notifyListeners();
  }

  void updatePriority(int id, Priority newPriority) {
    getHeaderId(id).priority = newPriority;
    notifyListeners();
  }

  void updatePriorityItem(int headerId, int id, Priority newPriority) {
    getItemById(id).priority = newPriority;
    notifyListeners();
  }

  void updateCompletionDate(int id, DateTime newDate) {
    getHeaderId(id).dueDate = newDate;
    notifyListeners();
  }

  void updateCompletionDateItem(int headerId, int id, DateTime newDate) {
    getItemById(id).dueDate = newDate;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Filters / Sorting
  // ---------------------------------------------------------------------------

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
    _priofilter.clear;
    notifyListeners();
  }

  void switchSortingOption(ToDoSort newOption) {
    _sortingOption = newOption;
    notifyListeners();
  }

  int getRandomKey() {
    int key =
        (Random().nextInt(
          DateTime.now().millisecond,
        ) +
        Random().nextInt(
          DateTime.now().millisecond,
        ));
    List<int> bytes = utf8.encode(key.toString());
    Digest sha256Hash = sha256.convert(bytes);
    return sha256Hash.hashCode;
  }
}
