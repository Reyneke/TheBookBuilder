import 'package:book_builder/providers/provider_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDisplayWidget extends StatelessWidget {
  const AppDisplayWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool getUseDB = false;
    return Row(
      spacing: 4,
      children: [
        Text("Bookmaker: "),
        Switch(
          value: getUseDB,
          onChanged: (bool newStatus) {
            context.watch<ProviderService>().toggleOnlineOffline(newStatus);
          },
        ),
      ],
    );
  }
}
