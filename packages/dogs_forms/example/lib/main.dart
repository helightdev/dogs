import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_forms/dogs_forms.dart';
import 'package:example/dogs.g.dart';
import 'package:example/models/address.dart';
import 'package:example/models/person.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_custom.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_browser.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  await initialiseDogs();
  Intl.defaultLocale = await findSystemLocale();
  Intl.defaultLocale = "de";
  await initializeDateFormatting(Intl.defaultLocale, null);

  dogs.registerModeFactory(defaultFormFactories);
  runApp(const MyApp());
}

final DogsFormRef<Person> formRef = DogsFormRef();

final lightInputDecorationTheme = InputDecorationTheme(
  border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12, width: 2)),
  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black26, width: 2)),
  disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12, width: 2)),
  errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent, width: 2)),
  focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent, width: 2)),
  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2)),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    DogsFormRef<Person> reference = DogsFormRef();
    DogsForm<Person>(
      reference: reference
    );
    return MaterialApp(
      title: 'Flutter Demo',
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        inputDecorationTheme: lightInputDecorationTheme
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: DogsForm<Person>(
              reference: formRef,
              preferenceResolver: (previous, preference) {
                if (preference.borderPreference == BorderPreference.normal) {
                  return previous.copyWith(border: OutlineInputBorder(), filled: false);
                }
              },
              translationResolver: const MultiMapTranslationResolver({
                "de": {
                  "happy": "Wie glücklich bist du?",
                  "number-minimum": "Muss größer als %min% sein (%minExclusive%)."
                },
                "en": {
                  "happy": "How happy you are?",
                }
              }),
              initialValue: Person(
                  name: "Christoph",
                  surname: "Feuerer",
                  age: 20,
                  birthday: DateTime(2003, 11, 11),
                  happiness: 0,
                  gender: Gender.male,
                  active: true,
                  choose: "A",
                  choose2: "B",
                  choose3: "C",
                  tags: ["Hello", "World"], address: Address("Marienplatz 8", "München", "80331"), ints: [1, 2, 3], doubles: [1.25, 2.5, 3.75]),
              attributes: {
                #choose: const StringSelectionDataProvider(["A", "B", "C"])
              }),
        ),
        floatingActionButton: ElevatedButton(
            onPressed: () {
              print(formRef.read());
            },
            child: const Text("Print")),
      ),
    );
  }
}
