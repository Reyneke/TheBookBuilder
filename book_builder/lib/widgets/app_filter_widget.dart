import 'package:book_builder/objects/obj_todo.dart';
import 'package:book_builder/providers/provider_todo.dart';
import 'package:book_builder/widgets/to_do_priority_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppFilterWidget extends StatelessWidget {
  const AppFilterWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ProviderToDo todoManager = context.watch<ProviderToDo>();
    return Row(
      spacing: 4,
      children: [
        Text("Filter:"),
        Wrap(
          spacing: 4.0,
          children: ToDoFilter.values.map((ToDoFilter filter) {
            return FilterChip(
              label: Text(filter.name),
              selected: todoManager.filters.contains(filter),
              onSelected: (bool selected) {
                if (selected) {
                  todoManager.addFilter(filter);
                } else {
                  todoManager.removeFilter(filter);
                }
              },
            );
          }).toList(),
        ),
        Wrap(
          spacing: 4.0,
          children: Priority.values.map((Priority filter) {
            return FilterChip(
              label: ToDoPriorityIndicator(
                priority: filter,
              ), //Text(filter.name),
              selected: todoManager.priofilter.contains(filter),
              onSelected: (bool selected) {
                if (selected) {
                  todoManager.addPrioFilter(filter);
                } else {
                  todoManager.removePrioFilter(filter);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
