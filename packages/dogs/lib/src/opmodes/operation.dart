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

import 'dart:collection';
import 'dart:math';

import 'package:dogs_core/dogs_core.dart';

export 'modes/native.dart';
export 'modes/graph.dart';
export 'modes/validation.dart';

abstract interface class OperationMode<T> implements TypeCapture<T> {
  void initialise(DogEngine engine) {}
}

mixin OperationMapMixin<T> on DogConverter<T> {
  Map<Type, OperationMode<T> Function()> get modes;

  @override
  OperationMode<T>? resolveOperationMode(Type opmodeType) => modes[opmodeType]?.call();
}

class OperationModeRegistry {

  final Map<Type, OperationModeCacheEntry> _cache = HashMap();
  
  late OperationModeCacheEntry<NativeSerializerMode> nativeSerialization;
  late OperationModeCacheEntry<GraphSerializerMode> graphSerialization;
  late OperationModeCacheEntry<ValidationMode> validation;

  OperationModeRegistry() {
    nativeSerialization = entry<NativeSerializerMode>();
    graphSerialization = entry<GraphSerializerMode>();
    validation = entry<ValidationMode>();
  }

  OperationModeCacheEntry<T> entry<T extends OperationMode>() {
    OperationModeCacheEntry? cachedValue = _cache[T];
    if (cachedValue == null) {
      var entry = OperationModeCacheEntry<T>(T);
      _cache[T] = entry;
      return entry;
    } else {
      return cachedValue as OperationModeCacheEntry<T>;
    }
  }

  T getType<T extends OperationMode>(Type type, DogEngine engine) => entry<T>()
      .forType(type, engine);
  
  T getConverter<T extends OperationMode>(DogConverter converter, DogEngine engine) => entry<T>()
      .forConverter(converter, engine);
}

class OperationModeCacheEntry<T extends OperationMode> {
  final Type modeType;

  OperationModeCacheEntry(this.modeType);

  final Map<DogConverter, OperationMode> converterMapping = {};
  final Map<Type, OperationMode> typeMapping = {};

  T forConverter(DogConverter converter, DogEngine engine) {
    var cached = typeMapping[converter];
    if (cached != null) return cached as T;
    var resolved = converter.resolveOperationMode(modeType);
    if (resolved == null) throw Exception("DogConverter $converter doesn't support opmode $modeType");
    resolved.initialise(engine);
    converterMapping[converter] = resolved;
    return resolved as T;
  }

  T forType(Type type, DogEngine engine) {
    var cached = typeMapping[type];
    if (cached != null) return cached as T;
    var converter = engine.findAssociatedConverterOrThrow(type);
    var mode = forConverter(converter, engine);
    typeMapping[type] = mode;
    return mode;
  }

  T? forTypeNullable(Type type, DogEngine engine) {
    var cached = typeMapping[type];
    if (cached != null) return cached as T;
    var converter = engine.findAssociatedConverter(type);
    if (converter == null) return null;
    var mode = forConverter(converter, engine);
    typeMapping[type] = mode;
    return mode;
  }
}