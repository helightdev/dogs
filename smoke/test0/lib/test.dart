import 'dart:math';

import 'package:dogs_cbor/dogs_cbor.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_toml/dogs_toml.dart';
import 'package:dogs_yaml/dogs_yaml.dart';
import 'package:logging/logging.dart';
import 'package:smoke_test_0/dogs.g.dart';
import 'package:smoke_test_0/generics.dart';
import 'package:smoke_test_0/validation.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'dart:io';

import 'conformities.dart';
import 'models.dart';

part "parts/projection.dart";
part "parts/operations.dart";
part "parts/trees.dart";
part "parts/validators.dart";
part "parts/models.dart";
part "parts/conformities.dart";
part "parts/encodings.dart";

Future main() async {
  await initialiseDogs();
  group("Smoke Test", () {
    test("Models", testModels);
    test("Operations", testOperations);
    test("Conformity", testConformities);
    test("Validators", testValidators);
    test("Trees", testTrees);
    test("Projection", testProjection);

    group("Encodings", () {
      test("CBOR", testCbor);
      test("Yaml", testYaml);
      test("Toml", testToml);
    });
  });
}

Matcher deepEquals(dynamic expected) => DeepMatcher(expected);

class DeepMatcher extends Matcher {
  final dynamic expected;

  DeepMatcher(this.expected);

  @override
  Description describe(Description description) {
    return description.add("deep equals $expected");
  }

  @override
  bool matches(dynamic item, Map matchState) {
    return deepEquality.equals(item, expected);
  }
}