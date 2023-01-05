import 'dart:io';

import 'package:dogs/dogs.dart';
import 'package:example/dogs.g.dart';
import 'package:example/models.dart';

void main() {
  var person = Person("Christoph", 19, null, [Note("I love dart!", 0)],
      DateTime(2003, 11, 11), Gender.male);

  var encoded = dogs.jsonEncode<Person>(person);
  print(encoded);
  var decoded = dogs.jsonDecode<Person>(encoded);
  print(decoded);

  dogs.shutdown();
}
