import 'dart:convert';
import 'dart:math';

import 'package:book_builder/objects/obj_book_item.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class ProviderBookItems extends ChangeNotifier {
  //final List<ObjBookItem> _todoList = [];
  //List<ObjBookItem> get todoList => _todoList;

  final List<ObjBookHeader> _headerList = [];
  List<ObjBookHeader> get headerList => _headerList;

  final Set<ToDoFilter> _filters = <ToDoFilter>{ToDoFilter.alle};
  Set<ToDoFilter> get filters => _filters;

  final Set<Priority> _priofilter = <Priority>{};
  Set<Priority> get priofilter => _priofilter;

  ToDoSort _sortingOption = ToDoSort.prioritaet;
  ToDoSort get sortingOption => _sortingOption;

  //TODO remove
  /*int getToDoItems() {
    return _todoList.length;
  }

  void addItem(ObjBookItem newItem) {
    _todoList.add(newItem);
    notifyListeners();
  }

  void removeItem(ObjBookItem oldItem) {
    _todoList.remove(oldItem);
    notifyListeners();
  }*/

  int getItemPosition(List<ObjBookItem> index, ObjBookItem oldItem) {
    return index.indexWhere((element) => element.id == oldItem.id);
  }

  ObjBookHeader getHeaderId(int id) {
    return _headerList.singleWhere((element) => element.id == id);
  }

  ObjBookItem getBookId(int id, ObjBookHeader header) {
    return header.subTopics.singleWhere((element) => element.id == id);
  }

  /*void clearList() {
    _todoList.clear();
    notifyListeners();
  }*/

  void addHeader(ObjBookHeader newHeader) {
    _headerList.add(newHeader);
    notifyListeners();
  }

  void removeHeader(ObjBookHeader oldHeader) {
    final position = getItemPosition(_headerList, oldHeader);
    if (position >= 0) {
      oldHeader.subTopics.clear();
      _headerList.removeAt(position);
      notifyListeners();
    }
  }

  void recalculateDoD(int index, int amount) {
    getHeaderId(index).bookDod += amount;
  }

  void recalculateCounter(int index, int amount) {
    getHeaderId(index).bookCounter += amount;
  }

  void addItemToHeader(int index, ObjBookItem newItem) {
    //_todoList.add(newItem);
    getHeaderId(index).subTopics.add(newItem);
    recalculateDoD(index, newItem.bookDod);
    notifyListeners();
  }

  void removeItemFromHeader(int index, ObjBookItem oldItem) {
    //_todoList.remove(oldItem);
    final position = getItemPosition(
      getHeaderId(index).subTopics,
      oldItem,
    );
    if (position >= 0) {
      getHeaderId(index).subTopics.removeAt(position);
      recalculateDoD(index, -oldItem.bookDod);
      notifyListeners();
    }
  }

  void clearHeaderList(bool getNotifyListeners) {
    _headerList.clear();

    if (getNotifyListeners) {
      notifyListeners();
    }
  }

  void clearAllItemsFromHeader(int index) {
    getHeaderId(index).subTopics.clear();
    notifyListeners();
  }

  void updateCompletion(int id, bool newState) {
    //_todoList[id].isCompleted = newState;
    getHeaderId(id).isCompleted = newState;
    notifyListeners();
  }

  void updateCompletionItem(int headerId, int id, bool newState) {
    //_todoList[id].isCompleted = newState;
    getBookId(id, getHeaderId(headerId)).isCompleted = newState;
    notifyListeners();
  }

  void updateTitle(int id, String newTitle) {
    getHeaderId(id).title = newTitle;
    //_headerList[id].title = newTitle;
    notifyListeners();
  }

  void updateTitleItem(int headerId, int id, String newTitle) {
    getBookId(id, getHeaderId(headerId)).title = newTitle;
    //_headerList[headerId].subTopics[id].title = newTitle;
    notifyListeners();
  }

  void updateDescription(int id, String newDesc) {
    getHeaderId(id).description = newDesc;
    notifyListeners();
  }

  void updateDescriptionItem(int headerId, int id, String newDesc) {
    getBookId(id, getHeaderId(headerId)).description = newDesc;
    notifyListeners();
  }

  /*void updateDodCounter(int id, String newCount) {
    getHeaderId(id).bookCounter = (int.tryParse(newCount) ?? 0);
    notifyListeners();
  }*/

  void updateDodCounterItem(int headerId, int id, String newCount) {
    int newCounter = (int.tryParse(newCount) ?? 0);
    int counterValue =
        newCounter - getBookId(id, getHeaderId(headerId)).bookCounter;
    getBookId(id, getHeaderId(headerId)).bookCounter = newCounter;
    recalculateCounter(headerId, counterValue);
    notifyListeners();
  }

  /*void updateDod(int id, String newCount) {
    getHeaderId(id).bookDod = (int.tryParse(newCount) ?? 0);
    notifyListeners();
  }*/

  void updateDodItem(int headerId, int id, String newCount) {
    int newDod = (int.tryParse(newCount) ?? 0);
    int dodValue = newDod - getBookId(id, getHeaderId(headerId)).bookDod;
    getBookId(id, getHeaderId(headerId)).bookDod = newDod;
    recalculateDoD(headerId, dodValue);
    notifyListeners();
  }

  void updatePriority(int id, Priority newPriority) {
    getHeaderId(id).priority = newPriority;
    notifyListeners();
  }

  void updatePriorityItem(int headerId, int id, Priority newPriority) {
    getBookId(id, getHeaderId(headerId)).priority = newPriority;
    notifyListeners();
  }

  void updateCompletionDate(int id, DateTime newDate) {
    getHeaderId(id).dueDate = newDate;
    notifyListeners();
  }

  void updateCompletionDateItem(int headerId, int id, DateTime newDate) {
    getBookId(id, getHeaderId(headerId)).dueDate = newDate;
    notifyListeners();
  }

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
