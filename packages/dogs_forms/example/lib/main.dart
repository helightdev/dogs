import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_forms/dogs_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:forms_example/dogs.g.dart';
import 'package:forms_example/models/person.dart';
import 'package:forms_example/pages/address_page.dart';
import 'package:forms_example/pages/lists_page.dart';
import 'package:forms_example/pages/nested_page.dart';
import 'package:forms_example/pages/nullables_page.dart';
import 'package:forms_example/pages/person_page.dart';
import 'package:forms_example/pages/post_page.dart';
import 'package:forms_example/pages/structlist_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_browser.dart';

import 'form_print_wrapper.dart';

void main() async {
  await initialiseDogs();
  Intl.defaultLocale = await findSystemLocale();
  Intl.defaultLocale = "de";
  await initializeDateFormatting(Intl.defaultLocale, null);

  dogs.registerModeFactory(defaultFormFactories);
  runApp(const MyApp());
}

final DogsFormRef<Person> formRef = DogsFormRef();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dogs_forms Demo',
      locale: const Locale("de"),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('de'), // Spanish
      ],
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
      ),
      home: const ExampleContent(),
    );
  }
}

class ExampleContent extends StatefulWidget {
  const ExampleContent({super.key});

  @override
  State<ExampleContent> createState() => _ExampleContentState();
}

class _ExampleContentState extends State<ExampleContent> {

  int selectedIndex = 0;
  bool isDark = false;

  List<NavigationRailDestination> destinations = [
    NavigationRailDestination(
      icon: const Icon(Icons.person),
      label: Text("Person"),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.home),
      label: Text("Address"),
    ),
    NavigationRailDestination(
        icon: const Icon(Icons.post_add), label: Text("Post")),
    NavigationRailDestination(
        icon: const Icon(Icons.account_tree), label: Text("Nested")),
    NavigationRailDestination(
        icon: const Icon(Icons.format_list_bulleted_sharp),
        label: Text("Lists")),
    NavigationRailDestination(
        icon: const Icon(Icons.question_mark), label: Text("Nullables")),
    NavigationRailDestination(
        icon: const Icon(Icons.format_list_bulleted),
        label: Text("StructList")),
  ];
  List<Widget Function(BuildContext)> pages = [
    (ctx) => PersonPage(),
    (ctx) => AddressPage(),
    (ctx) => PostPage(),
    (ctx) => NestedPage(),
    (ctx) => ListsPage(),
    (ctx) => NullablesPage(),
        (ctx) => StructListPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDark ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        floatingActionButton: ButtonBar(
          children: [
            Checkbox(
                value: isDark,
                onChanged: (v) {
                  setState(() {
                    isDark = v??false;
                  });
                }),
            Text("Dark Mode"),
            Checkbox(
                value: presetExamples,
                onChanged: (v) {
                  setState(() {
                    presetExamples = v??false;
                  });
                }),
            Text("Initialize with Examples"),
          ],
        ),
        body: Row(
          children: [
            NavigationRail(
              destinations: destinations,
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
            ),
            Expanded(child: Builder(builder: pages[selectedIndex]))
          ],
        ),
      ),
    );
  }
}
