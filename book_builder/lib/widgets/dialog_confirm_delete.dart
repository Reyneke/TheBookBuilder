import 'package:flutter/material.dart';

class DialogConfirmDelete extends StatelessWidget {
  const DialogConfirmDelete({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Löschen bestätigen"),
      content: const Text(
        "Sind Sie sicher, dass sie diesen Eintrag löschen wollen?",
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () => Navigator.of(context).pop(true),
          icon: Icon(Icons.check_box), //const Text("DELETE")
          color: Colors.red,
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(false),
          icon: Icon(Icons.cancel), //const Text("CANCEL"),
          color: Colors.green,
        ),
      ],
    );
  }
}
