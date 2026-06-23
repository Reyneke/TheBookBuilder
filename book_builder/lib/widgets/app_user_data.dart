import 'package:book_builder/objects/obj_book_item.dart';
import 'package:book_builder/providers/provider_book_items.dart';
import 'package:book_builder/providers/provider_service.dart';
import 'package:book_builder/screens/to_do_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppUserData extends StatelessWidget {
  const AppUserData({
    super.key,
    required this.formKey,
    required this.titelController,
    required this.serviceController,
    required this.descriptionController,
    required this.index,
    required this.isHeader,
    required this.headerIndex,
    required this.listItem,
    this.isLocked = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titelController;
  final ProviderService serviceController;
  final TextEditingController descriptionController;
  final int index;
  final bool isHeader;
  final int headerIndex;
  final ObjBookItem listItem;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    TextEditingController dodController = TextEditingController();
    TextEditingController dodCounterController = TextEditingController();
    if (isHeader) {
      dodController.text = context
          .read<ProviderBookItems>()
          .getHeaderId(index)
          .bookDod
          .toString();
      dodCounterController.text = context
          .read<ProviderBookItems>()
          .getHeaderId(index)
          .bookCounter
          .toString();
    } else {
      //getBookId(id, getHeaderId(headerId))
      dodController.text = context
          .read<ProviderBookItems>()
          .getBookId(
            index,
            context.read<ProviderBookItems>().getHeaderId(headerIndex),
          )
          .bookDod
          .toString();
      dodCounterController.text = context
          .read<ProviderBookItems>()
          .getBookId(
            index,
            context.read<ProviderBookItems>().getHeaderId(headerIndex),
          )
          .bookCounter
          .toString();
    }

    return Form(
      key: formKey,
      child: Wrap(
        children: <Widget>[
          ListTile(
            leading: Text("Titel"),
            title: TextFormField(
              controller: titelController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bitte gib einen Titel ein';
                }
                return null;
              },
            ),
            trailing: IconButton(
              onPressed: isLocked
                  ? null
                  : () {
                      if (formKey.currentState!.validate()) {
                        isHeader
                            ? context.read<ProviderBookItems>().updateTitle(
                                index,
                                titelController.text.trim(),
                              )
                            : context.read<ProviderBookItems>().updateTitleItem(
                                headerIndex,
                                index,
                                titelController.text.trim(),
                              );
                        serviceController.saveToDoList(context);
                      }
                    },
              icon: Icon(Icons.check),
            ),
            onTap: () => {},
          ),
          ListTile(
            leading: Text(
              "Beschreibung",
            ),
            title: TextFormField(
              controller: descriptionController,
              maxLines: 4,
            ),
            trailing: IconButton(
              onPressed: isLocked
                  ? null
                  : () {
                      isHeader
                          ? context.read<ProviderBookItems>().updateDescription(
                              index,
                              descriptionController.text.trim(),
                            )
                          : context
                                .read<ProviderBookItems>()
                                .updateDescriptionItem(
                                  headerIndex,
                                  index,
                                  descriptionController.text.trim(),
                                );
                      serviceController.saveToDoList(context);
                    },
              icon: Icon(Icons.check),
            ),
            onTap: () => {},
          ),
          ListTile(
            leading: Text("Aktuelle Wörter"),
            title: isHeader
                ? Text(
                    "${context.read<ProviderBookItems>().getHeaderId(index).bookCounter}",
                  )
                : TextFormField(
                    controller: dodCounterController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Bitte giben Sie die aktuelle Anzahl von Wörtern ein';
                      }
                      return null;
                    },
                  ),
            trailing: IconButton(
              onPressed: isLocked
                  ? null
                  : () {
                      if (formKey.currentState!.validate()) {
                        isHeader
                            ? null
                            : context
                                  .read<ProviderBookItems>()
                                  .updateDodCounterItem(
                                    headerIndex,
                                    index,
                                    dodCounterController.text.trim(),
                                  );
                        serviceController.saveToDoList(context);
                      }
                    },
              icon: Icon(Icons.check),
            ),
            onTap: () => {},
          ),
          ListTile(
            leading: Text("Benötigte Wörter"),
            title: isHeader
                ? Text(
                    "${context.read<ProviderBookItems>().getHeaderId(index).bookDod}",
                  )
                : TextFormField(
                    controller: dodController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Bitte geben Sie die Wortzielzahl ein';
                      }
                      return null;
                    },
                  ),
            trailing: IconButton(
              onPressed: isLocked
                  ? null
                  : () {
                      if (formKey.currentState!.validate()) {
                        isHeader
                            ? null
                            : context.read<ProviderBookItems>().updateDodItem(
                                headerIndex,
                                index,
                                dodController.text.trim(),
                              );
                        serviceController.saveToDoList(context);
                      }
                    },
              icon: Icon(Icons.check),
            ),
            onTap: () => {},
          ),
          ListTile(
            leading: Text("Priorität"),
            title: DropdownMenu<Priority>(
              initialSelection: listItem.priority,
              dropdownMenuEntries: [
                for (var priorites in Priority.values)
                  DropdownMenuEntry(
                    label: priorites.name,
                    value: priorites,
                  ),
              ],
              onSelected: isLocked
                  ? null
                  : (item) {
                      if (item == null) return;
                      isHeader
                          ? context.read<ProviderBookItems>().updatePriority(
                              index,
                              item,
                            )
                          : context
                                .read<ProviderBookItems>()
                                .updatePriorityItem(
                                  headerIndex,
                                  index,
                                  item,
                                );
                      serviceController.saveToDoList(context);
                    },
            ),
          ),
          ListTile(
            leading: Text("Fällig am"),
            title: ToDoDatePicker(
              index: index,
              isHeader: isHeader,
              indexHeader: headerIndex,
            ),
          ),
        ],
      ),
    );
  }
}
