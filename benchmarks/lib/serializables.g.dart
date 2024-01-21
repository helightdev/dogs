// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializables.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (new Serializers().toBuilder()
      ..add(BuiltPerson.serializer)
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>()))
    .build();
Serializer<BuiltPerson> _$builtPersonSerializer = new _$BuiltPersonSerializer();

class _$BuiltPersonSerializer implements StructuredSerializer<BuiltPerson> {
  @override
  final Iterable<Type> types = const [BuiltPerson, _$BuiltPerson];
  @override
  final String wireName = 'BuiltPerson';

  @override
  Iterable<Object?> serialize(Serializers serializers, BuiltPerson object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'age',
      serializers.serialize(object.age, specifiedType: const FullType(int)),
      'tags',
      serializers.serialize(object.tags,
          specifiedType:
              const FullType(BuiltList, const [const FullType(String)])),
    ];

    return result;
  }

  @override
  BuiltPerson deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new BuiltPersonBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'age':
          result.age = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'tags':
          result.tags.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$BuiltPerson extends BuiltPerson {
  @override
  final String name;
  @override
  final int age;
  @override
  final BuiltList<String> tags;

  factory _$BuiltPerson([void Function(BuiltPersonBuilder)? updates]) =>
      (new BuiltPersonBuilder()..update(updates))._build();

  _$BuiltPerson._({required this.name, required this.age, required this.tags})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(name, r'BuiltPerson', 'name');
    BuiltValueNullFieldError.checkNotNull(age, r'BuiltPerson', 'age');
    BuiltValueNullFieldError.checkNotNull(tags, r'BuiltPerson', 'tags');
  }

  @override
  BuiltPerson rebuild(void Function(BuiltPersonBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BuiltPersonBuilder toBuilder() => new BuiltPersonBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BuiltPerson &&
        name == other.name &&
        age == other.age &&
        tags == other.tags;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, age.hashCode);
    _$hash = $jc(_$hash, tags.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BuiltPerson')
          ..add('name', name)
          ..add('age', age)
          ..add('tags', tags))
        .toString();
  }
}

class BuiltPersonBuilder implements Builder<BuiltPerson, BuiltPersonBuilder> {
  _$BuiltPerson? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _age;
  int? get age => _$this._age;
  set age(int? age) => _$this._age = age;

  ListBuilder<String>? _tags;
  ListBuilder<String> get tags => _$this._tags ??= new ListBuilder<String>();
  set tags(ListBuilder<String>? tags) => _$this._tags = tags;

  BuiltPersonBuilder();

  BuiltPersonBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _age = $v.age;
      _tags = $v.tags.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BuiltPerson other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$BuiltPerson;
  }

  @override
  void update(void Function(BuiltPersonBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BuiltPerson build() => _build();

  _$BuiltPerson _build() {
    _$BuiltPerson _$result;
    try {
      _$result = _$v ??
          new _$BuiltPerson._(
              name: BuiltValueNullFieldError.checkNotNull(
                  name, r'BuiltPerson', 'name'),
              age: BuiltValueNullFieldError.checkNotNull(
                  age, r'BuiltPerson', 'age'),
              tags: tags.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tags';
        tags.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'BuiltPerson', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsonSerializablePerson _$JsonSerializablePersonFromJson(
        Map<String, dynamic> json) =>
    JsonSerializablePerson(
      json['name'] as String,
      json['age'] as int,
      (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$JsonSerializablePersonToJson(
        JsonSerializablePerson instance) =>
    <String, dynamic>{
      'name': instance.name,
      'age': instance.age,
      'tags': instance.tags,
    };

_$FreezedPersonImpl _$$FreezedPersonImplFromJson(Map<String, dynamic> json) =>
    _$FreezedPersonImpl(
      name: json['name'] as String,
      age: json['age'] as int,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$FreezedPersonImplToJson(_$FreezedPersonImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'age': instance.age,
      'tags': instance.tags,
    };
