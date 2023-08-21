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

class ConvertableA {

  int a;
  int b;

  ConvertableA(this.a, this.b);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConvertableA &&
          runtimeType == other.runtimeType &&
          a == other.a &&
          b == other.b;

  @override
  int get hashCode => a.hashCode ^ b.hashCode;
}

@linkSerializer
class ConvertableAConverter extends DogConverter<ConvertableA> with OperationMapMixin<ConvertableA> {

  @override
  Map<Type, OperationMode<ConvertableA> Function()> get modes => {
    NativeSerializerMode: () => NativeSerializerMode.create(
        serializer: (value, engine) => [value.a, value.b],
        deserializer: (value, engine) => ConvertableA(value[0], value[1]),
    ),
    GraphSerializerMode: () => GraphSerializerMode.auto(this)
  };

  @override
  ConvertableA convertFromGraph(DogGraphValue value, DogEngine engine) {
    var list = value.asList!.value;
    return ConvertableA(list[0].asInt!, list[1].asInt!);
  }

  @override
  DogGraphValue convertToGraph(ConvertableA value, DogEngine engine) {
    return DogList([DogInt(value.a), DogInt(value.b)]);
  }

  ConvertableAConverter() : super(
    struct: DogStructure<ConvertableA>.synthetic("ConvertableA")
  );
}

@serializable
enum EnumA {
  a,b,c;
}