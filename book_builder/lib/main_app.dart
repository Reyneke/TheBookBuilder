import 'package:book_builder/objects/obj_todo.dart';
import 'package:book_builder/providers/provider_service.dart';
import 'package:book_builder/providers/provider_todo.dart';
import 'package:book_builder/providers/theme_notifier.dart';
import 'package:book_builder/screens/screen_todo.dart';
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
          title: "ToDo List",
          home: Scaffold(
            appBar: AppBar(
              title: AppDisplayWidget(),
              //ThemeSwitchWidget(),
            ),

            body: Consumer<ProviderToDo>(
              builder: (context, todoItems, child) {
                //TODO: check if we really need this anymore ...
                /*if (todoItems.todoList.isEmpty) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        spacing: 16,
                        children: [
                          ThemeSwitchWidget(),
                          AppFilterWidget(),
                          AppSortWidget(),
                        ],
                      ),

                      Center(
                        child: Text('Keine ToDos verteilt.'),
                      ),
                    ],
                  );
                }*/
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
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                final newItem = ObjTodo(
                  id: context.read<ProviderToDo>().todoList.length,
                  description: "Leer",
                  title: "Leer",
                  isCompleted: false,
                  createdAt: DateTime.now(),
                  dueDate: DateTime.now(),
                  priority: Priority.low,
                );

                final newItem2 = ObjHeader(
                  id: context.read<ProviderToDo>().headerList.length,
                  description: "Leer",
                  title: "Leer",
                  isCompleted: false,
                  createdAt: DateTime.now(),
                  dueDate: DateTime.now(),
                  priority: Priority.low,
                  subTopics: [],
                );

                context.read<ProviderToDo>().addItem(newItem);
                context.read<ProviderToDo>().addHeader(newItem2);
                //context.read<ProviderToDo>().addItemToHeader(0, newItem);
              },
              child: Icon(Icons.add_alarm),
            ),
          ),
        );
      },
    );
  }
}
