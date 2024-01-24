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
import 'package:dogs_core/dogs_validation.dart';

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

abstract class CustomBase {

  // This should also be copied!
  @PropertyName("_id")
  final String id;

  const CustomBase({
    required this.id,
  });
}

abstract class SecondLevelBase extends CustomBase {

  @LengthRange(max: 100)
  final String name;

  const SecondLevelBase({
    required super.id,
    required this.name,
  });
}

@serializable
class CustomBaseImpl extends SecondLevelBase with Dataclass<CustomBaseImpl> {

  final String tag;

  CustomBaseImpl({
    required super.id,
    required super.name,
    required this.tag,
  });

  factory CustomBaseImpl.variant0() {
    return CustomBaseImpl(id: "id0", name: "Bert", tag: "tag");
  }

  factory CustomBaseImpl.variant1() {
    return CustomBaseImpl(id: "id1", name: "Helga", tag: "tag");
  }

}

@serializable
class InitializersModel with Dataclass<InitializersModel> {

  final String id;

  InitializersModel(String? id) : id = id ?? "default";

  factory InitializersModel.variant0() {
    return InitializersModel(null);
  }

  factory InitializersModel.variant1() {
    return InitializersModel("id1");
  }
}

@serializable
class ConstructorBodyModel with Dataclass<ConstructorBodyModel>{

  late String id;
  late String data;

  ConstructorBodyModel(String? id, String data) {
    this.id = id ?? "default";
    this.data = data;
  }

  factory ConstructorBodyModel.variant0() {
    return ConstructorBodyModel(null, "data0");
  }

  factory ConstructorBodyModel.variant1() {
    return ConstructorBodyModel("id1", "data1");
  }
}

@serializable
class GetterModel with Dataclass<GetterModel> {

  late String id;
  String? _buffer;

  GetterModel(String? id, String data)  {
    this.id = id ?? "default";
    _buffer = data;
  }

  @PropertyName(r"$data")
  String get data => "$_buffer";

  factory GetterModel.variant0() {
    return GetterModel(null, "data0");
  }

  factory GetterModel.variant1() {
    return GetterModel("id1", "data1");
  }
}