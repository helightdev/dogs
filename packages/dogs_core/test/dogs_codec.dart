// ignore_for_file: unused_import

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

import "dart:math";

import "package:dogs_core/dogs_core.dart";
import "package:test/expect.dart";
import "package:test/scaffolding.dart";

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
      return DogMap(value.map((key, value) => MapEntry(fromNative(key), fromNative(value))));
    }

    throw ArgumentError.value(value, null, "Can't coerce native value to dart object graph");
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
  test("Test Custom Codec", () {
    final structure = DogStructure(
        "Test",
        StructureConformity.basic,
        [
          DogStructureField.string("a", optional: true),
          DogStructureField.create<CustomNative>("b")
        ],
        [],
        MemoryDogStructureProxy());

    final engine = DogEngine();
    final converter = DogStructureConverterImpl(structure);
    final forked = engine.fork(codec: CustomCodec());
    final nativeOpmode = forked.modeRegistry.nativeSerialization.forConverter(converter, forked);
    final encoded = nativeOpmode.serialize(["Hello", CustomNative()], forked);
    final decoded = nativeOpmode.deserialize(encoded, forked);
    expect(decoded[0], isA<String?>());
    expect(decoded[1], isA<CustomNative>());
  });

  test("Primitive Coerce", () {
    final coercion = NumberPrimitiveCoercion();
    final e1 = QualifiedTypeTree.terminal<int>();
    final e2 = QualifiedTypeTree.terminal<double>();
    final e3 = QualifiedTypeTree.terminal<String>();
    expect(coercion.coerce(e1, 1.0, "a"), 1);
    expect(coercion.coerce(e2, 1, "a"), 1.0);
    expect(() {
      coercion.coerce(e3, 1, "a");
    }, throwsArgumentError);
  });

  test("Test Custom Codec Overrides", () {
    final structure = DogStructure(
        "Test",
        StructureConformity.basic,
        [
          DogStructureField.create<DateTime>("a"),
        ],
        [],
        MemoryDogStructureProxy());

    final engine = DogEngine();
    final converter = DogStructureConverterImpl(structure);
    final forked = engine.fork(codec: CustomCodec());
    forked.registerAssociatedConverter(DateTimeWrapperConverter());

    // Test forked
    final nativeOpmode = forked.modeRegistry.nativeSerialization.forConverter(converter, forked);
    final encoded = nativeOpmode.serialize([DateTime.now()], forked);
    expect(encoded["a"], isA<DateTimeWrapper>());
    final decoded = nativeOpmode.deserialize(encoded, forked);
    expect(decoded[0], isA<DateTime>());

    // Test original
    final nativeOpmode2 = engine.modeRegistry.nativeSerialization.forConverter(converter, engine);
    final encoded2 = nativeOpmode2.serialize([DateTime.now()], engine);
    expect(encoded2["a"], isA<String>());
    final decoded2 = nativeOpmode2.deserialize(encoded2, engine);
    expect(decoded2[0], isA<DateTime>());
  });
}
