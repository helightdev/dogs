library dogs_built;

import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:dogs_core/dogs_core.dart';

class BuiltDogConverter extends DogConverter with OperationMapMixin {
  final Serializer serializer;
  final Serializers mapper;

  BuiltDogConverter(this.serializer, this.mapper) : super(
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

void installBuiltSerializers(Serializers serializers, [DogEngine? engine]) {
  var instance = engine ?? DogEngine.instance;
  serializers = (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
  for (var value in serializers.serializers) {
    var converter = BuiltDogConverter(value, serializers);
    for (var type in value.types) {
      instance.registerAssociatedConverter(converter, type: type);
      instance.registerStructure(converter.struct!, type: type);
    }
    instance.registerShelvedConverter(converter);
  }
}

