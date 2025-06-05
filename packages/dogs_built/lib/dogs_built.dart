library dogs_built;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:dogs_built/collections.dart';
import 'package:dogs_core/dogs_core.dart';

class GeneratedBuiltInteropConverter<T> extends DefaultStructureConverter<T> {
  GeneratedBuiltInteropConverter({required super.struct});

  @override
  OperationMode<T>? resolveOperationMode(DogEngine engine, Type opmodeType) {
    final compatibility = engine.getMeta<BuiltInteropCompatibility>();

    // We treat built_value structures like normal structures when enabled.
    if (compatibility.useStructureSerializers) {
      return super.resolveOperationMode(engine, opmodeType);
    }

    // We use the built_value serializers directly for serialization by default.
    if (opmodeType == NativeSerializerMode) {
      var mapper = compatibility.serializers;
      var serializer = mapper.serializerForType(T)! as Serializer<T>;
      return NativeSerializerMode.create<T>(
        serializer: (value, engine) {
          return mapper.serializeWith<T>(serializer, value);
        },
        deserializer: (value, engine) {
          return mapper.deserializeWith<T>(serializer, value)!;
        },
      );
    }
    return null;
  }

}

class DogBuiltRuntimeConverter extends DogConverter with OperationMapMixin {
  final Serializer serializer;
  final Serializers mapper;

  DogBuiltRuntimeConverter(this.serializer, this.mapper) : super(
      struct: DogStructure.synthetic(serializer.wireName),
      isAssociated: false
  );

  @override
  Map<Type, OperationMode Function()> get modes => {
    NativeSerializerMode: () => NativeSerializerMode.create(
      serializer: (value, engine) {
        return mapper.serializeWith(serializer, value);
      },
      deserializer: (value, engine) {
        return mapper.deserializeWith(serializer, value);
      },
    ),
  };
}

class BuiltInteropCompatibility {
  Serializers serializers;
  final bool useStructureSerializers;

  BuiltInteropCompatibility({
    required this.serializers,
    this.useStructureSerializers = false,
  });
}

// ignore: non_constant_identifier_names
DogPlugin BuiltInteropPlugin({
  required Serializers serializers,
  bool useStructureSerializers = false,
}) => (DogEngine engine) {
  if (engine.getMetaOrNull<BuiltInteropCompatibility>() != null) {
    throw ArgumentError("BuiltCompatibility is already set in the engine. "
        "You should not register BuiltInteropPlugin multiple times.");
  }

  serializers = (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();

  engine.registerTreeBaseFactory(TypeToken<BuiltList>(), BuiltCollectionFactories.builtList);
  engine.registerTreeBaseFactory(TypeToken<BuiltSet>(), BuiltCollectionFactories.builtSet);
  engine.registerTreeBaseFactory(TypeToken<BuiltMap>(), BuiltCollectionFactories.builtMap);
  engine.registerTreeBaseFactory(TypeToken<BuiltListMultimap>(), BuiltCollectionFactories.builtListMultimap);
  engine.registerTreeBaseFactory(TypeToken<BuiltSetMultimap>(), BuiltCollectionFactories.builtSetMultimap);

  engine.setMeta<BuiltInteropCompatibility>(BuiltInteropCompatibility(
    serializers: serializers,
    useStructureSerializers: useStructureSerializers,
  ));

  for (var serializer in serializers.serializers) {
    for (var type in serializer.types) {
      if (engine.findStructureByType(type) == null) {
        // TODO: Maybe not all built_value serializers should be registered. May lead to problems with built_collection tree types.
        DogBuiltRuntimeConverter converter = DogBuiltRuntimeConverter(serializer, serializers);
        engine.registerAssociatedConverter(converter, type: type);
        engine.registerStructure(converter.struct!, type: type);
        engine.registerShelvedConverter(converter);
      }
    }
  }
};