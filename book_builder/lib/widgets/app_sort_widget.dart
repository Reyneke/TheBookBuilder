import 'package:book_builder/objects/obj_book_item.dart';
import 'package:book_builder/providers/provider_book_items.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppSortWidget extends StatelessWidget {
  const AppSortWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ProviderBookItems todoManager = context.watch<ProviderBookItems>();
    return Row(
      spacing: 4,
      children: [
        Text("Sortierung:"),
        DropdownMenu(
          initialSelection: todoManager.sortingOption,
          dropdownMenuEntries: [
            for (var selection in ToDoSort.values)
              DropdownMenuEntry(
                label: selection.name,
                value: selection,
              ),
          ],
          onSelected: (value) {
            todoManager.switchSortingOption(value!);
          },
        ),
      ],
    );
  }
}
