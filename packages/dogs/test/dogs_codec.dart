/*
 *    Copyright 2022, the DOGs authors
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

import 'package:dogs_core/dogs_core.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class CustomNative {}

class DateTimeWrapper {
  final DateTime dateTime;

  DateTimeWrapper(this.dateTime);
}

class DateTimeWrapperConverter extends DogConverter<DateTime> with OperationMapMixin<DateTime> {

  @override
  Map<Type, OperationMode<DateTime> Function()> get modes => {
    NativeSerializerMode: () => NativeSerializerMode.create(
        serializer: (value, engine) => DateTimeWrapper(value),
        deserializer: (value, engine) => value.dateTime,
    ),
    GraphSerializerMode: () => GraphSerializerMode.auto(this)
  };

}

class CustomCodec extends DogNativeCodec {
  @override
  DogGraphValue fromNative(value) {
    if (value == null) return DogNull();
    if (value is String) return DogString(value);
    if (value is int) return DogInt(value);
    if (value is double) return DogDouble(value);
    if (value is bool) return DogBool(value);
    if (value is CustomNative) return DogNative(value);
    if (value is DateTimeWrapper) return DogNative(value);
    if (value is Iterable) {
      return DogList(value.map((e) => fromNative(e)).toList());
    }
    if (value is Map) {
      return DogMap(value
          .map((key, value) => MapEntry(fromNative(key), fromNative(value))));
    }

    throw ArgumentError.value(
        value, null, "Can't coerce native value to dart object graph");
  }

  @override
  bool isNative(Type serial) {
    return serial == String ||
        serial == int ||
        serial == double ||
        serial == bool ||
        serial == CustomNative ||
        serial == DateTimeWrapper;
  }

  @override
  Map<Type, DogConverter> get bridgeConverters => const {
    String: NativeRetentionConverter<String>(),
    int: NativeRetentionConverter<int>(),
    double: NativeRetentionConverter<double>(),
    bool: NativeRetentionConverter<bool>(),
    CustomNative: NativeRetentionConverter<CustomNative>(),
    DateTimeWrapper: NativeRetentionConverter<DateTimeWrapper>()
  };
}

void main() {
  test('Test Custom Codec', () {
    var structure = DogStructure(
        "Test",
        StructureConformity.basic,
        [
          DogStructureField.string("a", optional: true),
          DogStructureField.create<CustomNative>("b")
        ],
        [],
        MemoryDogStructureProxy());

    var engine = DogEngine();
    var converter = DogStructureConverterImpl(structure);
    var forked = engine.fork(codec: CustomCodec());
    var nativeOpmode = forked.modeRegistry.nativeSerialization.forConverter(converter, forked);
    var encoded = nativeOpmode.serialize(["Hello", CustomNative()], forked);
    var decoded = nativeOpmode.deserialize(encoded, forked);
    expect(decoded[0], isA<String?>());
    expect(decoded[1], isA<CustomNative>());
  });

  test('Test Custom Codec Overrides', () {
    var structure = DogStructure(
        "Test",
        StructureConformity.basic,
        [
          DogStructureField.create<DateTime>("a"),
        ],
        [],
        MemoryDogStructureProxy());

    var engine = DogEngine();
    var converter = DogStructureConverterImpl(structure);
    var forked = engine.fork(codec: CustomCodec());
    forked.registerAssociatedConverter(DateTimeWrapperConverter());

    // Test forked
    var nativeOpmode = forked.modeRegistry.nativeSerialization.forConverter(converter, forked);
    var encoded = nativeOpmode.serialize([DateTime.now()], forked);
    expect(encoded["a"], isA<DateTimeWrapper>());
    var decoded = nativeOpmode.deserialize(encoded, forked);
    expect(decoded[0], isA<DateTime>());

    // Test original
    var nativeOpmode2 = engine.modeRegistry.nativeSerialization.forConverter(converter, engine);
    var encoded2 = nativeOpmode2.serialize([DateTime.now()], engine);
    expect(encoded2["a"], isA<String>());
    var decoded2 = nativeOpmode2.deserialize(encoded2, engine);
    expect(decoded2[0], isA<DateTime>());

  });
}