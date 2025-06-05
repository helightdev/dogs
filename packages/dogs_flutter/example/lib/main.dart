import 'package:dogs_core/dogs_schema.dart' as z;
import 'package:dogs_flutter/databinding/bindings/list.dart';
import 'package:dogs_flutter/databinding/style.dart';
import 'package:dogs_flutter/databinding/validation.dart';
import 'package:dogs_flutter/dogs_flutter.dart';
import 'package:example/dogs.g.dart';
import 'package:flutter/material.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDogs(plugins: [
    GeneratedModelsPlugin(),
    DogsFlutterPlugin()
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
  // final controller = StructureBindingController.create<Person>(
  //   // initialValue: Person(
  //   //   "John",
  //   //   "Doe",
  //   //   21,
  //   //   249.2,
  //   //   true,
  //   //   "ABC123",
  //   //   "myTag",
  //   //   "password",
  //   //   "password",
  //   // ),
  // );

  final mainSchema = dogs.materialize(
    z.object({
      "name": z.string(),
      "surname": z.string(),
      "age": z.integer(),
      "subschema":  z.object({
        "subfield1": z.string(),
        "subfield2": z.integer()
      }),
      "enum": z.enumeration([
        "option1",
        "option2",
        "option3",
      ])
    }),
  );

  late final controller = StructureBindingController.schema(
    schema: mainSchema.originalSchema,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Theme(
        data: Theme.of(
          context,
        ).copyWith(inputDecorationTheme: InputDecorationTheme()),
        child: Center(
          child: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StructureBinding<dynamic>(
                    controller: controller,
                    validationTrigger: ValidationTrigger.always,
                    //child: _buildForm(),
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
                  ElevatedButton(
                    onPressed: () {
                      controller.load({
                        "name": "John",
                        "surname": "Doe",
                        "age": 21,
                        "subschema": {"subfield1": "value1", "subfield2": 42},
                        "enum": "option2",
                      });

                      setState(() {
                        // Update the state to trigger a rebuild
                      });
                    },
                    child: const Text("Load"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column _buildForm() {
    return Column(
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
        FieldBinding(field: "age"),
        FieldBinding(
          field: "subschema",
          //binder: NestedStructureFlutterBinder(subSchema.structure),
        ),
        FieldBinding(field: "array",
            //binder: ListFlutterBinder(StringFlutterBinder(), QualifiedTypeTree.terminal<String>())
        ),
      ],
    );
  }
}
