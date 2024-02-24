import 'package:dogs_cbor/dogs_cbor.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_toml/dogs_toml.dart';
import 'package:dogs_yaml/dogs_yaml.dart';
import 'package:smoke_test_0/dogs.g.dart';
import 'package:smoke_test_0/validation.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'conformities.dart';
import 'models.dart';

part "parts/conformities.dart";
part "parts/encodings.dart";
part "parts/models.dart";
part "parts/operations.dart";
part "parts/projection.dart";
part "parts/trees.dart";
part "parts/validators.dart";

Future main() async {
  await initialiseDogs();
  group("Smoke Test", () {
    group("Models", testModels);
    test("Operations", testOperations);
    test("Conformity", testConformities);
    test("Validators", testValidators);
    test("Trees", testTrees);
    test("Projection", testProjection);

    group("Encodings", () {
      test("Json", () {
        testEncoding(dogs.fromJson, dogs.toJson);
      });
      test("Cbor", () {
        testEncoding(dogs.fromCborString, dogs.toCborString);
      });
      test("Yaml", () {
        testEncoding(dogs.fromYaml, dogs.toYaml);
      });
      test("Toml", () {
        testEncoding(dogs.fromToml, dogs.toToml);
      });
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