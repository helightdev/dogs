import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_firestore/dogs_firestore.dart';
import 'package:example/dogs.g.dart';
import 'package:example/models/person.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'models/town.dart';

void main() async {
  await initialiseDogs();
  installFirebaseInterop();

  await Firebase.initializeApp(options: FirebaseOptions(apiKey: "", appId: "test", messagingSenderId: "", projectId: "test"));
  FirebaseFirestore.instance.settings = Settings(
    host: 'localhost:8080',
    sslEnabled: false,
    persistenceEnabled: false,
  );


  var town = await FirestoreEntity.get<Town>("amberg",
      orCreate: () => Town("Amberg", "de")
  );
  town!;

  var person = Person("Christoph", 20, DateTime(11, 11, 2003), Timestamp.now(), GeoPoint(51.165691, 10.451526));
  await town.$store(person);
  print("Saved person with id ${person.id} at path ${person.selfCollection.path}");
  var subCollection = town.getSubCollection<Person>();
  var resolved = await subCollection.doc(person.id).get();
  print("Got person with id ${resolved.data()?.id} at path ${resolved.data()?.selfCollection.path}: ${resolved.data()}");

  var cursor = resolved.data();
  await town.$query<Person>(
    startAt: cursor,
    query: (query) => query
        .orderBy("timestamp", descending: true)
        .where("timestamp", isLessThanOrEqualTo: Timestamp.now()),
  ).then((value) => print("Got ${value.length} persons: $value"));
  await town.$find<Person>(
    query: (query) => query
        .orderBy("timestamp", descending: true)
        .where("timestamp", isLessThanOrEqualTo: Timestamp.now()),
  ).then((value) => print("Got person: $value"));
  await town.$get<Person>(person.id!)
      .then((value) => print("Got person: $value"));

  // This app doesn't do anything
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Look in the console'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
    );
  }
}
