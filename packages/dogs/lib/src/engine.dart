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

import 'dart:async';
import 'dart:collection';

import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_core/src/opmodes/operation.dart';
import 'package:meta/meta.dart';

/// Registry and interface for [DogConverter]s, [DogStructure]s and [Copyable]s.
class DogEngine {
  static DogEngine? _instance;

  /// Checks if a valid instance of [DogEngine] is statically available.
  static bool get hasValidInstance => _instance != null;

  /// Returns the current statically linked [DogEngine].
  static DogEngine get instance => _instance!;

  /// Read-only list of [DogConverter]s.
  List<DogConverter> converters = [];

  /// Read-only mapping of [DogConverter]s.
  Map<Type, DogConverter> associatedConverters = HashMap();

  /// Read-only mapping of [DogStructure]s.
  Map<Type, DogStructure> structures = HashMap();

  /// Read-only mapping of [Copyable]s.
  Map<Type, Copyable> copyables = HashMap();

  Map<Type, DogConverter> runtimeTreeConverterCache = HashMap();
  
  Map<Type, TreeBaseConverterFactory> treeBaseFactories = {
    List: ListTreeBaseConverterFactory(),
    Iterable: ListTreeBaseConverterFactory(),
    Set: SetTreeBaseConverterFactory(),
    Map: MapTreeBaseConverterFactory()
  };

  final OperationModeRegistry modeRegistry = OperationModeRegistry();
  late final _nativeSerialization = modeRegistry.nativeSerialization;
  late final _graphSerialization = modeRegistry.graphSerialization;
  late final _validation = modeRegistry.validation;
  
  final StreamController<bool> _changeStreamController =
      StreamController.broadcast();

  Stream<bool> get changeStream => _changeStreamController.stream;

  StreamSubscription? _forkSubscription;

  final DogNativeCodec codec;

  /// Creates a new [DogEngine] with optional async capabilities which can
  /// be enabled via [enableAsync]. (Experimental)
  DogEngine(
      {bool registerBaseConverters = true,
      this.codec = const DefaultNativeCodec()}) {
    if (registerBaseConverters) {
      // Register polymorphic converters
      registerConverter(PolymorphicConverter(), false);
      registerConverter(DefaultMapConverter(), false);
      registerConverter(DefaultIterableConverter(), false);
      registerConverter(DefaultListConverter(), false);
      registerConverter(DefaultSetConverter(), false);

      // Register common converters
      registerConverter(DateTimeConverter(), false);
      registerConverter(DurationConverter(), false);
      registerConverter(UriConverter(), false);
      registerConverter(Uint8ListConverter(), false);

      // Register primitives
      registerConverter(StringConverter(), false);
      registerConverter(IntConverter(), false);
      registerConverter(DoubleConverter(), false);
      registerConverter(BoolConverter(), false);
    }
  }

  /// Sets this current instance as [_instance].
  void setSingleton() => _instance = this;

  void clear() {
    treeBaseFactories.clear();
    runtimeTreeConverterCache.clear();
    converters.clear();
    associatedConverters.clear();
    structures.clear();
    copyables.clear();
  }

  @internal
  void forkEngine(DogEngine engine) {
    clear();
    var forks = engine.converters.map((e) => e.fork(this));
    var treeFactories = engine.treeBaseFactories.entries;
    registerAllConverters(forks);
    registerAllTreeBaseFactories(treeFactories);
    _changeStreamController.add(true);
  }

  DogEngine fork({DogNativeCodec? codec}) {
    DogEngine forked =
        DogEngine(registerBaseConverters: false, codec: codec ?? this.codec);
    forked._forkSubscription = changeStream.listen((event) {
      forked.forkEngine(this);
    }, onDone: () {
      print("Closing dog engine because the parent has been closed.");
      forked.close();
    }, onError: (_) {
      print(
          "Closing dog engine because the parent event stream threw an error");
      forked.close();
    });
    forked.forkEngine(this);
    return forked;
  }

  void close() {
    _changeStreamController.close();
    _forkSubscription?.cancel();
    clear();
  }

  /// Returns the [DogStructure] associated with [type].
  DogStructure? findStructureByType(Type type) => structures[type];

  /// Returns the [DogStructure] that is associated with the serial name [name]
  /// or null if not present.
  DogStructure? findSerialName(String name) => structures.entries
      .firstWhereOrNull((element) => element.value.serialName == name)
      ?.value;

  /// Returns the [DogStructure] that is associated with the serial name [name]
  /// or throws an exception if not present.
  DogStructure findSerialNameOrThrow(String name) {
    var structure = findSerialName(name);
    if (structure == null) {
      throw ArgumentError.value(
          name, "name", "No structure for given serial name found");
    }
    return structure;
  }

  /// Returns the [DogConverter] that is associated with [type] or
  /// null if not present.
  DogConverter? findAssociatedConverter(Type type) {
    return associatedConverters[type];
  }

  /// Returns the first registered [DogConverter] of the given [type].
  DogConverter? findConverter(Type type) =>
      converters.firstWhereOrNull((element) => element.runtimeType == type);

  /// Returns the [DogConverter] that is associated with [type] or
  /// throws an exception if not present.
  DogConverter findAssociatedConverterOrThrow(Type type) {
    var converter = findAssociatedConverter(type);
    if (converter == null) {
      if (type == dynamic) {
        throw Exception("Tried to resolve the converter for 'dynamic'. "
            "Consider explicitly specifying a type to resolve.");
      } else {
        throw ArgumentError.value(
            type, "type", "No converter for given type found");
      }
    }
    return converter;
  }
  
  /// Registers a [converter] in this [DogEngine] instance and emits a event to
  /// the change stream if [emitChangeToStream] is true. If this converter also
  /// has the [StructureEmitter] mixin, the supplied structure will be linked.
  /// If this converter also has the [Copyable] mixin, it will also be linked.
  void registerConverter(DogConverter converter,
      [bool emitChangeToStream = true]) {
    if (converter.isAssociated) {
      if (converter.struct != null) {
        structures[converter.struct!.typeArgument] = converter.struct!;
      }
      if (converter is Copyable) {
        copyables[converter.typeArgument] = converter as Copyable;
      }
      associatedConverters[converter.typeArgument] = converter;
    }
    converters.add(converter);
    converter.registrationCallback(this);
    if (emitChangeToStream) _changeStreamController.add(true);
  }

  /// Registers multiple converters using [registerConverter].
  /// For more details see [DogEngine.registerConverter].
  void registerAllConverters(Iterable<DogConverter> converters) {
    for (var x in converters) {
      registerConverter(x, false);
    }
    _changeStreamController.add(true);
  }
  
  void registerAllTreeBaseFactories(Iterable<MapEntry<Type, TreeBaseConverterFactory>> entries) {
    treeBaseFactories.addAll(Map.fromEntries(entries));
  }

  DogConverter getTreeConverter(TypeTree tree) {
    var cachedConverter = runtimeTreeConverterCache[tree.qualified.typeArgument];
    if (cachedConverter != null) return cachedConverter;
    var created = _getTreeConverterUncached(tree);
    runtimeTreeConverterCache[tree.qualified.typeArgument] = created;
    return created;
  }
  DogConverter<dynamic> _getTreeConverterUncached(TypeTree<dynamic> tree) {
    if (tree.isTerminal) {
      var associated = findAssociatedConverter(tree.base.typeArgument);
      assert((){
        if (associated == null && kWarnPolymorphicTerminalNode) {
          print(
              "[WARN] Using polymorphic converter for terminal tree node ${tree.base.typeArgument}. "
                  "If this intended, you can ignore this message or deactivate it using kWarnPolymorphicTerminalNode."
          );
        }
        return true;
      }());
      return associated ?? TreeBaseConverterFactory.polymorphicConverter;
    } else {
      // Use associated converter if present
      var associated = findAssociatedConverter(tree.qualified.typeArgument);
      if (associated != null) return associated;

      // Use factory
      var factory = treeBaseFactories[tree.base.typeArgument];
      if (factory == null) throw ArgumentError("No type tree converter for ${tree.base} found");
      return factory.getConverter(tree, this);
    }
  }

  /// Creates a copy of the supplied [value] using the [Copyable] associated
  /// with [type] or the [runtimeType] of value. All given [overrides] will
  /// be applied on the resulting object.
  dynamic copyObject(dynamic value,
      [Map<String, dynamic>? overrides, Type? type]) {
    var queryType = type ?? value;
    var cloneable = copyables[queryType]!;
    return cloneable.copy(value, this, overrides);
  }

  /// Validates the supplied [value] using the [Validatable] mapped to the
  /// [value]s runtime type or [type] if specified.
  bool validateObject(dynamic value, [Type? type]) {
    var queryType = type ?? value.runtimeType;
    var validatable = associatedConverters[queryType]!;
    return validatable.validate(value, this);
  }

  /// Converts a [value] to its [DogGraphValue] representation using the
  /// converter associated with [serialType].
  DogGraphValue convertObjectToGraph(dynamic value, Type serialType) {
    var converter = associatedConverters[serialType];
    if (converter == null) {
      throw Exception("Couldn't find an converter for $serialType");
    }
    return converter.convertToGraph(value, this);
  }

  /// Converts a [value] to its [DogGraphValue] representation using the
  /// converter associated with [serialType].
  dynamic convertIterableToGraph(dynamic value, Type type, IterableKind kind) {
    if (kind == IterableKind.none) {
      return convertObjectToGraph(value, type);
    } else {
      if (value is! Iterable) throw Exception("Expected an iterable");
      return DogList(value.map((e) => convertObjectToGraph(e, type)).toList());
    }
  }

  /// Converts [DogGraphValue] supplied via [value] to its normal representation
  /// by using the converter associated with [serialType].
  dynamic convertObjectFromGraph(DogGraphValue value, Type serialType) {
    var converter = associatedConverters[serialType]!;
    return converter.convertFromGraph(value, this);
  }

  dynamic convertObjectFromNative(dynamic value, Type serialType) {
    var converter = associatedConverters[serialType]!;
    return converter.convertFromNative(value, this);
  }

  dynamic convertObjectToNative(dynamic value, Type serialType) {
    var converter = associatedConverters[serialType];
    if (converter == null) {
      throw Exception("Couldn't find an converter for $serialType");
    }
    return converter.convertToNative(value, this);
  }
  
  dynamic convertObjectFromNativeOperation(dynamic value, Type serialType) {
    var converter = _nativeSerialization.forType(serialType, this);
    return converter.deserialize(value, this);
  }

  dynamic convertObjectToNativeOperation(dynamic value, Type serialType) {
    var converter = _nativeSerialization.forType(serialType, this);
    return converter.serialize(value, this);
  }

  dynamic convertIterableToNative(
      dynamic value, Type serialType, IterableKind kind) {
    if (kind == IterableKind.none) {
      return convertObjectToNative(value, serialType);
    } else {
      var converter = associatedConverters[serialType];
      if (converter == null) {
        throw Exception("Couldn't find an converter for $serialType");
      }
      if (value is! Iterable) throw Exception("value is not iterable");
      return value.map((e) => converter.convertToNative(e, this)).toList();
    }
  }

  dynamic convertIterableFromNative(
      dynamic value, Type serialType, IterableKind kind) {
    if (kind == IterableKind.none) {
      return convertObjectFromNative(value, serialType);
    } else {
      var converter = associatedConverters[serialType];
      if (converter == null) {
        throw Exception("Couldn't find an converter for $serialType");
      }
      if (value is! Iterable) throw Exception("value is not iterable");
      return adjustIterable(
          value.map((e) => converter.convertFromNative(e, this)), kind);
    }
  }

  /// Converts [DogGraphValue] supplied via [value] to its normal representation
  /// by using the converter associated with [serialType].
  dynamic convertIterableFromGraph(
      DogGraphValue value, Type type, IterableKind kind) {
    if (kind == IterableKind.none) {
      return convertObjectFromGraph(value, type);
    } else {
      if (value is! DogList) throw Exception("Expected a list");
      var items = value.value.map((e) => convertObjectFromGraph(e, type));
      return adjustIterable(items, kind);
    }
  }
}

abstract class DogNativeCodec {
  const DogNativeCodec();

  bool isNative(Type serial);
  DogGraphValue fromNative(dynamic value);
}

class DefaultNativeCodec extends DogNativeCodec {
  const DefaultNativeCodec();

  @override
  DogGraphValue fromNative(value) {
    if (value == null) return DogNull();
    if (value is String) return DogString(value);
    if (value is int) return DogInt(value);
    if (value is double) return DogDouble(value);
    if (value is bool) return DogBool(value);
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
        serial == bool;
  }
}

/// Converts a [value] to the given [IterableKind]. If the value is a [Iterable]
/// implementation, it will converted to the desired [IterableKind]. Trying to
/// convert singular values to a iterable will result in an exception.
dynamic adjustIterable<T>(dynamic value, IterableKind kind) {
  switch(kind) {
    case IterableKind.none:
      return value;
    case IterableKind.list:
      return (value as Iterable).toList();
    case IterableKind.set:
      return (value as Iterable).toSet();
  }
}

/// Common iterable kinds which are compatible with dogs.
enum IterableKind { list, set, none }
