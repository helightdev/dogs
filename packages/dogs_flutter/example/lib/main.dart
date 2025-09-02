import 'package:dogs_core/dogs_schema.dart';
import 'package:dogs_flutter/databinding/material/list.dart';
import 'package:dogs_flutter/dogs_flutter.dart';
import 'package:example/dogs.g.dart';
import 'package:flutter/material.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDogs(plugins: [GeneratedModelsPlugin(), DogsFlutterPlugin()]);
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

  final mainSchema = object({
    "name": string(),
    "surname": string(),
    "age": integer(),
    "subschema": object({
      "subfield1": string(),
      "subfield2": integer(),
      "address": object({"street": string(), "city": string()}),
    }).serialName("SubSchema").formHelper("Helper").formLabel("My Label"),
    "list":
        array(integer())
            .formLabel("My List")
            .formHelper("Hello World!")
            .itemLabel("Item")
            .addButtonLabel("Add Item")
            .optional(),

    "complexList": object({
      "field1": string(),
      "field2": integer(),
    }).array().itemLabel("Complex Item"),

    "enum": enumeration(["option1", "option2", "option3"]),
  });

  late final controller = StructureBindingController.schema(
    schema: mainSchema,
    initialValue: {
      "name": "Alex",
      "surname": "Boe",
      "age": 99,
      "subschema": {
        "subfield1": "initial",
        "subfield2": 123,
        "address": {"street": "123 Other St", "city": "New York"},
      },
      "list": [],
      "complexList": [
        {"field1": "value1", "field2": 1},
      ],
      "enum": "option1",
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(
            // border: OutlineInputBorder(),
          ),
        ),
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
                        "subschema": {
                          "subfield1": "value1",
                          "subfield2": 42,
                          "address": {
                            "street": "123 Main St",
                            "city": "Metropolis",
                          },
                        },
                        "enum": "option2",
                      });

                      setState(() {
                        // Update the state to trigger a rebuild
                      });
                    },
                    child: const Text("Load"),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      controller.reset();
                      setState(() {
                        // Update the state to trigger a rebuild
                      });
                    },
                    child: const Text("Reset"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
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
        FieldBinding(
          field: "array",
          //binder: ListFlutterBinder(StringFlutterBinder(), QualifiedTypeTree.terminal<String>())
        ),
      ],
    );
  }
}
