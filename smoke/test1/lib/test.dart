import 'dart:convert';
import 'dart:io';

import 'package:dogs_built/dogs_built.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:smoke_test_1/dogs.g.dart';
import 'package:smoke_test_1/dogs_values.dart';
import 'package:smoke_test_1/serializers.dart';
import 'package:smoke_test_1/values.dart';

Future main() async {
  try {
    configureDogs(plugins: [
      GeneratedModelsPlugin(),
      BuiltInteropPlugin(serializers: serializers)
    ]);

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
    var account = dogs.fromJson<Account>(encode);
    testEncoderDecoder<Account>(account);

    testEncoderDecoder<MyDogsModel>(MyDogsModel.variant0());
    testEncoderDecoder<MultimapModel>(MultimapModel.variant0());
    testEncoderDecoder<PolymorphicBuiltModel>(PolymorphicBuiltModel.variant0());
  } catch(ex,st) {
    print("$ex: $st");
    exit(1);
  }
}

void testEncoderDecoder<T>(T value) {
  var native = dogs.convertObjectToNative(value, T);
  var decoded = dogs.convertObjectFromNative(native, T);
  if (decoded != value) throw Exception("Does not match!");

  var json = dogs.toJson<T>(value);
  var decodedJson = dogs.fromJson<T>(json);
  if (decodedJson != value) throw Exception("Json does not match!");
}
