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

import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_core/dogs_validation.dart';

import 'models.dart';

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
  };

  ConvertableAConverter() : super(
    struct: DogStructure<ConvertableA>.synthetic("ConvertableA")
  );
}

@serializable
enum EnumA {
  a,b,c,longNameValue;
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

@serializable
class DefaultValueModel with Dataclass<DefaultValueModel> {

  @DefaultValue("default")
  String a;

  @DefaultValue(bSupplier)
  int b;

  @DefaultValue(cSupplier)
  ModelA c;

  DefaultValueModel({
    this.a = "default",
    required this.b,
    required this.c,
  });

  factory DefaultValueModel.variant0() {
    return DefaultValueModel(b: bSupplier(), c: cSupplier());
  }

  factory DefaultValueModel.variant1() {
    return DefaultValueModel(a: "custom", b: 1001, c: ModelA.variant1());
  }

  static int bSupplier() => 420;
  static ModelA cSupplier() => ModelA.variant0();

}

@Serializable(serialName: "MyCustomSerialName")
class CustomSerialName {
  String value;
  CustomSerialName(this.value);
}

@serializable
class FieldExclusionModel with Dataclass<FieldExclusionModel> {
  String? always;

  @excludeNull
  String? maybe;

  FieldExclusionModel({
    this.always,
    this.maybe,
  });

  factory FieldExclusionModel.variant0() {
    return FieldExclusionModel(
      always: "always",
      maybe: "maybe",
    );
  }

  factory FieldExclusionModel.variant1() {
    return FieldExclusionModel(
      always: null,
      maybe: null,
    );
  }
}

@serializable
@excludeNull
class ClassExclusionModel with Dataclass<ClassExclusionModel> {
  String? a;
  String? b;

  ClassExclusionModel({
    this.a,
    this.b,
  });

  factory ClassExclusionModel.variant0() {
    return ClassExclusionModel(
      a: "always",
      b: "maybe",
    );
  }

  factory ClassExclusionModel.variant1() {
    return ClassExclusionModel(
      a: null,
      b: null,
    );
  }
}

@serializable
enum EnumB {
  @EnumProperty(fallback: true)
  a,
  @PropertyName("second")
  b,
  @EnumProperty(name: "third")
  c;
}


@serializable
class CombinedEnumTestModel with Dataclass<CombinedEnumTestModel> {
  EnumA enumA;
  EnumB enumB;

  CombinedEnumTestModel({
    required this.enumA,
    required this.enumB,
  });

  factory CombinedEnumTestModel.variant0() {
    return CombinedEnumTestModel(enumA: EnumA.a, enumB: EnumB.a);
  }

  factory CombinedEnumTestModel.variant1() {
    return CombinedEnumTestModel(enumA: EnumA.c, enumB: EnumB.c);
  }
}

class CustomList<E> extends ListBase<E>{

  List<E> backing = [];

  CustomList();
  CustomList.from(this.backing);

  @override
  int get length => backing.length;

  @override
  set length(int newLength) {
    backing.length = newLength;
  }

  @override
  E operator [](int index) {
    return backing[index];
  }

  @override
  void operator []=(int index, E value) {
    backing[index] = value;
  }
}

@dogsLinked
final customListConverter = TreeBaseConverterFactory.createIterableFactory<CustomList>(
  wrap: <T>(entries) => CustomList<T>.from(entries.toList()),
  unwrap: <T>(list) => list
);