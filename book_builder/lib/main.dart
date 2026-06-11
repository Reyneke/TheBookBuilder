import 'dart:math';

import 'package:book_builder/main_app.dart';
import 'package:book_builder/providers/provider_book_items.dart';
import 'package:book_builder/providers/provider_service.dart';
import 'package:book_builder/providers/theme_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/env_files/supabase_key.dart';

void main() async {
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  await Supabase.initialize(
    url: url,
    publishableKey: publishableKey,
  );

  Random(DateTime.now().millisecondsSinceEpoch);

  runApp(
    MultiProvider(
      providers: [
        ListenableProvider(
          create: (_) => ProviderBookItems(),
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
