import 'package:book_builder/objects/obj_todo.dart';
import 'package:flutter/material.dart';

class ToDoPriorityIndicator extends StatelessWidget {
  final Priority priority;
  const ToDoPriorityIndicator({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      width: 30,
      child: priority == Priority.high
          ? ColoredBox(color: Colors.red)
          : priority == Priority.medium
          ? ColoredBox(color: Colors.yellow)
          : ColoredBox(color: Colors.green),
    );
  }
}
