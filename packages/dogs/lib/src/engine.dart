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

import "dart:async";
import "dart:collection";

import "package:dogs_core/dogs_core.dart";
import "package:meta/meta.dart";

/// Registry and interface for [DogConverter]s, [DogStructure]s and [Copyable]s.
class DogEngine {
  static DogEngine? _instance;

  /// Checks if a valid instance of [DogEngine] is statically available.
  static bool get hasValidInstance => _instance != null;

  /// Returns the current statically linked [DogEngine].
  static DogEngine get instance => _instance!;

  /// Read-only list of [DogConverter]s.
  final List<DogConverter> _converters = [];
  final Map<Type, OperationModeFactory> _modeFactories = {};

  /// Read-only mapping of [DogConverter]s.
  final Map<Type, DogConverter> _associatedConverters = HashMap();

  /// Read-only mapping of [DogStructure]s.
  final Map<Type, DogStructure> _structures = HashMap();
  final Map<String, String> _annotationTranslations = {};
  final Map<Type, DogConverter> _runtimeTreeConverterCache = HashMap();

  final Map<Type, TreeBaseConverterFactory> _treeBaseFactories = {
    List: DefaultTreeBaseFactories.list,
    Iterable: DefaultTreeBaseFactories.iterable,
    Set: DefaultTreeBaseFactories.set,
    Map: DefaultTreeBaseFactories.map,
    Optional: DefaultTreeBaseFactories.optional
  };

  final List<DogEngine> _children = [];

  /// The [DogNativeCodec] used by this [DogEngine] instance.
  /// See [DogNativeCodec] for more details.
  final DogNativeCodec codec;

  /// The [OperationModeRegistry] used by this [DogEngine] instance.
  /// See [OperationModeRegistry] for more details.
  late OperationModeRegistry modeRegistry = OperationModeRegistry();

  late var _nativeSerialization = modeRegistry.nativeSerialization;
  late var _graphSerialization = modeRegistry.graphSerialization;
  late var _validation = modeRegistry.validation;
  DogEngine? _parent;

  /// Creates a new [DogEngine] instance.
  /// If [registerBaseConverters] is true, the following converters will be
  /// registered:
  /// - [PolymorphicConverter]
  /// - [DefaultMapConverter]
  /// - [DefaultIterableConverter]
  /// - [DefaultListConverter]
  /// - [DefaultSetConverter]
  /// - [DateTimeConverter]
  /// - [DurationConverter]
  /// - [UriConverter]
  /// - [Uint8ListConverter]
  ///
  /// If [codec] is not specified, [DefaultNativeCodec] will be used.
  DogEngine(
      {bool registerBaseConverters = true,
      this.codec = const DefaultNativeCodec()}) {
    if (registerBaseConverters) {
      // Register polymorphic converters
      registerAutomatic(PolymorphicConverter(), false);
      registerAutomatic(DefaultMapConverter(), false);
      registerAutomatic(DefaultIterableConverter(), false);
      registerAutomatic(DefaultListConverter(), false);
      registerAutomatic(DefaultSetConverter(), false);

      // Register common converters
      registerAutomatic(DateTimeConverter(), false);
      registerAutomatic(DurationConverter(), false);
      registerAutomatic(UriConverter(), false);
      registerAutomatic(Uint8ListConverter(), false);
      registerAutomatic(RegExpConverter(), false);

      // Register primitives
      // registerConverter(StringConverter(), false);
      // registerConverter(IntConverter(), false);
      // registerConverter(DoubleConverter(), false);
      // registerConverter(BoolConverter(), false);
    }
  }

  /// Sets this current instance as [_instance].
  void setSingleton() => _instance = this;

  /// Resets the [DogEngine]'s operation mode cache.
  /// All registered converters and structures will not be affected.
  void reset() {
    modeRegistry = OperationModeRegistry();
    _nativeSerialization = modeRegistry.nativeSerialization;
    _graphSerialization = modeRegistry.graphSerialization;
    _validation = modeRegistry.validation;
    _runtimeTreeConverterCache.clear();
  }

  /// Fully clears the [DogEngine] instance, effectively resetting it to its
  /// initial state.
  ///
  /// Warning: Do not invoke on the root [DogEngine] instance which has been
  /// automatically created by the dogs_generator.
  void clear({
    bool clearStructures = true,
  }) {
    _treeBaseFactories.clear();
    _converters.clear();
    _associatedConverters.clear();
    reset();
    if (clearStructures) _structures.clear();
    populateChange();
  }

  @internal
  /// Rebuilds this [DogEngine] instance from the supplied [engine].
  void rebuildFrom(DogEngine engine) {
    _parent = engine;
    reset();
    populateChange();
  }

  /// Creates a new [DogEngine] instance that is a child of this instance.
  /// The [DogNativeCodec] will be inherited from this instance but can be
  /// overridden by supplying a [codec].
  DogEngine fork({DogNativeCodec? codec}) {
    final DogEngine forked =
        DogEngine(registerBaseConverters: false, codec: codec ?? this.codec);
    forked.rebuildFrom(this);
    return forked;
  }

  /// Populates an engine change to all children.
  /// This will cause all children to rebuild their cache and emit a change
  /// events to their children.
  void populateChange() {
    reset(); // After a change we need to reset the cache
    for (var child in _children) {
      try {
        child.rebuildFrom(this); // Also rebuild children
      } on Exception catch (e) {
        print("Error while populating change to child: $e");
        _children.remove(child);
      }
    }
  }

  /// Closes this [DogEngine] instance and unregisters it from its parent.
  void close() {
    clear();
    _children.clear();
    _parent?._children.remove(this);
  }

  /// Returns all [DogStructure]s registered in this [DogEngine] instance and its
  /// parents.
  Map<Type, DogStructure> get allStructures => {
        if (_parent != null) ..._parent!.allStructures,
        ..._structures,
      };

  /// Returns all [DogConverter]s registered in this [DogEngine] instance and its
  /// parents.
  Map<Type, DogConverter> get allAssociatedConverters => {
        if (_parent != null) ..._parent!.allAssociatedConverters,
        ..._associatedConverters,
      };

  /// Returns all [OperationModeFactory]s registered in this [DogEngine] instance
  /// and its parents.
  Map<Type, TreeBaseConverterFactory> get allTreeBaseFactories => {
        if (_parent != null) ..._parent!.allTreeBaseFactories,
        ..._treeBaseFactories,
      };

  /// Returns all converters registered in this [DogEngine] instance and its
  /// parents.
  List<DogConverter> get allConverters => List.of([
        if (_parent != null) ..._parent!.allConverters,
        ..._converters,
      ]);

  /// Returns the annotation override for the given [id] or null if not present.
  String? findAnnotationTranslation(String id) {
    return _annotationTranslations[id] ??
        _parent?.findAnnotationTranslation(id);
  }

  /// Returns the [DogStructure] associated with [type].
  DogStructure? findStructureByType(Type type) {
    final structure = _structures[type];
    return structure ?? _parent?.findStructureByType(type);
  }

  /// Returns the [DogStructure] that is associated with the serial name [name]
  /// or null if not present.
  DogStructure? findStructureBySerialName(String name) =>
      _structures.entries
          .firstWhereOrNullDogs((element) => element.value.serialName == name)
          ?.value ??
      _parent?.findStructureBySerialName(name);

  /// Returns the [DogStructure] that is associated with the serial name [name]
  DogConverter? findConverterBySerialName(String name) {
    final associatedStructureType = _structures.entries
        .firstWhereOrNullDogs((element) => element.value.serialName == name)
        ?.key;
    if (associatedStructureType == null) {
      return _parent?.findConverterBySerialName(name);
    }
    return findAssociatedConverter(associatedStructureType);
  }

  /// Returns the first registered [DogConverter] of the given [type].
  DogConverter? findConverter(Type type) =>
      _converters.firstWhereOrNullDogs((element) => element.runtimeType == type) ??
      _parent?.findConverter(type);

  /// Returns the [DogConverter] that is associated with [type] or
  /// null if not present.
  DogConverter? findAssociatedConverter(Type type) {
    return _associatedConverters[type] ??
        _parent?.findAssociatedConverter(type);
  }

  /// Returns the [OperationModeFactory] that is associated with [type] or
  /// null if not present.
  OperationModeFactory? findModeFactory(Type type) {
    return _modeFactories[type] ?? _parent?.findModeFactory(type);
  }

  /// Registers a [converter] in this [DogEngine] instance and emits a event to
  /// the change stream if [emitChangeToStream] is true.
  Future<void> registerAutomatic(DogConverter converter,
      [bool emitChangeToStream = true]) async {
    if (converter.isAssociated) {
      if (converter.struct != null) {
        _structures[converter.struct!.typeArgument] = converter.struct!;
      }
      _associatedConverters[converter.typeArgument] = converter;
    }
    _converters.add(converter);
    if (emitChangeToStream) populateChange();
  }

  /// Registers a [converter] in this [DogEngine] instance and emits a event to
  /// the change stream if [emitChangeToStream] is true. Shelved converters are
  /// converters that are not associated with a type, but can be used by querying
  /// the explicit type of the converter.
  void registerShelvedConverter(DogConverter converter,
      {bool emitChangeToStream = true}) {
    _converters.add(converter);
    if (emitChangeToStream) populateChange();
  }

  /// Registers a [converter] in this [DogEngine] instance and emits a event to
  /// the change stream if [emitChangeToStream] is true.
  void registerAssociatedConverter(DogConverter converter,
      {bool emitChangeToStream = true, Type? type}) {
    _associatedConverters[type ?? converter.typeArgument] = converter;
    if (!_converters.contains(converter)) _converters.add(converter);
    if (emitChangeToStream) populateChange();
  }

  /// Registers a [DogStructure] in this [DogEngine] instance and emits a event
  /// to the change stream if [emitChangeToStream] is true.
  void registerStructure(DogStructure structure,
      {bool emitChangeToStream = true, Type? type}) {
    _structures[type ?? structure.typeArgument] = structure;
    if (emitChangeToStream) populateChange();
  }

  /// Registers a [OperationModeFactory] in this [DogEngine] instance and emits
  /// a event to the change stream if [emitChangeToStream] is true.
  void registerModeFactory(OperationModeFactory factory,
      {bool emitChangeToStream = true, Type? type}) {
    _modeFactories[type ?? factory.typeArgument] = factory;
    if (emitChangeToStream) populateChange();
  }

  /// Registers multiple converters using [registerAutomatic].
  /// For more details see [DogEngine.registerAutomatic].
  void registerAllConverters(Iterable<DogConverter> converters) {
    for (var x in converters) {
      registerAutomatic(x, false);
    }
    populateChange();
  }

  /// Registers and associates a single [TreeBaseConverterFactory] with [Type].
  void registerTreeBaseFactory(Type type, TreeBaseConverterFactory factory) {
    _treeBaseFactories[type] = factory;
  }

  /// Registers multiple tree base factories using [registerTreeBaseFactory].
  void registerAllTreeBaseFactories(
      Iterable<MapEntry<Type, TreeBaseConverterFactory>> entries) {
    _treeBaseFactories.addAll(Map.fromEntries(entries));
  }

  /// Returns the [DogConverter] for the given [tree].
  /// If [allowPolymorphic] is true, the returned converter may contain
  /// polymorphic converters if any type tree terminals are not concrete.
  DogConverter getTreeConverter(TypeTree tree, [bool allowPolymorphic = true]) {
    final cachedConverter =
        _runtimeTreeConverterCache[tree.qualified.typeArgument];
    if (cachedConverter != null) return cachedConverter;
    final created = _getTreeConverterUncached(tree, allowPolymorphic);
    _runtimeTreeConverterCache[tree.qualified.typeArgument] = created;
    return created;
  }

  DogConverter<dynamic> _getTreeConverterUncached(TypeTree<dynamic> tree,
      [bool allowPolymorphic = true]) {
    if (tree.isTerminal) {
      final associated = findAssociatedConverter(tree.base.typeArgument);

      if (codec.isNative(tree.base.typeArgument)) {
        return codec.bridgeConverters[tree.base.typeArgument]!;
      }

      if (associated != null) return associated;
      if (allowPolymorphic) {
        return TreeBaseConverterFactory.polymorphicConverter;
      }
      throw DogException(
          "No type tree converter for tree ${tree.qualified} found. (Polymorphism disabled)");
    } else {
      // Use associated converter if present
      final associated = findAssociatedConverter(tree.qualified.typeArgument);
      if (associated != null) return associated;

      // Use factory
      final factory = _treeBaseFactories[tree.base.typeArgument];
      if (factory == null) {
        throw DogException("No type tree converter for ${tree.base} found");
      }
      return factory.getConverter(tree, this, allowPolymorphic);
    }
  }

  // --- Deprecated methods ---
  /// Returns the [DogStructure] that is associated with the serial name [name]
  /// or null if not present.
  ///
  /// Deprecated: Use findStructureBySerialName instead
  @Deprecated("Use findStructureBySerialName instead")
  DogStructure? findSerialName(String name) => findStructureBySerialName(name);

  /// Registers a [converter] in this [DogEngine] instance and emits a event to
  /// the change stream if [emitChangeToStream] is true.
  ///
  /// Deprecated: Use registerAutomatic instead
  @Deprecated("Use registerAutomatic instead")
  Future<void> registerConverter(DogConverter converter,
          [bool emitChangeToStream = true]) async =>
      registerAutomatic(converter, emitChangeToStream);

  /// Returns the [DogStructure] that is associated with the serial name [name]
  /// or throws an exception if not present.
  @Deprecated("Perform a null check instead")
  DogStructure findSerialNameOrThrow(String name) {
    final structure = findStructureBySerialName(name);
    if (structure == null) {
      throw ArgumentError.value(
          name, "name", "No structure for given serial name found");
    }
    return structure;
  }

  /// Returns the [DogConverter] that is associated with [type] or
  /// throws an exception if not present.
  @Deprecated("Perform a null check instead")
  DogConverter findAssociatedConverterOrThrow(Type type) {
    final converter = findAssociatedConverter(type);
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

  /// Validates the supplied [value] using the [ValidationMode] mapped to the
  /// [value]s runtime type or [type] if specified.
  bool validateObject(dynamic value, [Type? type]) {
    final queryType = type ?? value.runtimeType;
    final operation = _validation.forTypeNullable(queryType, this);
    if (operation == null) return true;
    return operation.validate(value, this);
  }

  /// Validates the supplied [value] using the [ValidationMode] mapped to the
  /// [value]s runtime type or [type] if specified. The resulting [AnnotationResult]
  /// contains all error messages that were generated during validation.
  AnnotationResult validateAnnotated(dynamic value, [Type? type]) {
    final queryType = type ?? value.runtimeType;
    final operation = _validation.forTypeNullable(queryType, this);
    if (operation == null) return AnnotationResult.empty();
    if (operation.validate(value, this)) return AnnotationResult.empty();
    final result = operation.annotate(value, this).translate(this);
    if (result.messages.isEmpty) {
      return AnnotationResult(messages: [
        AnnotationMessage(id: "no-message", message: "Validation failed")
      ]).translate(this);
    }
    return result;
  }

  /// Converts a [value] to its [DogGraphValue] representation using the
  /// converter associated with [serialType].
  DogGraphValue convertObjectToGraph(dynamic value, Type serialType) {
    return _graphSerialization.forType(serialType, this).serialize(value, this);
  }

  /// Converts a [value] to its [DogGraphValue] representation using the
  /// converter associated with [serialType].
  DogGraphValue convertIterableToGraph(
      dynamic value, Type serialType, IterableKind kind) {
    return _graphSerialization
        .forType(serialType, this)
        .serializeIterable(value, this, kind);
  }

  /// Converts [DogGraphValue] supplied via [value] to its normal representation
  /// by using the converter associated with [serialType].
  dynamic convertObjectFromGraph(DogGraphValue value, Type serialType) {
    return _graphSerialization
        .forType(serialType, this)
        .deserialize(value, this);
  }

  /// Converts [DogGraphValue] supplied via [value] to its normal representation
  /// by using the converter associated with [serialType].
  dynamic convertIterableFromGraph(
      DogGraphValue value, Type serialType, IterableKind kind) {
    return _graphSerialization
        .forType(serialType, this)
        .deserializeIterable(value, this, kind);
  }

  /// Converts a [value] to its native representation using the
  /// converter associated with [serialType].

  dynamic convertObjectToNative(dynamic value, Type serialType) {
    return _nativeSerialization
        .forType(serialType, this)
        .serialize(value, this);
  }

  /// Converts a [value] to its native representation using the
  /// converter associated with [serialType].
  dynamic convertObjectFromNative(dynamic value, Type serialType) {
    return _nativeSerialization
        .forType(serialType, this)
        .deserialize(value, this);
  }

  /// Converts the [value], which can be either a [Iterable] or instance of
  /// the type associated with [serialType], depending on the [IterableKind],
  /// to its native representation using the converter associated with
  /// [serialType].
  dynamic convertIterableToNative(
      dynamic value, Type serialType, IterableKind kind) {
    return _nativeSerialization
        .forType(serialType, this)
        .serializeIterable(value, this, kind);
  }

  /// Converts the [value], which can be either a [Iterable] or instance of
  /// the type associated with [serialType], depending on the [IterableKind],
  /// to its native representation using the converter associated with
  /// [serialType].
  ///
  /// If the value is a [Iterable] implementation, it will converted to the
  /// desired [IterableKind]. Trying to convert singular values to an [Iterable]
  /// will result in an exception.
  dynamic convertIterableFromNative(
      dynamic value, Type serialType, IterableKind kind) {
    return _nativeSerialization
        .forType(serialType, this)
        .deserializeIterable(value, this, kind);
  }
}

/// Converts a [value] to the given [IterableKind]. If the value is a [Iterable]
/// implementation, it will converted to the desired [IterableKind]. Trying to
/// convert singular values to a iterable will result in an exception.
dynamic adjustIterable<T>(dynamic value, IterableKind kind) {
  switch (kind) {
    case IterableKind.none:
      return value;
    case IterableKind.list:
      return (value as Iterable).toList();
    case IterableKind.set:
      return (value as Iterable).toSet();
  }
}

dynamic adjustWithCoercion(dynamic value, IterableKind kind, TypeCapture target,
    CodecPrimitiveCoercion coercion, String? fieldName) {
  if (kind == IterableKind.none) {
    if (target.isAssignable(value)) return value;
    return coercion.coerce(target, value, fieldName);
  }

  final iterable = (value as Iterable).map((e) {
    if (target.isAssignable(e)) return e;
    return coercion.coerce(target, e, fieldName);
  });

  switch (kind) {
    case IterableKind.none:
      throw Exception("Unreachable");
    case IterableKind.list:
      return iterable.toList();
    case IterableKind.set:
      return iterable.toSet();
  }
}

/// Common iterable kinds which are compatible with dogs.
enum IterableKind { list, set, none }
