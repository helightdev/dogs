import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_firestore/dogs_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_firestore/dogs.g.dart';

void main() async {
  if (kDebugMode) {
    print("Connecting to Firestore...");
  }
  await Firebase.initializeApp(options: const FirebaseOptions(apiKey: "", appId: "test", messagingSenderId: "", projectId: "test"));
  if (kDebugMode) {
    print("Connected to Firestore");
  }
  FirebaseFirestore.instance.settings = const Settings(
    host: 'localhost:8080',
    sslEnabled: false,
    persistenceEnabled: false,
  );

  configureDogs(
      plugins: [
        GeneratedModelsPlugin(),
        FirebaseDogsPlugin()
      ]
  );

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
