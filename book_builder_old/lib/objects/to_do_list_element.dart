import 'package:book_builder/objects/obj_book_item.dart';
import 'package:book_builder/providers/provider_book_items.dart';
import 'package:book_builder/providers/provider_service.dart';
import 'package:book_builder/widgets/to_do_priority_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ToDoListElement extends StatelessWidget {
  const ToDoListElement({
    super.key,
    required this.listItem,
    required this.index,
  });

  final ObjBookItem listItem;
  final int index;
  final String imageNotDone = "assets/images/echo_working.png";
  final String imageDone = "assets/images/echo_done.png";

  @override
  Widget build(BuildContext context) {
    final isHeader = (listItem.runtimeType == ObjBookHeader) ? true : false;
    return ListTile(
      leading: isHeader
          ? IconButton(
              onPressed: () {
                context.read<ProviderBookItems>().addItemToHeader(
                  listItem.id,
                  ObjBookItem(
                    id: context
                        .read<ProviderBookItems>()
                        .headerList[listItem.id]
                        .subTopics
                        .length,
                    description: "Leer",
                    title: "Leer",
                    isCompleted: false,
                    createdAt: DateTime.now(),
                    dueDate: DateTime.now(),
                    priority: Priority.low,
                    isHeader: false,
                    headerId: listItem.id,
                    bookDod: 4500,
                    bookCounter: 0,
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
      trailing: Consumer<ProviderBookItems>(
        builder: (context, completed, child) {
          return Checkbox(
            onChanged: (result) {
              isHeader
                  ? context.read<ProviderBookItems>().updateCompletion(
                      index,
                      (result ?? false),
                    )
                  : context.read<ProviderBookItems>().updateCompletionItem(
                      listItem.headerId,
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
