import 'package:book_builder/main_app.dart';
import 'package:book_builder/providers/provider_service.dart';
import 'package:book_builder/providers/provider_todo.dart';
import 'package:book_builder/providers/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ListenableProvider(
          create: (_) => ProviderToDo(),
        ),
        ListenableProvider(
          create: (_) => ProviderService(),
        ),
        ListenableProvider(
          create: (_) => ThemeNotifier(),
        ),
      ],
      child: MainApp(),
    ),
  );
}
