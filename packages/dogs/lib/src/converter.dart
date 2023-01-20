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

abstract class DogConverter<T> with TypeCaptureMixin<T> {
  final bool isAssociated;
  DogConverter([this.isAssociated = true]);

  DogGraphValue convertToGraph(T value, DogEngine engine);
  T convertFromGraph(DogGraphValue value, DogEngine engine);
}

typedef FieldGetter = dynamic Function(dynamic);
typedef ConstructorAccessor = dynamic Function(List);

abstract class GeneratedDogConverter<T> extends DogConverter<T>
    with StructureEmitter, Copyable<T> {
  @override
  DogStructure get structure;
  List<FieldGetter> get getters;
  ConstructorAccessor get constructorAccessor;

  GeneratedDogConverter();

  @override
  T convertFromGraph(DogGraphValue value, DogEngine engine) {
    if (value is! DogMap) {
      throw Exception(
          "Expected a DogMap for structure ${structure.type} but go ${value.runtimeType}");
    }
    var map = value.value;
    var values = [];
    for (var field in structure.fields) {
      var fieldValue = map[DogString(field.name)] ?? DogNull();

      if (fieldValue is DogNull) {
        if (field.optional) {
          values.add(null);
          continue;
        }
        throw Exception(
            "Expected a value of serial type ${field.serialType} at ${field.name} but got ${fieldValue.coerceString()}");
      }
      if (field.converterType != null) {
        values.add(engine
            .findConverter(field.converterType!)!
            .convertFromGraph(fieldValue, engine));
      } else if (field.structure) {
        values.add(adjustIterable(
            engine.convertObjectFromGraph(fieldValue, field.serialType),
            field.iterableKind));
      } else {
        values
            .add(adjustIterable(fieldValue.coerceNative(), field.iterableKind));
      }
    }
    return constructorAccessor(values);
  }

  @override
  DogGraphValue convertToGraph(T value, DogEngine engine) {
    var map = <DogGraphValue, DogGraphValue>{};
    var values = getters.map((e) => e(value)).toList();
    for (var field in structure.fields) {
      var fieldValue = values.removeAt(0);

      if (field.converterType != null) {
        map[DogString(field.name)] = engine
            .findConverter(field.converterType!)!
            .convertToGraph(fieldValue, engine);
      } else if (field.structure) {
        map[DogString(field.name)] =
            engine.convertObjectToGraph(fieldValue, field.serialType);
      } else {
        map[DogString(field.name)] = DogGraphValue.fromNative(fieldValue);
      }
    }
    return DogMap(map);
  }

  int? indexOfFieldName(String name) {
    var fields = structure.fields;
    for (var i = 0; i < fields.length; i++) {
      if (fields[i].name == name) {
        return i;
      }
    }
    return null;
  }

  @override
  T copy(T src, DogEngine engine, Map<String, dynamic>? overrides) {
    if (overrides == null) {
      return constructorAccessor(getters.map((e) => e(src)).toList());
    } else {
      var map = overrides
          .map((key, value) => MapEntry(indexOfFieldName(key)!, value));
      var values = [];
      for (var i = 0; i < structure.fields.length; i++) {
        if (map.containsKey(i)) {
          values.add(map[i]);
        } else {
          values.add(getters[i](src));
        }
      }
      return constructorAccessor(values);
    }
  }
}

typedef EnumFromString<T> = T? Function(String);
typedef EnumToString<T> = String Function(T?);

abstract class GeneratedEnumDogConverter<T extends Enum>
    extends DogConverter<T> {
  EnumToString<T?> get toStr;
  EnumFromString<T?> get fromStr;

  @override
  T convertFromGraph(DogGraphValue value, DogEngine engine) {
    var s = (value as DogString).value;
    return fromStr(s)!;
  }

  @override
  DogGraphValue convertToGraph(T value, DogEngine engine) {
    var s = toStr(value);
    return DogString(s);
  }
}

dynamic adjustIterable<T>(dynamic value, IterableKind kind) {
  if (kind == IterableKind.list) return (value as Iterable).toList();
  if (kind == IterableKind.set) return (value as Iterable).toSet();
  return value;
}
