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

part of "../trees.dart";

class _IterableTreeBaseConverterFactory<BASE> extends TreeBaseConverterFactory {
  final BASE Function<T>(Iterable<T> entries) wrap;
  final Iterable Function<T>(BASE value) unwrap;

  _IterableTreeBaseConverterFactory(this.wrap, this.unwrap);

  @override
  DogConverter getConverter(
      TypeTree tree, DogEngine engine, bool allowPolymorphic) {
    final argumentConverters = TreeBaseConverterFactory.argumentConverters(
        tree, engine, allowPolymorphic);
    if (argumentConverters.length > 1) {
      throw ArgumentError("Lists can only have one generic type argument");
    }
    return _IterableTreeBaseConverter<BASE>(
        this, argumentConverters.first, tree.arguments.first);
  }
}

class _IterableTreeBaseConverter<BASE> extends DogConverter
    with IterableTreeBaseConverterMixin {
  _IterableTreeBaseConverterFactory<BASE> factory;

  @override
  DogConverter converter;

  @override
  TypeTree itemSubtree;

  _IterableTreeBaseConverter(this.factory, this.converter, this.itemSubtree)
      : super(keepIterables: true);

  @override
  iterableCreator<T>(Iterable entries) {
    return factory.wrap<T>(entries.cast<T>());
  }

  @override
  Iterable iterableDestructor<T>(value) {
    return factory.unwrap<T>(value as BASE);
  }

  @override
  APISchemaObject get output =>
      APISchemaObject.array(ofSchema: converter.output)
        ..description = "$BASE of ${itemSubtree.qualified.typeArgument}";
}

/// The native operation implementation for [IterableTreeBaseConverterMixin].
class IterableTreeNativeOperation extends NativeSerializerMode<dynamic>
    with TypeCaptureMixin<dynamic> {
  /// The parent mixin.
  final IterableTreeBaseConverterMixin mixin;

  /// Creates a new native operation for the given [mixin].
  IterableTreeNativeOperation(this.mixin);

  /// The operation for the native serialization mode.
  late NativeSerializerMode operation;

  @override
  void initialise(DogEngine engine) {
    operation = engine.modeRegistry.nativeSerialization
        .forConverter(mixin.converter, engine);
  }

  @override
  deserialize(value, DogEngine engine) {
    if (value == null) return mixin.create([]);
    final entries =
        (value as Iterable).map((e) => operation.deserialize(e, engine));
    return mixin.create(entries);
  }

  @override
  serialize(value, DogEngine engine) {
    final entries =
        mixin.destruct(value).map((e) => operation.serialize(e, engine));
    return entries.toList();
  }

  @override
  bool get canSerializeNull => true;
}

/// A mixin for [DogConverter]s that handle iterable types.
mixin IterableTreeBaseConverterMixin on DogConverter {
  /// The type tree of the items in the iterable.
  TypeTree get itemSubtree;

  /// The converter for the items in the iterable.
  DogConverter get converter;

  /// Creates a new value from the given [entries].
  /// Needs to be invoked by [create].
  dynamic iterableCreator<T>(Iterable entries);

  /// Destructs the given [value] into an iterable.
  /// Needs to be invoked by [destruct].
  Iterable iterableDestructor<T>(dynamic value);

  /// Creates a new value from the given [entries].
  dynamic create(Iterable entries) =>
      itemSubtree.qualified.consumeTypeArg(iterableCreator, entries);

  /// Destructs the given [value] into an iterable.
  Iterable destruct(dynamic value) =>
      itemSubtree.qualified.consumeTypeArg(iterableDestructor, value);

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
