import 'dart:core';
import 'package:dogs_core/dogs_core.dart' as gen;
import 'package:dogs_built/dogs_built.dart' as gen;
import 'package:built_collection/built_collection.dart' as gen;
import 'dart:core' as gen0;
import 'package:petstore_api/src/model/api_response.dart' as gen1;
import 'package:petstore_api/src/model/category.dart' as gen2;
import 'package:petstore_api/src/model/order.dart' as gen3;
import 'package:built_collection/src/list.dart' as gen4;
import 'package:petstore_api/src/model/tag.dart' as gen5;
import 'package:petstore_api/src/model/pet.dart' as gen6;
import 'package:petstore_api/src/model/user.dart' as gen7;
import 'package:lyell/lyell.dart' as gen;
import 'package:petstore_api/src/model/date.dart' as gen8;
import 'package:smoke_test_openapi/test.dart';

class ApiResponseConverter extends gen.GeneratedBuiltInteropConverter<gen1.ApiResponse> {
  ApiResponseConverter()
      : super(
            struct: const gen.DogStructure<gen1.ApiResponse>(
                'ApiResponse',
                gen.StructureConformity.basic,
                [
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.int>(), gen.TypeToken<gen0.int>(), null, gen.IterableKind.none, 'code', true, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), gen.TypeToken<gen0.String>(), null, gen.IterableKind.none, 'type', true, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), gen.TypeToken<gen0.String>(), null, gen.IterableKind.none, 'message', true, false, [])
                ],
                [],
                gen.ObjectFactoryStructureProxy<gen1.ApiResponse>(_activator, [_$code, _$type, _$message], _values)));

  static List<dynamic> _values(gen1.ApiResponse obj) => [obj.code, obj.type, obj.message];

  static dynamic _$code(gen1.ApiResponse obj) => obj.code;

  static dynamic _$type(gen1.ApiResponse obj) => obj.type;

  static dynamic _$message(gen1.ApiResponse obj) => obj.message;

  static gen1.ApiResponse _activator(List list) {
    return (gen1.ApiResponseBuilder()
          ..code = list[0]
          ..type = list[1]
          ..message = list[2])
        .build();
  }
}

class CategoryConverter extends gen.GeneratedBuiltInteropConverter<gen2.Category> {
  CategoryConverter()
      : super(
            struct: const gen.DogStructure<gen2.Category>(
                'Category',
                gen.StructureConformity.basic,
                [
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.int>(), gen.TypeToken<gen0.int>(), null, gen.IterableKind.none, 'id', true, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), gen.TypeToken<gen0.String>(), null, gen.IterableKind.none, 'name', true, false, [])
                ],
                [],
                gen.ObjectFactoryStructureProxy<gen2.Category>(_activator, [_$id, _$name], _values)));

  static List<dynamic> _values(gen2.Category obj) => [obj.id, obj.name];

  static dynamic _$id(gen2.Category obj) => obj.id;

  static dynamic _$name(gen2.Category obj) => obj.name;

  static gen2.Category _activator(List list) {
    return (gen2.CategoryBuilder()
          ..id = list[0]
          ..name = list[1])
        .build();
  }
}

class OrderConverter extends gen.GeneratedBuiltInteropConverter<gen3.Order> {
  OrderConverter()
      : super(
            struct: const gen.DogStructure<gen3.Order>(
                'Order',
                gen.StructureConformity.basic,
                [
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.int>(), gen.TypeToken<gen0.int>(), null, gen.IterableKind.none, 'id', true, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.int>(), gen.TypeToken<gen0.int>(), null, gen.IterableKind.none, 'petId', true, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.int>(), gen.TypeToken<gen0.int>(), null, gen.IterableKind.none, 'quantity', true, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.DateTime>(), gen.TypeToken<gen0.DateTime>(), null, gen.IterableKind.none, 'shipDate', true, true, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen3.OrderStatusEnum>(), gen.TypeToken<gen3.OrderStatusEnum>(), null, gen.IterableKind.none, 'status', true, true, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.bool>(), gen.TypeToken<gen0.bool>(), null, gen.IterableKind.none, 'complete', true, false, [])
                ],
                [],
                gen.ObjectFactoryStructureProxy<gen3.Order>(_activator, [_$id, _$petId, _$quantity, _$shipDate, _$status, _$complete], _values)));

  static List<dynamic> _values(gen3.Order obj) => [obj.id, obj.petId, obj.quantity, obj.shipDate, obj.status, obj.complete];

  static dynamic _$id(gen3.Order obj) => obj.id;

  static dynamic _$petId(gen3.Order obj) => obj.petId;

  static dynamic _$quantity(gen3.Order obj) => obj.quantity;

  static dynamic _$shipDate(gen3.Order obj) => obj.shipDate;

  static dynamic _$status(gen3.Order obj) => obj.status;

  static dynamic _$complete(gen3.Order obj) => obj.complete;

  static gen3.Order _activator(List list) {
    return (gen3.OrderBuilder()
          ..id = list[0]
          ..petId = list[1]
          ..quantity = list[2]
          ..shipDate = list[3]
          ..status = list[4]
          ..complete = list[5])
        .build();
  }
}

class PetConverter extends gen.GeneratedBuiltInteropConverter<gen6.Pet> {
  PetConverter()
      : super(
            struct: const gen.DogStructure<gen6.Pet>(
                'Pet',
                gen.StructureConformity.basic,
                [
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), gen.TypeToken<gen0.String>(), null, gen.IterableKind.none, 'name', false, false, []),
                  gen.DogStructureField(gen.QualifiedTypeTreeN<gen4.BuiltList<gen0.String>, gen4.BuiltList<dynamic>>([gen.QualifiedTerminal<gen0.String>()]), gen.TypeToken<gen0.String>(), null,
                      gen.IterableKind.none, 'photoUrls', false, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.int>(), gen.TypeToken<gen0.int>(), null, gen.IterableKind.none, 'id', true, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen2.Category>(), gen.TypeToken<gen2.Category>(), null, gen.IterableKind.none, 'category', true, true, []),
                  gen.DogStructureField(gen.QualifiedTypeTreeN<gen4.BuiltList<gen5.Tag>, gen4.BuiltList<dynamic>>([gen.QualifiedTerminal<gen5.Tag>()]), gen.TypeToken<gen5.Tag>(), null,
                      gen.IterableKind.none, 'tags', true, true, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen6.PetStatusEnum>(), gen.TypeToken<gen6.PetStatusEnum>(), null, gen.IterableKind.none, 'status', true, true, [])
                ],
                [],
                gen.ObjectFactoryStructureProxy<gen6.Pet>(_activator, [_$name, _$photoUrls, _$id, _$category, _$tags, _$status], _values)));

  static List<dynamic> _values(gen6.Pet obj) => [obj.name, obj.photoUrls, obj.id, obj.category, obj.tags, obj.status];

  static dynamic _$name(gen6.Pet obj) => obj.name;

  static dynamic _$photoUrls(gen6.Pet obj) => obj.photoUrls;

  static dynamic _$id(gen6.Pet obj) => obj.id;

  static dynamic _$category(gen6.Pet obj) => obj.category;

  static dynamic _$tags(gen6.Pet obj) => obj.tags;

  static dynamic _$status(gen6.Pet obj) => obj.status;

  static gen6.Pet _activator(List list) {
    return (gen6.PetBuilder()
          ..name = list[0]
          ..photoUrls = list[1] == null ? null : gen.ListBuilder<gen0.String>(list[1])
          ..id = list[2]
          ..category = list[3]
          ..tags = list[4] == null ? null : gen.ListBuilder<gen5.Tag>(list[4])
          ..status = list[5])
        .build();
  }
}

class TagConverter extends gen.GeneratedBuiltInteropConverter<gen5.Tag> {
  TagConverter()
      : super(
            struct: const gen.DogStructure<gen5.Tag>(
                'Tag',
                gen.StructureConformity.basic,
                [
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.int>(), gen.TypeToken<gen0.int>(), null, gen.IterableKind.none, 'id', true, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), gen.TypeToken<gen0.String>(), null, gen.IterableKind.none, 'name', true, false, [])
                ],
                [],
                gen.ObjectFactoryStructureProxy<gen5.Tag>(_activator, [_$id, _$name], _values)));

  static List<dynamic> _values(gen5.Tag obj) => [obj.id, obj.name];

  static dynamic _$id(gen5.Tag obj) => obj.id;

  static dynamic _$name(gen5.Tag obj) => obj.name;

  static gen5.Tag _activator(List list) {
    return (gen5.TagBuilder()
          ..id = list[0]
          ..name = list[1])
        .build();
  }
}

class UserConverter extends gen.GeneratedBuiltInteropConverter<gen7.User> {
  UserConverter()
      : super(
            struct: const gen.DogStructure<gen7.User>(
                'User',
                gen.StructureConformity.basic,
                [
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.int>(), gen.TypeToken<gen0.int>(), null, gen.IterableKind.none, 'id', true, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), gen.TypeToken<gen0.String>(), null, gen.IterableKind.none, 'username', true, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), gen.TypeToken<gen0.String>(), null, gen.IterableKind.none, 'firstName', true, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), gen.TypeToken<gen0.String>(), null, gen.IterableKind.none, 'lastName', true, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), gen.TypeToken<gen0.String>(), null, gen.IterableKind.none, 'email', true, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), gen.TypeToken<gen0.String>(), null, gen.IterableKind.none, 'password', true, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), gen.TypeToken<gen0.String>(), null, gen.IterableKind.none, 'phone', true, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.int>(), gen.TypeToken<gen0.int>(), null, gen.IterableKind.none, 'userStatus', true, false, [])
                ],
                [],
                gen.ObjectFactoryStructureProxy<gen7.User>(_activator, [_$id, _$username, _$firstName, _$lastName, _$email, _$password, _$phone, _$userStatus], _values)));

  static List<dynamic> _values(gen7.User obj) => [obj.id, obj.username, obj.firstName, obj.lastName, obj.email, obj.password, obj.phone, obj.userStatus];

  static dynamic _$id(gen7.User obj) => obj.id;

  static dynamic _$username(gen7.User obj) => obj.username;

  static dynamic _$firstName(gen7.User obj) => obj.firstName;

  static dynamic _$lastName(gen7.User obj) => obj.lastName;

  static dynamic _$email(gen7.User obj) => obj.email;

  static dynamic _$password(gen7.User obj) => obj.password;

  static dynamic _$phone(gen7.User obj) => obj.phone;

  static dynamic _$userStatus(gen7.User obj) => obj.userStatus;

  static gen7.User _activator(List list) {
    return (gen7.UserBuilder()
          ..id = list[0]
          ..username = list[1]
          ..firstName = list[2]
          ..lastName = list[3]
          ..email = list[4]
          ..password = list[5]
          ..phone = list[6]
          ..userStatus = list[7])
        .build();
  }
}

class DateConverter extends gen.DefaultStructureConverter<gen8.Date> {
  DateConverter()
      : super(
            struct: const gen.DogStructure<gen8.Date>(
                'Date',
                gen.StructureConformity.basic,
                [
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.int>(), gen.TypeToken<gen0.int>(), null, gen.IterableKind.none, 'year', false, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.int>(), gen.TypeToken<gen0.int>(), null, gen.IterableKind.none, 'month', false, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.int>(), gen.TypeToken<gen0.int>(), null, gen.IterableKind.none, 'day', false, false, [])
                ],
                [],
                gen.ObjectFactoryStructureProxy<gen8.Date>(_activator, [_$year, _$month, _$day], _values)));

  static dynamic _$year(gen8.Date obj) => obj.year;

  static dynamic _$month(gen8.Date obj) => obj.month;

  static dynamic _$day(gen8.Date obj) => obj.day;

  static List<dynamic> _values(gen8.Date obj) => [obj.year, obj.month, obj.day];

  static gen8.Date _activator(List list) {
    return gen8.Date(list[0], list[1], list[2]);
  }
}

class DateBuilder {
  DateBuilder([gen8.Date? $src]) {
    if ($src == null) {
      $values = List.filled(3, null);
    } else {
      $values = DateConverter._values($src);
    }
  }

  late List<dynamic> $values;

  set year(gen0.int value) {
    $values[0] = value;
  }

  gen0.int get year => $values[0];

  set month(gen0.int value) {
    $values[1] = value;
  }

  gen0.int get month => $values[1];

  set day(gen0.int value) {
    $values[2] = value;
  }

  gen0.int get day => $values[2];

  gen8.Date build() => DateConverter._activator($values);
}

extension DateDogsExtension on gen8.Date {
  gen8.Date rebuild(Function(DateBuilder b) f) {
    var builder = DateBuilder(this);
    f(builder);
    return builder.build();
  }

  DateBuilder toBuilder() {
    return DateBuilder(this);
  }

  Map<String, dynamic> toNative() {
    return gen.dogs.convertObjectToNative(this, gen8.Date);
  }
}
