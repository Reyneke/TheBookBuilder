import 'package:book_builder/objects/obj_book_item.dart';
import 'package:book_builder/providers/provider_book_items.dart';
import 'package:book_builder/providers/provider_service.dart';
import 'package:book_builder/screens/to_do_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppUserData extends StatefulWidget {
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
  State<AppUserData> createState() => _AppUserDataState();
}

class _AppUserDataState extends State<AppUserData> {
  List<String> _users = [];
  bool _isLoadingUsers = true;
  String? _selectedUser;

  @override
  void initState() {
    super.initState();
    _selectedUser = widget.listItem.responsibleUser.isEmpty
        ? null
        : widget.listItem.responsibleUser;
    _loadUsers();
  }

  @override
  void didUpdateWidget(AppUserData oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listItem != widget.listItem) {
      _selectedUser = widget.listItem.responsibleUser.isEmpty
          ? null
          : widget.listItem.responsibleUser;
    }
  }

  Future<void> _loadUsers() async {
    if (!widget.serviceController.getUseOnlineDB) {
      setState(() {
        _isLoadingUsers = false;
      });
      return;
    }

    final users = await widget.serviceController.getAllUsers();
    if (mounted) {
      setState(() {
        _users = users;
        _isLoadingUsers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController dodController = TextEditingController();
    TextEditingController dodCounterController = TextEditingController();
    if (widget.isHeader) {
      dodController.text = context
          .read<ProviderBookItems>()
          .getHeaderId(widget.index)
          .bookDod
          .toString();
      dodCounterController.text = context
          .read<ProviderBookItems>()
          .getHeaderId(widget.index)
          .bookCounter
          .toString();
    } else {
      //getBookId(id, getHeaderId(headerId))
      dodController.text = context
          .read<ProviderBookItems>()
          .getBookId(
            widget.index,
            context.read<ProviderBookItems>().getHeaderId(widget.headerIndex),
          )
          .bookDod
          .toString();
      dodCounterController.text = context
          .read<ProviderBookItems>()
          .getBookId(
            widget.index,
            context.read<ProviderBookItems>().getHeaderId(widget.headerIndex),
          )
          .bookCounter
          .toString();
    }

    return Form(
      key: widget.formKey,
      child: Wrap(
        children: <Widget>[
          ListTile(
            leading: const Text("Titel"),
            title: TextFormField(
              controller: widget.titelController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bitte gib einen Titel ein';
                }
                return null;
              },
            ),
            trailing: IconButton(
              onPressed: widget.isLocked
                  ? null
                  : () {
                      if (widget.formKey.currentState!.validate()) {
                        widget.isHeader
                            ? context.read<ProviderBookItems>().updateTitle(
                                widget.index,
                                widget.titelController.text.trim(),
                              )
                            : context.read<ProviderBookItems>().updateTitleItem(
                                widget.headerIndex,
                                widget.index,
                                widget.titelController.text.trim(),
                              );
                        widget.serviceController.saveToDoList(context);
                      }
                    },
              icon: const Icon(Icons.check),
            ),
            onTap: () => {},
          ),
          ListTile(
            leading: const Text(
              "Beschreibung",
            ),
            title: TextFormField(
              controller: widget.descriptionController,
              maxLines: 4,
            ),
            trailing: IconButton(
              onPressed: widget.isLocked
                  ? null
                  : () {
                      widget.isHeader
                          ? context.read<ProviderBookItems>().updateDescription(
                              widget.index,
                              widget.descriptionController.text.trim(),
                            )
                          : context
                                .read<ProviderBookItems>()
                                .updateDescriptionItem(
                                  widget.headerIndex,
                                  widget.index,
                                  widget.descriptionController.text.trim(),
                                );
                      widget.serviceController.saveToDoList(context);
                    },
              icon: const Icon(Icons.check),
            ),
            onTap: () => {},
          ),
          ListTile(
            leading: const Text("Aktuelle Wörter"),
            title: widget.isHeader
                ? Text(
                    "${context.read<ProviderBookItems>().getHeaderId(widget.index).bookCounter}",
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
              onPressed: widget.isLocked
                  ? null
                  : () {
                      if (widget.formKey.currentState!.validate()) {
                        widget.isHeader
                            ? null
                            : context
                                  .read<ProviderBookItems>()
                                  .updateDodCounterItem(
                                    widget.headerIndex,
                                    widget.index,
                                    dodCounterController.text.trim(),
                                  );
                        widget.serviceController.saveToDoList(context);
                      }
                    },
              icon: const Icon(Icons.check),
            ),
            onTap: () => {},
          ),
          ListTile(
            leading: const Text("Benötigte Wörter"),
            title: widget.isHeader
                ? Text(
                    "${context.read<ProviderBookItems>().getHeaderId(widget.index).bookDod}",
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
              onPressed: widget.isLocked
                  ? null
                  : () {
                      if (widget.formKey.currentState!.validate()) {
                        widget.isHeader
                            ? null
                            : context.read<ProviderBookItems>().updateDodItem(
                                widget.headerIndex,
                                widget.index,
                                dodController.text.trim(),
                              );
                        widget.serviceController.saveToDoList(context);
                      }
                    },
              icon: const Icon(Icons.check),
            ),
            onTap: () => {},
          ),
          ListTile(
            leading: const Text("Priorität"),
            title: DropdownMenu<Priority>(
              initialSelection: widget.listItem.priority,
              dropdownMenuEntries: [
                for (var priorites in Priority.values)
                  DropdownMenuEntry(
                    label: priorites.name,
                    value: priorites,
                  ),
              ],
              onSelected: widget.isLocked
                  ? null
                  : (item) {
                      if (item == null) return;
                      widget.isHeader
                          ? context.read<ProviderBookItems>().updatePriority(
                              widget.index,
                              item,
                            )
                          : context
                                .read<ProviderBookItems>()
                                .updatePriorityItem(
                                  widget.headerIndex,
                                  widget.index,
                                  item,
                                );
                      widget.serviceController.saveToDoList(context);
                    },
            ),
          ),
          ListTile(
            leading: const Text("Fällig am"),
            title: ToDoDatePicker(
              index: widget.index,
              isHeader: widget.isHeader,
              indexHeader: widget.headerIndex,
            ),
          ),
          if (!widget.isHeader)
            ListTile(
              leading: const Text("Verantwortlicher"),
              title: _isLoadingUsers
                  ? const CircularProgressIndicator()
                  : DropdownButton<String>(
                      value: _selectedUser,
                      hint: const Text('Benutzer auswählen'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('Keiner'),
                        ),
                        for (final user in _users)
                          DropdownMenuItem<String>(
                            value: user,
                            child: Text(user),
                          ),
                      ],
                      onChanged: widget.isLocked
                          ? null
                          : (newUser) {
                              setState(() {
                                _selectedUser = newUser;
                              });
                              context
                                  .read<ProviderBookItems>()
                                  .updateResponsibleUser(
                                    widget.headerIndex,
                                    widget.index,
                                    newUser ?? '',
                                  );
                              widget.serviceController.saveToDoList(context);
                            },
                    ),
            ),
        ],
      ),
    );
  }
}
