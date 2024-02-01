// Openapi Generator last run: : 2024-02-01T14:48:50.967742
import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:dogs_built/dogs_built.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:logging/logging.dart';
import 'dart:io';

import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@SerializableLibrary(include: ["package:petstore_api/src/model/.*"])
import 'package:petstore_api/petstore_api.dart';

import 'dogs.g.dart';

Future main() async {
  await initialiseDogs();
  installBuiltSerializers(PetstoreApi().serializers);

  // Does the generated api actually kinda work?
  Pet pet = (PetBuilder()
    ..id = 1
    ..name = "Fido"
    ..status = PetStatusEnum.available).build();

  // Rebuilt using generated field maps
  var petStructure = dogs.findStructureByType(Pet);
  var extractFields = petStructure!.getFieldMap(pet);
  var rebuilt = dogs.project<Pet>(extractFields);

}

@Openapi(
  additionalProperties:
  DioProperties(pubName: 'petstore_api'),
  inputSpec:
  RemoteSpec(path: 'https://petstore.swagger.io/v2/swagger.json'),
  generatorName: Generator.dio,
  runSourceGenOnOutput: true,
  outputDirectory: 'api/petstore_api',
)
class OpenApiGenerator {}