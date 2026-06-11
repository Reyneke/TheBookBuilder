import 'package:book_builder/objects/obj_book_item.dart';
import 'package:flutter/material.dart';

class ProviderBookItems extends ChangeNotifier {
  final List<ObjBookItem> _todoList = [];
  List<ObjBookItem> get todoList => _todoList;

  final List<ObjBookHeader> _headerList = [];
  List<ObjBookHeader> get headerList => _headerList;

  final Set<ToDoFilter> _filters = <ToDoFilter>{ToDoFilter.alle};
  Set<ToDoFilter> get filters => _filters;

  final Set<Priority> _priofilter = <Priority>{};
  Set<Priority> get priofilter => _priofilter;

  ToDoSort _sortingOption = ToDoSort.prioritaet;
  ToDoSort get sortingOption => _sortingOption;

  //TODO remove
  int getToDoItems() {
    return _todoList.length;
  }

  void addItem(ObjBookItem newItem) {
    _todoList.add(newItem);
    notifyListeners();
  }

  void removeItem(ObjBookItem oldItem) {
    _todoList.remove(oldItem);
    notifyListeners();
  }

  int getItemPosition(List<ObjBookItem> index, ObjBookItem oldItem) {
    return index.indexWhere((element) => element.id == oldItem.id);
  }

  void clearList() {
    _todoList.clear();
    notifyListeners();
  }

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

  void addItemToHeader(int index, ObjBookItem newItem) {
    //_todoList.add(newItem);
    _headerList.elementAt(index).subTopics.add(newItem);
    notifyListeners();
  }

  void removeItemFromHeader(int index, ObjBookItem oldItem) {
    //_todoList.remove(oldItem);
    final position = getItemPosition(
      _headerList.elementAt(index).subTopics,
      oldItem,
    );
    if (position >= 0) {
      _headerList.elementAt(index).subTopics.removeAt(position);
      notifyListeners();
    }
  }

  void clearHeaderList() {
    _headerList.clear();
    notifyListeners();
  }

  void clearAllItemsFromHeader(int index) {
    _headerList.elementAt(index).subTopics.clear();
    notifyListeners();
  }

  void updateCompletion(int id, bool newState) {
    //_todoList[id].isCompleted = newState;
    _headerList[id].isCompleted = newState;
    notifyListeners();
  }

  void updateCompletionItem(int headerId, int id, bool newState) {
    //_todoList[id].isCompleted = newState;
    _headerList[headerId].subTopics[id].isCompleted = newState;
    notifyListeners();
  }

  void updateTitle(int id, String newTitle) {
    _headerList[id].title = newTitle;
    notifyListeners();
  }

  void updateTitleItem(int headerId, int id, String newTitle) {
    _headerList[headerId].subTopics[id].title = newTitle;
    notifyListeners();
  }

  void updateDescription(int id, String newDesc) {
    _headerList[id].description = newDesc;
    notifyListeners();
  }

  void updateDescriptionItem(int headerId, int id, String newDesc) {
    _headerList[headerId].subTopics[id].description = newDesc;
    notifyListeners();
  }

  void updatePriority(int id, Priority newPriority) {
    _headerList[id].priority = newPriority;
    notifyListeners();
  }

  void updatePriorityItem(int headerId, int id, Priority newPriority) {
    _headerList[headerId].subTopics[id].priority = newPriority;
    notifyListeners();
  }

  void updateCompletionDate(int id, DateTime newDate) {
    _headerList[id].dueDate = newDate;
    notifyListeners();
  }

  void updateCompletionDateItem(int headerId, int id, DateTime newDate) {
    _headerList[headerId].subTopics[id].dueDate = newDate;
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
}
