import 'package:book_builder/objects/obj_todo.dart';
import 'package:book_builder/providers/provider_service.dart';
import 'package:book_builder/providers/provider_todo.dart';
import 'package:book_builder/widgets/to_do_priority_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ToDoListElement extends StatelessWidget {
  const ToDoListElement({
    super.key,
    required this.listItem,
    required this.index,
  });

  final /*ObjTodo*/ dynamic listItem;
  final int index;
  final String imageNotDone = "assets/images/echo_working.png";
  final String imageDone = "assets/images/echo_done.png";

  @override
  Widget build(BuildContext context) {
    return (listItem.runtimeType == ObjHeader)
        ? Column(
            children: [
              ListTile(
                leading: (listItem.runtimeType == ObjHeader)
                    ? IconButton(
                        onPressed: () {
                          context.read<ProviderToDo>().addItemToHeader(
                            listItem.id,
                            ObjTodo(
                              id: context
                                  .read<ProviderToDo>()
                                  .headerList[listItem.id]
                                  .subTopics
                                  .length,
                              description: "Leer",
                              title: "Leer",
                              isCompleted: false,
                              createdAt: DateTime.now(),
                              dueDate: DateTime.now(),
                              priority: Priority.low,
                            ),
                          );
                        },
                        icon: Icon(Icons.add),
                      )
                    : listItem.isCompleted
                    ? Image.asset(imageDone)
                    : Image.asset(imageNotDone),
                title: Text(listItem.title),
                subtitle: ToDoPriorityIndicator(priority: listItem.priority),
                trailing: Consumer<ProviderToDo>(
                  builder: (context, completed, child) {
                    return Checkbox(
                      onChanged: (result) {
                        context.read<ProviderToDo>().updateCompletion(
                          index,
                          (result ?? false),
                        );
                        context.read<ProviderService>().saveToDoList(context);
                      },
                      value: listItem.isCompleted,
                    );
                  },
                ),
              ),
              /*{
                if (listItem.subTopics.length > 0) {
                for (var subItem in listItem.subTopics)}
              }*/
            ],
          )
        : ListTile(
            leading: (listItem.runtimeType == ObjHeader)
                ? IconButton(
                    onPressed: () {
                      context.read<ProviderToDo>().addItemToHeader(
                        listItem.id,
                        ObjTodo(
                          id: context
                              .read<ProviderToDo>()
                              .headerList[listItem.id]
                              .subTopics
                              .length,
                          description: "Leer",
                          title: "Leer",
                          isCompleted: false,
                          createdAt: DateTime.now(),
                          dueDate: DateTime.now(),
                          priority: Priority.low,
                        ),
                      );
                    },
                    icon: Icon(Icons.add),
                  )
                : listItem.isCompleted
                ? Image.asset(imageDone)
                : Image.asset(imageNotDone),
            title: Text(listItem.title),
            subtitle: ToDoPriorityIndicator(priority: listItem.priority),
            trailing: Consumer<ProviderToDo>(
              builder: (context, completed, child) {
                return Checkbox(
                  onChanged: (result) {
                    context.read<ProviderToDo>().updateCompletion(
                      index,
                      (result ?? false),
                    );
                    context.read<ProviderService>().saveToDoList(context);
                  },
                  value: listItem.isCompleted,
                );
              },
            ),
          );
  }
}
