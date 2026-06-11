import 'package:book_builder/objects/obj_book_item.dart';
import 'package:book_builder/providers/provider_book_items.dart';
import 'package:book_builder/providers/provider_service.dart';
import 'package:book_builder/providers/theme_notifier.dart';
import 'package:book_builder/screens/login_screen.dart';
import 'package:book_builder/screens/screen_todo.dart';
import 'package:book_builder/screens/user_setup_screen.dart';
import 'package:book_builder/theme/app_theme.dart';
import 'package:book_builder/widgets/app_display_widget.dart';
import 'package:book_builder/widgets/app_filter_widget.dart';
import 'package:book_builder/widgets/app_sort_widget.dart';
import 'package:book_builder/widgets/theme_switch_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeModeNotifier = context.watch<ThemeNotifier>();
    bool getShowLoadingScreen =
        ((context.read<ProviderService>().getUseOnlineDB) &&
            (context.read<ProviderService>().supabase.auth.currentSession ==
                null))
        ? true
        : false;
    bool getShowSetupScreen =
        ((!context.read<ProviderService>().getUseOnlineDB) ||
            (context.read<ProviderService>().isUserValidated))
        ? true
        : false;
    context.read<ProviderService>().loadToDoList(context);

    themeModeNotifier.setThemeModeNotifier(
      context.watch<ProviderService>().isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,
    );

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: context.read<ThemeNotifier>().themeModeNotifier,
      builder: (context, value, child) {
        return MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeModeNotifier.themeModeNotifier.value,
          title: "BookMaker",
          home: Scaffold(
            appBar: AppBar(
              title: AppDisplayWidget(),
              //ThemeSwitchWidget(),
            ),

            body: getShowLoadingScreen
                ? const LoginScreen()
                : getShowSetupScreen
                ? Consumer<ProviderBookItems>(
                    builder: (context, todoItems, child) {
                      return Column(
                        //mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              spacing: 16,
                              children: [
                                ThemeSwitchWidget(),
                                AppFilterWidget(),
                                AppSortWidget(),
                              ],
                            ),
                          ),
                          Flexible(flex: 4, child: ScreenTodo()),
                        ],
                      );
                    },
                  )
                : UserSetupScreen(),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (context
                        .read<ProviderService>()
                        .supabase
                        .auth
                        .currentSession ==
                    null) {
                  return;
                }

                final newItem2 = ObjBookHeader(
                  id: context.read<ProviderBookItems>().headerList.length,
                  description: "Leer",
                  title: "Leer",
                  isCompleted: false,
                  createdAt: DateTime.now(),
                  dueDate: DateTime.now(),
                  priority: Priority.low,
                  isHeader: true,
                  subTopics: [],
                  headerId: 0,
                  bookDod: 4500,
                  bookCounter: 0,
                );

                context.read<ProviderBookItems>().addHeader(newItem2);
              },
              child: Icon(Icons.add_alarm),
            ),
          ),
        );
      },
    );
  }
}

extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).snackBarTheme.backgroundColor,
      ),
    );
  }
}
