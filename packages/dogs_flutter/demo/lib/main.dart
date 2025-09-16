// ignore_for_file: unused_import

import 'dart:convert';

import 'package:demo/dogs.g.dart';
import 'package:demo/widgets/brightness_toggle.dart';
import 'package:demo/widgets/code_export_dialog.dart';
import 'package:dogs_core/dogs_schema.dart' as z;
import 'package:dogs_flutter/dogs_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:go_router/go_router.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

late HighlighterTheme highlighterThemeDark;
late HighlighterTheme highlighterThemLight;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Highlighter.initialize(["dart", "yaml", "json"]);
  highlighterThemeDark = await HighlighterTheme.loadDarkTheme();
  highlighterThemLight = await HighlighterTheme.loadLightTheme();
  configureDogs(plugins: [GeneratedModelsPlugin(), DogsFlutterPlugin()]);
  runApp(const DogsDemoApp());
}

ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.dark);

HighlighterTheme get highlighterTheme => themeMode.value == ThemeMode.dark
    ? highlighterThemeDark
    : highlighterThemLight;

final router = GoRouter(
  routes: [
    GoRoute(
      path: "/binder/string",
      builder: (context, state) {
        return BinderPreview(
          z.object({"stringField": z.string().formLabel("String Field")}),
          exampleValue: {"stringField": "Hello, World!"},
        );
      },
    ),

    GoRoute(
      path: "/binder/int",
      builder: (context, state) {
        return BinderPreview(
          z.object({"intField": z.integer().formLabel("Integer Field")}),
          exampleValue: {"intField": 42},
        );
      },
    ),

    GoRoute(
      path: "/binder/double",
      builder: (context, state) {
        return BinderPreview(
          z.object({"doubleField": z.number().formLabel("Double Field")}),
          exampleValue: {"doubleField": 3.141592654},
        );
      },
    ),

    GoRoute(
      path: "/binder/bool",
      builder: (context, state) {
        return BinderPreview(
          z.object({"boolField": z.boolean().formLabel("Bool Field")}),
          exampleValue: {"boolField": true},
        );
      },
    ),

    GoRoute(
      path: "/binder/enum",
      builder: (context, state) {
        return BinderPreview(
          z.object({
            "enumField": z.enumeration(["a", "b", "c"]).formLabel("Enum Field"),
          }),
          exampleValue: {"enumField": "b"},
        );
      },
    ),

    GoRoute(
      path: "/binder/nested",
      builder: (context, state) {
        return BinderPreview(
          z.object({
            "name": z.string().formLabel("Name"),
            "age": z.integer().formLabel("Age"),
            "isActive": z.boolean().formLabel("Is Active"),
            "address": z
                .object({
                  "street": z.string().formLabel("Street"),
                  "city": z.string().formLabel("City"),
                  "zipCode": z.string().formLabel("Zip Code"),
                })
                .formLabel("Address"),
          }),
          exampleValue: {
            "name": "John Doe",
            "age": 30,
            "isActive": true,
            "address": {
              "street": "123 Main St",
              "city": "Anytown",
              "zipCode": "12345",
            },
          },
        );
      },
    ),
  ],
);

class BinderPreview extends StatefulWidget {
  final SchemaType schema;
  final Map<String, dynamic>? initialValue;
  final Map<String, dynamic>? exampleValue;

  const BinderPreview(
    this.schema, {
    super.key,
    this.initialValue,
    this.exampleValue,
  });

  @override
  State<BinderPreview> createState() => _BinderPreviewState();
}

class _BinderPreviewState extends State<BinderPreview> {
  late final controller = StructureBindingController.schema(
    schema: widget.schema,
    initialValue: widget.initialValue,
  );

  bool isDark = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: StructureBinding(
                controller: controller,
                validationTrigger: ValidationTrigger.onInteraction,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FilledButton(
                    onPressed: () {
                      var value = controller.submit();
                      if (value == null) {
                        return;
                      }
                      final json = dogs
                          .materialize(widget.schema)
                          .toJson(value);
                      final prettyJson = JsonEncoder.withIndent(
                        "  ",
                      ).convert(jsonDecode(json));
                      showDialog(
                        context: context,
                        builder: (context) =>
                            CodeExportDialog(code: prettyJson),
                      );
                    },
                    child: Text("Submit"),
                  ),

                  FilledButton.tonal(
                    onPressed: () {
                      controller.reset();
                    },
                    child: Text("Reset"),
                  ),

                  if (widget.exampleValue != null)
                    FilledButton.tonal(
                      onPressed: () {
                        controller.load(widget.exampleValue);
                      },
                      child: Text("Example"),
                    ),
                  Spacer(),
                  BrightnessToggle(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DogsDemoApp extends StatelessWidget {
  const DogsDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeMode,
      builder: (context, value, child) => MaterialApp.router(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
        ),
        themeMode: value,
        routerConfig: router,
      ),
    );
  }
}

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
