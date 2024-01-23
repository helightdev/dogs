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

part of '../trees.dart';

class _NargsTreeBaseConverterFactory<BASE> extends TreeBaseConverterFactory {
  final int nargs;
  final Function captureFactory;

  _NargsTreeBaseConverterFactory(this.nargs, this.captureFactory);

  @override
  DogConverter getConverter(
      TypeTree tree, DogEngine engine, bool allowPolymorphic) {
    var argumentConverters = TreeBaseConverterFactory.argumentConverters(
        tree, engine, allowPolymorphic);
    if (tree.arguments.length != nargs) {
      throw ArgumentError("Expected $nargs type arguments");
    }
    var factory = switch (tree.arguments.length) {
      1 => tree.arguments.first.qualified
          .consumeType(captureFactory as Function<_>()),
      2 => TypeContainers.arg2(
          tree.arguments[0].qualified,
          tree.arguments[1].qualified,
        ).consume(captureFactory as Function<_0, _1>()),
      3 => TypeContainers.arg3(
          tree.arguments[0].qualified,
          tree.arguments[1].qualified,
          tree.arguments[2].qualified,
        ).consume(captureFactory as Function<_0, _1, _2>()),
      4 => TypeContainers.arg4(
          tree.arguments[0].qualified,
          tree.arguments[1].qualified,
          tree.arguments[2].qualified,
          tree.arguments[3].qualified,
        ).consume(captureFactory as Function<_0, _1, _2, _3>()),
      5 => TypeContainers.arg5(
          tree.arguments[0].qualified,
          tree.arguments[1].qualified,
          tree.arguments[2].qualified,
          tree.arguments[3].qualified,
          tree.arguments[4].qualified,
        ).consume(captureFactory as Function<_0, _1, _2, _3, _4>()),
      6 => TypeContainers.arg6(
          tree.arguments[0].qualified,
          tree.arguments[1].qualified,
          tree.arguments[2].qualified,
          tree.arguments[3].qualified,
          tree.arguments[4].qualified,
          tree.arguments[5].qualified,
        ).consume(captureFactory as Function<_0, _1, _2, _3, _4, _5>()),
      int() => throw Exception("Too many type arguments")
    };
    var castedFactory = factory as NTreeArgConverter<BASE>;
    var modeCacheEntry = engine.modeRegistry.nativeSerialization;
    castedFactory.tree = tree;
    castedFactory.itemConverters = argumentConverters;
    castedFactory.nativeModes = argumentConverters
        .map((e) => modeCacheEntry.forConverter(e, engine))
        .toList();
    return _NTreeArgConverterImpl<BASE>(castedFactory);
  }
}

class _NTreeArgConverterImpl<BASE> extends DogConverter<BASE>
    with OperationMapMixin<BASE> {
  NTreeArgConverter<BASE> delegate;

  _NTreeArgConverterImpl(this.delegate);

  @override
  Map<Type, OperationMode<BASE> Function()> get modes => {
        NativeSerializerMode: () => NativeSerializerMode.create<BASE>(
            serializer: delegate.serialize, deserializer: delegate.deserialize),
        GraphSerializerMode: () => GraphSerializerMode.auto<BASE>(this),
      };
}

abstract class NTreeArgConverter<BASE> {
  late TypeTree tree;
  late List<DogConverter> itemConverters;
  late List<NativeSerializerMode> nativeModes;

  dynamic deserializeArg(dynamic value, int index, DogEngine engine) {
    return nativeModes[index].deserialize(value, engine);
  }

  dynamic serializeArg(dynamic value, int index, DogEngine engine) {
    return nativeModes[index].serialize(value, engine);
  }

  BASE deserialize(dynamic value, DogEngine engine);
  dynamic serialize(BASE value, DogEngine engine);
}
