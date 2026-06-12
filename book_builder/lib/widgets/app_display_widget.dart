import 'package:book_builder/providers/provider_service.dart';
import 'package:book_builder/widgets/time/app_timewidget.dart';
import 'package:flutter/material.dart';
import 'package:postgrest/src/types.dart';
import 'package:provider/provider.dart';

class AppDisplayWidget extends StatefulWidget {
  const AppDisplayWidget({
    super.key,
  });

  @override
  State<AppDisplayWidget> createState() => _AppDisplayWidgetState();
}

class _AppDisplayWidgetState extends State<AppDisplayWidget> {
  TextEditingController newName = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    newName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      spacing: 8,
      children: [
        Consumer<ProviderService>(
          builder: (context, serviceManager, child) {
            return Switch(
              value: serviceManager.getUseOnlineDB,
              onChanged: (bool newStatus) {
                serviceManager.toggleOnlineOffline(newStatus, context);
              },
            );
          },
        ),

        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: ListTile(
            leading: IconButton(
              icon: Icon(Icons.edit_document),
              onPressed: () {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext ctx) => AlertDialog(
                    title: Text("Neues Buch?"),
                    content: Text(
                      "Wünschen Sie ein neues Buch anzulegen oder ein neues Buch zu laden?",
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          changeBookTitle(ctx, context, false);
                        },
                        child: Text("Neu"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          changeBookTitle(ctx, context, true);
                        },
                        child: Text("Laden"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                        },
                        //style: ButtonStyle(backgroundColor: Colors.red,),
                        child: Text("Abbrechen"),
                      ),
                    ],
                  ),
                );
              },
            ),
            title: Text(
              "Bookmaker: ${context.watch<ProviderService>().currentBook}",
            ),
          ),
        ),
        AppTimeWidget(),
      ],
    );
  }

  Future<dynamic> changeBookTitle(
    BuildContext ctx,
    BuildContext context,
    bool isOldBook,
  ) async {
    PostgrestList? bookMap = await context
        .read<ProviderService>()
        .getBookTitles(context);
    Set<String> booktitles = {};
    String selection = "";

    if (bookMap != null) {
      for (var mapElement in bookMap) {
        booktitles.add(mapElement['titel']);
      }
    }

    return showModalBottomSheet(
      context: ctx,
      builder: (ctx) {
        return Container(
          child: Wrap(
            children: [
              isOldBook ? Text("Wählen Sie einen Titel") : Text("Neuer Name"),
              isOldBook
                  ? SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: booktitles.length,
                        itemBuilder: (context, index) {
                          String bookTitle = booktitles.elementAt(index);
                          return ListTile(
                            title: Text(bookTitle),
                            onTap: () {
                              setState(() {
                                selection = booktitles.elementAt(index);
                              });
                            },
                          );
                        },
                      ),
                    )
                  : TextFormField(
                      controller: newName,
                    ),
              IconButton(
                onPressed: () {
                  isOldBook
                      ? context.read<ProviderService>().setNewBookName(
                          selection,
                          context,
                        )
                      : context.read<ProviderService>().setNewBookName(
                          newName.text.trim(),
                          context,
                        );
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                icon: Icon(Icons.check),
              ),
            ],
          ),
        );
      },
    );
  }
}
