// Openapi Generator last run: : 2024-02-01T14:48:50.967742
// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:dogs_built/dogs_built.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:logging/logging.dart';
import 'package:openapi/openapi.dart';

import 'dogs.g.dart';

Future main() async {
  configureDogs(plugins: [
    GeneratedModelsPlugin(),
    BuiltInteropPlugin(serializers: Openapi().serializers),
  ]);

  // Does the generated api actually kinda work?
  Pet pet = (PetBuilder()
    ..id = 1
    ..name = "Fido"
    ..status = PetStatusEnum.available).build();

  // Rebuilt using generated field maps
  var petStructure = dogs.findStructureByType(Pet);
  var encoded = dogs.toJson(pet);
  var rebuilt = dogs.fromJson<Pet>(encoded);

  print("OpenAPI test succeeded");
  exit(0);
}
