import 'package:book_builder/objects/obj_todo.dart';
import 'package:book_builder/providers/provider_service.dart';
import 'package:book_builder/providers/provider_todo.dart';
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
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titelController;
  final ProviderService serviceController;
  final TextEditingController descriptionController;
  final int index;

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<ProviderToDo>().updateTitle(
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
              onPressed: () {
                context.read<ProviderToDo>().updateDescription(
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
            leading: Text("Priorität"),
            title: DropdownMenu(
              initialSelection: Priority.low,
              dropdownMenuEntries: [
                for (var priorites in Priority.values)
                  DropdownMenuEntry(
                    label: priorites.name,
                    value: priorites,
                  ),
              ],
              onSelected: (item) {
                context.read<ProviderToDo>().updatePriority(
                  index,
                  (item!),
                );
                serviceController.saveToDoList(context);
              },
            ),
          ),
          ListTile(
            leading: Text("Fällig am"),
            title: /*DatePickerDialog(
                      firstDate: DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 4),
                      
                    ),*/ ToDoDatePicker(
              index: index,
            ),
          ),
        ],
      ),
    );
  }
}
