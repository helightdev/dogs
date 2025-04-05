import 'package:dogs_flutter/databinding/style.dart';
import 'package:dogs_flutter/databinding/validation.dart';
import 'package:dogs_flutter/databinding/validators/format.dart';
import 'package:dogs_flutter/dogs.g.dart';
import 'package:dogs_flutter/dogs_flutter.dart';
import 'package:example/dogs.g.dart';
import 'package:flutter/material.dart';

import 'models.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialiseDogs();
  configureDogsFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    InputDecoration d;

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const TestForm(),
    );
  }
}

class TestForm extends StatefulWidget {
  const TestForm({super.key});

  @override
  State<TestForm> createState() => _TestFormState();
}

class _TestFormState extends State<TestForm> {
  final controller = StructureBindingController.create<Person>(
    // initialValue: Person(
    //   "John",
    //   "Doe",
    //   21,
    //   249.2,
    //   true,
    //   "ABC123",
    //   "myTag",
    //   "password",
    //   "password",
    // ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Theme(
        data: Theme.of(
          context,
        ).copyWith(inputDecorationTheme: InputDecorationTheme()),
        child: StructureBinding<Person>(
          controller: controller,
          validationTrigger: ValidationTrigger.onSubmit,
          child: Column(
            spacing: 12,
            children: [
              FieldBinding(
                field: "name",
                validationTrigger: ValidationTrigger.always,
              ),
              FieldBinding(
                field: "surname",
                style: BindingStyle(helper: "This is a helper"),
              ),
              FieldBinding(
                field: "age",
                validationTrigger: ValidationTrigger.always,
                annotationTransformer:
                    (result) => result.replace(
                      FormatMessages.invalidNumberFormat.id,
                      message: "Write a proper number please",
                    ),
              ),
              FieldBinding(
                field: "balance",
                validationTrigger: ValidationTrigger.always,
              ),
              FieldBinding(
                field: "isActive",
                style: BindingStyle(
                  label: "Is this active?",
                  helper: "This is a helper",
                ),
              ),
              FieldBinding(
                field: "plate",
                styleBuilder: (style) => style.copy(label: "License plate"),
              ),
              //FieldBinding(field: "tag"),
              SizedBox(height: 32),
              FieldBinding(field: "password"),
              FieldBinding(field: "confirm"),
              FieldBindingBuilder(
                fieldName: "tag",
                builder: (context, controller) {
                  return ListenableBuilder(
                    listenable: controller,
                    builder: (context, _) {
                      return DropdownButton<String>(
                        items: [
                          DropdownMenuItem(
                            value: "option1",
                            child: Text("Option 1"),
                          ),
                          DropdownMenuItem(
                            value: "option2",
                            child: Text("Option 2"),
                          ),
                          DropdownMenuItem(
                            value: "option3",
                            child: Text("Option 3"),
                          ),
                        ],
                        onChanged: (value) {
                          controller.setValue(value);
                        },
                        value: controller.getValue(),
                      );
                    },
                  );
                },
              ),

              ElevatedButton(
                onPressed: () {
                  print(
                    "Button pressed: ${controller.read(false)}, ${controller.read(true)}",
                  );
                  setState(() {
                    // Update the state to trigger a rebuild
                  });
                },
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
