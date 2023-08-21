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

import 'package:conduit_open_api/v3.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:meta/meta.dart';

abstract class DogConverter<T> extends TypeCapture<T> {
  final bool isAssociated;
  final bool keepIterables;
  final DogStructure<T>? struct;

  DogConverter({
    this.struct,
    this.isAssociated = true,
    this.keepIterables = false
  });

  OperationMode<T>? resolveOperationMode(Type opmodeType) => null;

  /// Describes the converts output using openapi3 component specs.
  APISchemaObject get output => APISchemaObject.empty();

  /// Converts [T] to a [DogGraphValue].
  DogGraphValue convertToGraph(T value, DogEngine engine);

  /// Converts a [DogGraphValue] to [T].
  T convertFromGraph(DogGraphValue value, DogEngine engine);

  /// Aggressively converts [T] to a "primitive" dart type.
  dynamic convertToNative(T value, DogEngine engine) {
    return convertToGraph(value, engine).coerceNative();
  }

  /// Aggressively converts a "primitive" dart type to [T].
  T convertFromNative(dynamic value, DogEngine engine) {
    return convertFromGraph(engine.codec.fromNative(value), engine);
  }

  bool validate(T src, DogEngine engine) => true;

  void registrationCallback(DogEngine engine) {}

  DogConverter<T> fork(DogEngine forkEngine) => this;
}

class Serializable {
  const Serializable();
}

/// Marks a class or enum as serializable.
/// The dogs_generator will then generate a [DefaultStructureConverter] which
/// also implements [Copyable] and [Validatable]. The generator will also
/// generate an implementation of [Builder] for the given type with the suffix
/// 'Builder' appended to the original class name.
///  Annotated types must match following conditions:
/// 1. Have a primary constructor or a secondary constructor
/// named 'dog' with only positional parameters.
/// 2. All constructor parameters must be field references. (this.fieldName)
/// 3. All fields specified in the eligible constructor must be serializable
/// using a converter or must be of type String, int, double or boolean.
const serializable = Serializable();

@internal
class LinkSerializer {
  const LinkSerializer();
}

/// Manually marks a custom dog converter implementation for linking.
/// The dogs_generator will then include an instance of this converter.
const linkSerializer = LinkSerializer();

class _BeanIgnore {
  const _BeanIgnore();
}

const beanIgnore = _BeanIgnore();

/// Marks a property as polymorphic, meaning its values type can vary.
class _Polymorphic extends ConverterSupplyingVisitor {
  const _Polymorphic();

  @override
  DogConverter resolve(DogStructure<dynamic> structure, DogStructureField field,
      DogEngine engine) {
    if (field.serial.typeArgument == dynamic) {
      switch (field.iterableKind) {
        case IterableKind.list:
          return DefaultListConverter();
        case IterableKind.set:
          return DefaultSetConverter();
        case IterableKind.none:
          return PolymorphicConverter();
      }
    } else {
      switch (field.iterableKind) {
        case IterableKind.list:
          return DefaultListConverter(field.serial);
        case IterableKind.set:
          return DefaultSetConverter(field.serial);
        case IterableKind.none:
          return PolymorphicConverter();
      }
    }
  }
}

/// Marks a property as polymorphic, meaning its value's type can vary.
const polymorphic = _Polymorphic();

/// Overrides the name that will be used by the [GeneratedDogConverter] for this
/// specific property. By default, the field name will be used.
class PropertyName {
  final String name;
  const PropertyName(this.name);
}

/// Overrides the serializer that will be used by the [GeneratedDogConverter]
/// for this specific property. By default, the field will be serialized using
/// the convert associated with its type.
class PropertySerializer {
  final Type type;
  const PropertySerializer(this.type);
}

extension ConverterIterableExtension on DogConverter {
  DogGraphValue convertIterableToGraph(
      dynamic value, DogEngine engine, IterableKind kind) {
    if (kind == IterableKind.none) {
      return convertToGraph(value, engine);
    } else {
      if (value is! Iterable) throw Exception("Expected an iterable");
      return DogList(value.map((e) => convertToGraph(e, engine)).toList());
    }
  }

  dynamic convertIterableFromGraph(
      DogGraphValue value, DogEngine engine, IterableKind kind) {
    if (kind == IterableKind.none) {
      return convertFromGraph(value, engine);
    } else {
      if (value is! DogList) throw Exception("Expected a list");
      var items = value.value.map((e) => convertFromGraph(e, engine));
      return adjustIterable(items, kind);
    }
  }

  dynamic convertIterableToNative(
      dynamic value, DogEngine engine, IterableKind kind) {
    if (kind == IterableKind.none) {
      return convertToNative(value, engine);
    } else {
      if (value is! Iterable) throw Exception("value is not iterable");
      return value.map((e) => convertToNative(e, engine)).toList();
    }
  }

  dynamic convertIterableFromNative(
      dynamic value, DogEngine engine, IterableKind kind) {
    if (kind == IterableKind.none) {
      return convertFromNative(value, engine);
    } else {
      if (value is! Iterable) throw Exception("value is not iterable");
      return adjustIterable(
          value.map((e) => convertFromNative(e, engine)), kind);
    }
  }
}
