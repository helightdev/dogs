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
import 'package:lyell/lyell.dart';

/// Polymorphic converter for simple polymorphic datastructures.
/// Currently only supports a maximum depth of 1.
class PolymorphicConverter extends DogConverter {
  PolymorphicConverter() : super(false);

  static final typePropertyKey = DogString("_type");
  static final valuePropertyKey = DogString("_value");
  bool serializeNativeValues = true;

  @override
  dynamic convertFromGraph(DogGraphValue value, DogEngine engine) {
    if (value is! DogMap && serializeNativeValues) {
      return value.coerceNative();
    }
    var map = value.asMap!;
    var typeValue = map.value[typePropertyKey]!.asString!;
    var structure = engine.findSerialName(typeValue)!;
    var converter = engine.associatedConverters[structure.typeArgument]!;
    if (map.value.length == 2 && map.value.containsKey(valuePropertyKey)) {
      var simpleValue = map.value[valuePropertyKey]!;
      return converter.convertFromGraph(simpleValue, engine);
    } else {
      var clone = map.clone().asMap!;
      clone.value.remove(typePropertyKey);
      return converter.convertFromGraph(clone, engine);
    }
  }

  @override
  DogGraphValue convertToGraph(dynamic value, DogEngine engine) {
    if (DogGraphValue.isNative(value) && serializeNativeValues) {
      return DogGraphValue.fromNative(value);
    }
    var type = value.runtimeType;
    var converter = engine.associatedConverters[type]!;
    var structure = engine.structures[type]!;
    var graphValue = converter.convertToGraph(value, engine);
    if (graphValue is DogMap) {
      var valueMap = graphValue.asMap!;
      valueMap.value[typePropertyKey] = DogString(structure.serialName);
      return valueMap;
    } else {
      return DogMap({
        typePropertyKey: DogString(structure.serialName),
        valuePropertyKey: graphValue
      });
    }
  }

  DogGraphValue iterableToGraph(Iterable iterable, DogEngine engine) {
    return DogList(iterable.map((e) => convertToGraph(e, engine)).toList());
  }

  Iterable iterableFromGraph(DogGraphValue value, DogEngine engine) {
    return value.asList!.value.map((e) => convertFromGraph(e, engine));
  }

  DogMap mapToGraph(Map map, DogEngine engine) {
    return DogMap(map.map((key, value) =>
        MapEntry(convertToGraph(key, engine), convertToGraph(value, engine))));
  }

  Map mapFromGraph(DogMap map, DogEngine engine) {
    return map.value.map((key, value) => MapEntry(
        convertFromGraph(key, engine), convertFromGraph(value, engine)));
  }

  @override
  APISchemaObject get output => APISchemaObject.object({
        "_type": APISchemaObject.string(),
      })
        ..title = "Any"
        ..description =
            "A polymorphic object discriminated using the _type field.";
}

class DefaultListConverter extends DogConverter<List> {
  PolymorphicConverter polymorphicConverter = PolymorphicConverter();

  final TypeCapture? cast;

  DefaultListConverter([this.cast]) : super(false, true);

  @override
  List convertFromGraph(DogGraphValue value, DogEngine engine) {
    var list = polymorphicConverter
        .iterableFromGraph(value.asList!, engine)
        .toList();
    if (cast != null) return cast!.castList(list);
    return list;
  }

  @override
  DogGraphValue convertToGraph(List value, DogEngine engine) {
    return polymorphicConverter.iterableToGraph(value, engine);
  }

  @override
  APISchemaObject get output =>
      APISchemaObject.array(ofSchema: polymorphicConverter.output)
        ..title = cast == null ? "Dynamic List" : "${cast!.typeArgument.toString()} List";
}

class DefaultSetConverter extends DogConverter<Set> {
  PolymorphicConverter polymorphicConverter = PolymorphicConverter();

  final TypeCapture? cast;

  DefaultSetConverter([this.cast]) : super(false, true);

  @override
  Set convertFromGraph(DogGraphValue value, DogEngine engine) {
    var set = polymorphicConverter
        .iterableFromGraph(value.asList!, engine)
        .toSet();
    if (cast != null) return cast!.castSet(set);
    return set;
  }

  @override
  DogGraphValue convertToGraph(Set value, DogEngine engine) {
    return polymorphicConverter.iterableToGraph(value, engine);
  }

  @override
  APISchemaObject get output =>
      APISchemaObject.array(ofSchema: polymorphicConverter.output)
        ..title = cast == null ? "Dynamic Set" : "${cast!.typeArgument.toString()} Set";
}

class DefaultIterableConverter extends DogConverter<Iterable> {
  PolymorphicConverter polymorphicConverter = PolymorphicConverter();

  final TypeCapture? cast;

  DefaultIterableConverter([this.cast]) : super(false, true);

  @override
  Iterable convertFromGraph(DogGraphValue value, DogEngine engine) {
    var iterable = polymorphicConverter.iterableFromGraph(value.asList!, engine);
    if (cast != null) return cast!.castIterable(iterable);
    return iterable;
  }

  @override
  DogGraphValue convertToGraph(Iterable value, DogEngine engine) {
    return polymorphicConverter.iterableToGraph(value, engine);
  }

  @override
  APISchemaObject get output =>
      APISchemaObject.array(ofSchema: polymorphicConverter.output)
        ..title = cast == null ? "Dynamic List" : "${cast!.typeArgument.toString()} List";
}

class DefaultMapConverter extends DogConverter<Map> {
  PolymorphicConverter polymorphicConverter = PolymorphicConverter();

  DefaultMapConverter() : super(false);

  @override
  Map convertFromGraph(DogGraphValue value, DogEngine engine) {
    return polymorphicConverter.mapFromGraph(value.asMap!, engine);
  }

  @override
  DogGraphValue convertToGraph(Map value, DogEngine engine) {
    return polymorphicConverter.mapToGraph(value, engine);
  }
}
