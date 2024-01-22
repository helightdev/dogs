library dogs_built;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:dogs_built/collections.dart';
import 'package:dogs_core/dogs_core.dart';

class GeneratedBuiltInteropConverter<T> extends DefaultStructureConverter<T> {
  GeneratedBuiltInteropConverter({required super.struct});

  Map<Type, OperationMode<T> Function()> get modes => {
        NativeSerializerMode: () {
          var mapper = BuiltCompatibility.serializers!;
          var serializer = mapper.serializerForType(T)! as Serializer<T>;
          return NativeSerializerMode.create<T>(
            serializer: (value, engine) {
              return mapper.serializeWith<T>(serializer, value);
            },
            deserializer: (value, engine) {
              return mapper.deserializeWith<T>(serializer, value)!;
            },
          );
        },
        GraphSerializerMode: () => GraphSerializerMode.auto<T>(this)
      };

  @override
  OperationMode<T>? resolveOperationMode(Type opmodeType) {
    if (BuiltCompatibility.useStructureSerializers) {
      return super.resolveOperationMode(opmodeType);
    }
    return modes[opmodeType]?.call();
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
    GraphSerializerMode: () => GraphSerializerMode.auto(this)
  };
}

class BuiltCompatibility {
  static Serializers? serializers;
  static bool useStructureSerializers = false;
}

void installBuiltSerializers(Serializers serializers) {
  serializers = (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();

  dogs.registerTreeBaseFactory(BuiltList, builtListFactory);
  dogs.registerTreeBaseFactory(BuiltSet, builtSetFactory);

  for (var serializer in serializers.serializers) {
    for (var type in serializer.types) {
      if (dogs.findStructureByType(type) == null) {
        // TODO: Maybe not all built_value serializers should be registered. May lead to problems with built_collection tree types.
        DogBuiltRuntimeConverter converter = DogBuiltRuntimeConverter(serializer, serializers);
        dogs.registerAssociatedConverter(converter, type: type);
        dogs.registerStructure(converter.struct!, type: type);
        dogs.registerShelvedConverter(converter);
      }
    }
  }

  BuiltCompatibility.serializers = serializers;
}
