// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dataclasses.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<BuiltBenchmarkDataclassEntity>
    _$builtBenchmarkDataclassEntitySerializer =
    new _$BuiltBenchmarkDataclassEntitySerializer();

class _$BuiltBenchmarkDataclassEntitySerializer
    implements StructuredSerializer<BuiltBenchmarkDataclassEntity> {
  @override
  final Iterable<Type> types = const [
    BuiltBenchmarkDataclassEntity,
    _$BuiltBenchmarkDataclassEntity
  ];
  @override
  final String wireName = 'BuiltBenchmarkDataclassEntity';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, BuiltBenchmarkDataclassEntity object,
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
      'fields',
      serializers.serialize(object.fields,
          specifiedType: const FullType(BuiltMap,
              const [const FullType(String), const FullType(String)])),
    ];

    return result;
  }

  @override
  BuiltBenchmarkDataclassEntity deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new BuiltBenchmarkDataclassEntityBuilder();

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
        case 'fields':
          result.fields.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltMap,
                  const [const FullType(String), const FullType(String)]))!);
          break;
      }
    }

    return result.build();
  }
}

class _$BuiltBenchmarkDataclassEntity extends BuiltBenchmarkDataclassEntity {
  @override
  final String name;
  @override
  final int age;
  @override
  final BuiltList<String> tags;
  @override
  final BuiltMap<String, String> fields;

  factory _$BuiltBenchmarkDataclassEntity(
          [void Function(BuiltBenchmarkDataclassEntityBuilder)? updates]) =>
      (new BuiltBenchmarkDataclassEntityBuilder()..update(updates))._build();

  _$BuiltBenchmarkDataclassEntity._(
      {required this.name,
      required this.age,
      required this.tags,
      required this.fields})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        name, r'BuiltBenchmarkDataclassEntity', 'name');
    BuiltValueNullFieldError.checkNotNull(
        age, r'BuiltBenchmarkDataclassEntity', 'age');
    BuiltValueNullFieldError.checkNotNull(
        tags, r'BuiltBenchmarkDataclassEntity', 'tags');
    BuiltValueNullFieldError.checkNotNull(
        fields, r'BuiltBenchmarkDataclassEntity', 'fields');
  }

  @override
  BuiltBenchmarkDataclassEntity rebuild(
          void Function(BuiltBenchmarkDataclassEntityBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BuiltBenchmarkDataclassEntityBuilder toBuilder() =>
      new BuiltBenchmarkDataclassEntityBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BuiltBenchmarkDataclassEntity &&
        name == other.name &&
        age == other.age &&
        tags == other.tags &&
        fields == other.fields;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, age.hashCode);
    _$hash = $jc(_$hash, tags.hashCode);
    _$hash = $jc(_$hash, fields.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BuiltBenchmarkDataclassEntity')
          ..add('name', name)
          ..add('age', age)
          ..add('tags', tags)
          ..add('fields', fields))
        .toString();
  }
}

class BuiltBenchmarkDataclassEntityBuilder
    implements
        Builder<BuiltBenchmarkDataclassEntity,
            BuiltBenchmarkDataclassEntityBuilder> {
  _$BuiltBenchmarkDataclassEntity? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _age;
  int? get age => _$this._age;
  set age(int? age) => _$this._age = age;

  ListBuilder<String>? _tags;
  ListBuilder<String> get tags => _$this._tags ??= new ListBuilder<String>();
  set tags(ListBuilder<String>? tags) => _$this._tags = tags;

  MapBuilder<String, String>? _fields;
  MapBuilder<String, String> get fields =>
      _$this._fields ??= new MapBuilder<String, String>();
  set fields(MapBuilder<String, String>? fields) => _$this._fields = fields;

  BuiltBenchmarkDataclassEntityBuilder();

  BuiltBenchmarkDataclassEntityBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _age = $v.age;
      _tags = $v.tags.toBuilder();
      _fields = $v.fields.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BuiltBenchmarkDataclassEntity other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$BuiltBenchmarkDataclassEntity;
  }

  @override
  void update(void Function(BuiltBenchmarkDataclassEntityBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BuiltBenchmarkDataclassEntity build() => _build();

  _$BuiltBenchmarkDataclassEntity _build() {
    _$BuiltBenchmarkDataclassEntity _$result;
    try {
      _$result = _$v ??
          new _$BuiltBenchmarkDataclassEntity._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'BuiltBenchmarkDataclassEntity', 'name'),
            age: BuiltValueNullFieldError.checkNotNull(
                age, r'BuiltBenchmarkDataclassEntity', 'age'),
            tags: tags.build(),
            fields: fields.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tags';
        tags.build();
        _$failedField = 'fields';
        fields.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'BuiltBenchmarkDataclassEntity', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
