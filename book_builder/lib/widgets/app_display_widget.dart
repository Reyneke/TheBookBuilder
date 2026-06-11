import 'package:book_builder/providers/provider_service.dart';
import 'package:book_builder/widgets/time/app_timewidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDisplayWidget extends StatefulWidget {
  const AppDisplayWidget({
    super.key,
  });

  @override
  State<AppDisplayWidget> createState() => _AppDisplayWidgetState();
}

class _AppDisplayWidgetState extends State<AppDisplayWidget> {
  @override
  Widget build(BuildContext context) {
    bool getUseDB = context.read<ProviderService>().getUseOnlineDB;
    return Row(
      spacing: 8,
      children: [
        Text("Bookmaker: ${context.watch<ProviderService>().currentBook}"),
        Switch(
          value: getUseDB,
          onChanged: (bool newStatus) {
            setState(() {
              getUseDB = newStatus;
            });
            context.read<ProviderService>().toggleOnlineOffline(newStatus);
          },
        ),
        AppTimeWidget(),
      ],
    );
  }
}
