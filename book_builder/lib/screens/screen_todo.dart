import 'package:book_builder/objects/obj_book_item.dart';
import 'package:book_builder/objects/to_do_list_element.dart';
import 'package:book_builder/providers/provider_book_items.dart';
import 'package:book_builder/providers/provider_service.dart';
import 'package:book_builder/widgets/app_user_data.dart';
import 'package:book_builder/widgets/dialog_confirm_delete.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScreenTodo extends StatefulWidget {
  const ScreenTodo({super.key});

  @override
  State<ScreenTodo> createState() => _ScreenTodoState();
}

class _ScreenTodoState extends State<ScreenTodo> {
  List<ObjBookItem> getCondensedList() {
    List<ObjBookItem> condensedList = [];
    final todoManager = context.read<ProviderBookItems>();

    for (var header in todoManager.headerList) {
      condensedList.add(header);
      final subtopics = todoManager.getSubtopicsForHeader(header.id);
      for (var topic in subtopics) {
        condensedList.add(topic);
      }

      if (subtopics.isNotEmpty) {
        sortFilteredList(subtopics, todoManager);
      }
    }

    return condensedList;
  }

  @override
  Widget build(BuildContext context) {
    final todoManager = context.watch<ProviderBookItems>();
    final filteredList = getCondensedList().where((element) {
      return getFilteredList(todoManager, element);
    }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Text('Keine ToDos verteilt.'),
      );
    }

    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final listItem = filteredList[index];
        return Dismissible(
          key: listItem.key,
          confirmDismiss: (direction) {
            return showDialog(
              context: context,
              builder: (BuildContext context) {
                return DialogConfirmDelete();
              },
            );
          },
          onDismissed: (direction) {
            setState(() {
              filteredList.removeAt(index);
            });

            if (listItem is ObjBookHeader) {
              context.read<ProviderBookItems>().removeHeader(listItem);
              context.read<ProviderService>().removeFromList(context, listItem);
            } else {
              context.read<ProviderBookItems>().removeItemFromHeader(
                listItem.headerId,
                listItem,
              );
              context.read<ProviderService>().saveToDoList(context);
            }

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              SnackBar(content: Text('${listItem.title} dismissed')),
            );
          },
          background: Container(color: Colors.red),
          child: Card(
            elevation: 4,
            child: GestureDetector(
              onTap: () {
                toDoBottomSheet(context, listItem, listItem.id);
              },
              child: ToDoListElement(
                listItem: listItem,
                index: listItem.id,
              ),
            ),
          ),
        );
      },
    );
  }

  void sortFilteredList(
    List<ObjBookItem> filteredList,
    ProviderBookItems todoManager,
  ) {
    filteredList.sort(
      (element, compareElement) {
        if (todoManager.sortingOption == ToDoSort.prioritaet) {
          return element.priority.name.toLowerCase().compareTo(
            compareElement.priority.name.toLowerCase(),
          );
        }

        if (todoManager.sortingOption == ToDoSort.titel) {
          return element.title.toLowerCase().compareTo(
            compareElement.title.toLowerCase(),
          );
        }

        if (todoManager.sortingOption == ToDoSort.faelligkeitsdatum) {
          return element.dueDate.compareTo(compareElement.dueDate);
        }

        return element.createdAt.compareTo(compareElement.createdAt);
      },
    );
  }

  bool getFilteredList(ProviderBookItems todoManager, ObjBookItem element) {
    if (todoManager.filters.contains(ToDoFilter.alle)) {
      return true;
    }
    if (todoManager.filters.contains(ToDoFilter.offen) &&
        !element.isCompleted) {
      return true;
    }
    if (todoManager.filters.contains(ToDoFilter.erledigt) &&
        element.isCompleted) {
      return true;
    }
    if (todoManager.filters.contains(ToDoFilter.ueberfaellig) &&
        ((element.createdAt == element.dueDate) ||
            (DateTime.now().isAfter(element.dueDate)))) {
      return true;
    }
    if (todoManager.priofilter.contains(Priority.low) &&
        (element.priority == Priority.low)) {
      return true;
    }
    if (todoManager.priofilter.contains(Priority.medium) &&
        (element.priority == Priority.medium)) {
      return true;
    }
    if (todoManager.priofilter.contains(Priority.high) &&
        (element.priority == Priority.high)) {
      return true;
    }

    return false;
  }

  Future<dynamic> toDoBottomSheet(
    BuildContext context,
    ObjBookItem listItem,
    int index,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        ProviderService serviceController = context.watch<ProviderService>();
        TextEditingController titelController = TextEditingController();
        TextEditingController descriptionController = TextEditingController();
        final GlobalKey<FormState> formKey = GlobalKey<FormState>();

        titelController.text = listItem.title;
        descriptionController.text = listItem.description;

        return AppUserData(
          formKey: formKey,
          titelController: titelController,
          serviceController: serviceController,
          descriptionController: descriptionController,
          index: index,
          isHeader: listItem.isHeader,
          headerIndex: listItem.headerId,
        );
      },
    );
  }
}
