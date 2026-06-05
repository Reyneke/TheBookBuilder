import 'package:book_builder/objects/obj_todo.dart';
import 'package:flutter/material.dart';

class ProviderToDo extends ChangeNotifier {
  final List<ObjTodo> _todoList = [];
  List<ObjTodo> get todoList => _todoList;

  final List<ObjHeader> _headerList = [];
  List<ObjHeader> get headerList => _headerList;

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

  void addItem(ObjTodo newItem) {
    _todoList.add(newItem);
    notifyListeners();
  }

  void removeItem(ObjTodo oldItem) {
    _todoList.remove(oldItem);
    notifyListeners();
  }

  void clearList() {
    _todoList.clear();
    notifyListeners();
  }

  void addHeader(ObjHeader newHeader) {
    _headerList.add(newHeader);
    notifyListeners();
  }

  void removeHeader(ObjHeader oldHeader) {
    _headerList.remove(oldHeader);
    notifyListeners();
  }

  void addItemToHeader(int index, ObjTodo newItem) {
    //_todoList.add(newItem);
    _headerList.elementAt(index).subTopics.add(newItem);
    notifyListeners();
  }

  void removeItemFromHeader(int index, ObjTodo oldItem) {
    //_todoList.remove(oldItem);
    _headerList.elementAt(index).subTopics.remove(oldItem);
    notifyListeners();
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
    _todoList[id].isCompleted = newState;
    notifyListeners();
  }

  void updateTitle(int id, String newTitle) {
    _todoList[id].title = newTitle;
    notifyListeners();
  }

  void updateDescription(int id, String newDesc) {
    _todoList[id].description = newDesc;
    notifyListeners();
  }

  void updatePriority(int id, Priority newPriority) {
    _todoList[id].priority = newPriority;
    notifyListeners();
  }

  void updateCompletionDate(int id, DateTime newDate) {
    _todoList[id].dueDate = newDate;
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
