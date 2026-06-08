import 'package:book_builder/providers/provider_book_items.dart';
import 'package:book_builder/providers/provider_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ToDoDatePicker extends StatefulWidget {
  const ToDoDatePicker({
    super.key,
    required this.index,
    required this.isHeader,
    required this.indexHeader,
  });
  final int index;
  final bool isHeader;
  final int indexHeader;

  @override
  State<ToDoDatePicker> createState() => _ToDoDatePickerState();
}

class _ToDoDatePickerState extends State<ToDoDatePicker> {
  DateTime? selectedDate;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  String getParsedDateString(DateTime selectedDate, bool updateDueTime) {
    if (updateDueTime) {
      widget.isHeader
          ? context.read<ProviderBookItems>().headerList[widget.index].dueDate =
                selectedDate
          : context
                    .read<ProviderBookItems>()
                    .headerList[widget.indexHeader]
                    .subTopics[widget.index]
                    .dueDate =
                selectedDate;
      context.read<ProviderService>().saveToDoList(context);
    }

    return '${DateTime.parse(selectedDate.toString()).day}.${DateTime.parse(selectedDate.toString()).month}.${DateTime.parse(selectedDate.toString()).year}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Consumer<ProviderBookItems>(
          builder: (context, dateProvider, child) {
            return Text(
              selectedDate == null
                  ? widget.isHeader
                        ? getParsedDateString(
                            context
                                .read<ProviderBookItems>()
                                .headerList[widget.index]
                                .dueDate,
                            false,
                          )
                        : getParsedDateString(
                            context
                                .read<ProviderBookItems>()
                                .headerList[widget.indexHeader]
                                .subTopics[widget.index]
                                .dueDate,
                            false,
                          ) /*'Noch kein Datum ausgewählt'*/
                  : getParsedDateString(selectedDate!, true),
            );
          },
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _selectDate(context),
          child: Text('Select Date'),
        ),
      ],
    );
  }
}
