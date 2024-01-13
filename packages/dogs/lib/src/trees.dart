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
import 'package:meta/meta.dart';

abstract class TreeBaseConverterFactory {
  DogConverter getConverter(
      TypeTree tree, DogEngine engine, bool allowPolymorphic);

  @internal
  static final PolymorphicConverter polymorphicConverter =
      PolymorphicConverter();

  static DogConverter treeConverter(
      TypeTree tree, DogEngine engine, bool allowPolymorphic) {
    if (tree.isTerminal && tree.qualified.typeArgument == dynamic) {
      return polymorphicConverter;
    }
    return engine.getTreeConverter(tree, allowPolymorphic);
  }

  static List<DogConverter> argumentConverters(
      TypeTree tree, DogEngine engine, bool allowPolymorphic) {
    return tree.arguments.map((e) {
      return treeConverter(e, engine, allowPolymorphic);
    }).toList();
  }
}

class IterableTreeNativeOperation extends NativeSerializerMode<dynamic>
    with TypeCaptureMixin<dynamic> {
  IterableTreeBaseConverterMixin mixin;
  IterableTreeNativeOperation(this.mixin);

  late NativeSerializerMode operation;

  @override
  void initialise(DogEngine engine) {
    operation = engine.modeRegistry.nativeSerialization
        .forConverter(mixin.converter, engine);
  }

  @override
  deserialize(value, DogEngine engine) {
    var entries =
        (value as Iterable).map((e) => operation.deserialize(e, engine));
    return mixin.create(entries);
  }

  @override
  serialize(value, DogEngine engine) {
    var entries =
        mixin.destruct(value).map((e) => operation.serialize(e, engine));
    return entries.toList();
  }
}

mixin IterableTreeBaseConverterMixin on DogConverter {
  TypeTree get tree;
  DogConverter get converter;

  dynamic iterableCreator<T>(Iterable entries);
  Iterable iterableDestructor<T>(dynamic value);

  dynamic create(Iterable entries) =>
      tree.qualified.consumeTypeArg(iterableCreator, entries);
  Iterable destruct(dynamic value) =>
      tree.qualified.consumeTypeArg(iterableDestructor, value);

  @override
  OperationMode<dynamic>? resolveOperationMode(Type opmodeType) {
    if (opmodeType == NativeSerializerMode) {
      return IterableTreeNativeOperation(this);
    }
    if (opmodeType == GraphSerializerMode) {
      return GraphSerializerMode.auto(this);
    }
    return null;
  }
}

class ListTreeBaseConverterFactory extends TreeBaseConverterFactory {
  @override
  DogConverter getConverter(
      TypeTree tree, DogEngine engine, bool allowPolymorphic) {
    var argumentConverters = TreeBaseConverterFactory.argumentConverters(
        tree, engine, allowPolymorphic);
    if (argumentConverters.length > 1) {
      throw ArgumentError("Lists can only have one generic type argument");
    }
    return ListTreeBaseConverter(
        argumentConverters.first, tree.arguments.first);
  }
}

class SetTreeBaseConverterFactory extends TreeBaseConverterFactory {
  @override
  DogConverter getConverter(
      TypeTree tree, DogEngine engine, bool allowPolymorphic) {
    var argumentConverters = TreeBaseConverterFactory.argumentConverters(
        tree, engine, allowPolymorphic);
    if (argumentConverters.length > 1) {
      throw ArgumentError("Lists can only have one generic type argument");
    }
    return SetTreeBaseConverter(argumentConverters.first, tree.arguments.first);
  }
}

class IterableTreeBaseConverterFactory extends TreeBaseConverterFactory {
  @override
  DogConverter getConverter(
      TypeTree tree, DogEngine engine, bool allowPolymorphic) {
    var argumentConverters = TreeBaseConverterFactory.argumentConverters(
        tree, engine, allowPolymorphic);
    if (argumentConverters.length > 1) {
      throw ArgumentError("Lists can only have one generic type argument");
    }
    return ListTreeBaseConverter(
        argumentConverters.first, tree.arguments.first);
  }
}

class MapTreeBaseConverterFactory extends TreeBaseConverterFactory {
  @override
  DogConverter getConverter(
      TypeTree tree, DogEngine engine, bool allowPolymorphic) {
    var argumentConverters = TreeBaseConverterFactory.argumentConverters(
        tree, engine, allowPolymorphic);
    if (argumentConverters.length > 2 || argumentConverters.length < 2) {
      throw ArgumentError("Lists can only have two generic type arguments");
    }
    return MapTreeBaseConverter(
        argumentConverters[0], argumentConverters[1], tree);
  }
}

class ListTreeBaseConverter extends DogConverter
    with IterableTreeBaseConverterMixin {
  @override
  DogConverter converter;

  @override
  TypeTree tree;

  ListTreeBaseConverter(this.converter, this.tree) : super(keepIterables: true);

  @override
  iterableCreator<T>(Iterable<dynamic> entries) {
    return entries.toList().cast<T>();
  }

  @override
  Iterable iterableDestructor<T>(value) => value;

  @override
  String toString() {
    return 'ListTypeTreeConverter{converter: $converter, tree: $tree}';
  }
}

class SetTreeBaseConverter extends DogConverter
    with IterableTreeBaseConverterMixin {
  @override
  DogConverter converter;

  @override
  TypeTree tree;

  SetTreeBaseConverter(this.converter, this.tree) : super(keepIterables: true);

  @override
  iterableCreator<T>(Iterable<dynamic> entries) {
    return entries.toSet().cast<T>();
  }

  @override
  Iterable iterableDestructor<T>(value) => value;

  @override
  String toString() {
    return 'SetTypeTreeConverter{converter: $converter, tree: $tree}';
  }
}

class MapTreeBaseNativeOperation extends NativeSerializerMode<Map>
    with TypeCaptureMixin<Map> {
  MapTreeBaseConverter base;
  MapTreeBaseNativeOperation(this.base);

  late NativeSerializerMode opKey;
  late NativeSerializerMode opVal;
  late TypeContainer2 container;

  Map _mapBuffer = {};

  void castMapBuffer<K, V>() {
    _mapBuffer = _mapBuffer.cast<K, V>();
  }

  Map finalizeMap(Map map, TypeContainer2 container) {
    _mapBuffer = map;
    container.consume(castMapBuffer);
    return _mapBuffer;
  }

  @override
  void initialise(DogEngine engine) {
    opKey = engine.modeRegistry.nativeSerialization
        .forConverter(base.keyConverter, engine);
    opVal = engine.modeRegistry.nativeSerialization
        .forConverter(base.valueConverter, engine);
    container = TypeContainers.arg2(
        base.tree.arguments[0].qualified, base.tree.arguments[1].qualified);
  }

  @override
  Map deserialize(value, DogEngine engine) {
    var convertedItems = (value as Map).map((key, value) => MapEntry(
        opKey.deserialize(key, engine), opVal.deserialize(value, engine)));
    return finalizeMap(convertedItems, container);
  }

  @override
  serialize(Map value, DogEngine engine) {
    var convertedItems = value.map((key, value) =>
        MapEntry(opKey.serialize(key, engine), opVal.serialize(value, engine)));
    return convertedItems;
  }
}

class MapTreeBaseConverter extends DogConverter {
  DogConverter keyConverter;
  DogConverter valueConverter;
  TypeTree tree;

  MapTreeBaseConverter(this.keyConverter, this.valueConverter, this.tree);

  @override
  OperationMode<dynamic>? resolveOperationMode(Type opmodeType) {
    if (opmodeType == NativeSerializerMode) {
      return MapTreeBaseNativeOperation(this);
    }
    if (opmodeType == GraphSerializerMode) {
      return GraphSerializerMode.auto(this);
    }
    return null;
  }

  Map _mapBuffer = {};

  void castMapBuffer<K, V>() {
    _mapBuffer = _mapBuffer.cast<K, V>();
  }

  Map finalizeMap(Map map, TypeContainer2 container) {
    _mapBuffer = map;
    container.consume(castMapBuffer);
    return map;
  }

  @override
  String toString() {
    return 'MapTreeBaseNativeOperation{key: $keyConverter, value: $valueConverter, tree: $tree}';
  }
}
