import 'package:darwin_marshal/darwin_marshal.dart';
import 'package:dogs/dogs.dart';
import 'package:dogs_darwin/dogs_darwin.dart';

void main() {
  var dogs = DogEngine(false);
  dogs.registerConverter(CatConverter());
  var marshal = DarwinMarshal();
  DogsMarshal.link(marshal, dogs);

  var serializationContext =
      SerializationContext(List<Cat>, "application/json", {}, marshal);
  var serializer = marshal.findSerializer(serializationContext)!;
  var serialized = serializer
      .serialize([Cat("CAT 1", 5), Cat("CAT 2", 5)], serializationContext);
  print(serialized);

  var deserializationContext =
      DeserializationContext("application/json", Set<Cat>, {}, marshal);
  var deserializer = marshal.findDeserializer(deserializationContext)!;
  var deserialized =
      deserializer.deserialize(serialized, deserializationContext);
  print(deserialized);
}

class Cat {
  String name;
  int age;

  Cat(this.name, this.age);

  @override
  String toString() {
    return 'Cat{name: $name, age: $age}';
  }
}

class CatConverter extends DogConverter<Cat> {
  @override
  Cat convertFromGraph(DogGraphValue value, DogEngine engine) {
    var map = value.asMap!.value;
    return Cat(map[DogString("name")]!.coerceNative(),
        map[DogString("age")]!.coerceNative());
  }

  @override
  DogGraphValue convertToGraph(Cat value, DogEngine engine) {
    return DogMap({
      DogString("name"): DogGraphValue.fromNative(value.name),
      DogString("age"): DogGraphValue.fromNative(value.age)
    });
  }
}
