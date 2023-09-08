import 'dart:convert';

import 'package:built_value/standard_json_plugin.dart';
import 'package:dogs_built/dogs_built.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:logging/logging.dart';
import 'dart:io';

import 'package:smoke_test_1/dogs.g.dart';
import 'package:smoke_test_1/serializers.dart';
import 'package:smoke_test_1/values.dart';

Future main() async {
  try {
    await initialiseDogs();
    installBuiltSerializers(serializers);

    testEncoderDecoder<SimpleValue>(SimpleValue((b) => b
      ..anInt = 0
      ..aString = "test"
    ));
    testEncoderDecoder<SimpleValue>(SimpleValue((b) => b
      ..anInt = 1
      ..aString = null
    ));
    testEncoderDecoder<CompoundValue>(CompoundValue((b) => b
      ..simpleValue.anInt = 1
      ..validatedValue.anInt = 2)
    );

    var encode = jsonEncode({
      'id': 3,
      'name': 'John Smith',
      'keyValues': {
        'visited': 1732,
        'active': true,
        'email': 'john.smith@example.com',
        'tags': [74, 123, 4001],
        'preferences': {
          'showMenu': true,
          'skipIntro': true,
          'colorScheme': 'light',
        }
      }
    });
    var account = dogs.jsonDecode<Account>(encode);
    testEncoderDecoder<Account>(account);

  } catch(ex,st) {
    print("$ex: $st");
    exit(1);
  }
}

void testEncoderDecoder<T>(T value) {
  var native = dogs.convertObjectToNative(value, T);
  var decoded = dogs.convertObjectFromNative(native, T);
  if (decoded != value) throw Exception("Does not match!");
}