import 'dart:convert';

import 'package:dogs_core/dogs_core.dart';
import 'package:test/test.dart';

void main() {
  var dogs = DogEngine(false);
  test('dogs json serialization', () {
    var mapPayload = {
      "id": 0,
      "name": "Christoph",
      "developer": true,
    };
    expect(dogs.jsonEncode<Map>(mapPayload), jsonEncode(mapPayload));
  });
}
