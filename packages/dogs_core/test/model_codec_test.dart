import "package:dogs_core/dogs_models.dart";
import "package:test/test.dart";

class AliasValue {
  const AliasValue({this.id, this.name, this.echo, this.flag, this.ignored = false});

  final int? id;
  final String? name;
  final String? echo;
  final bool? flag;
  final bool ignored;
}

class TreeValue {
  const TreeValue({this.child, this.children, this.nested});

  final AliasValue? child;
  final List<AliasValue>? children;
  final TreeValue? nested;
}

class ConvertedValue {
  const ConvertedValue({this.text, required this.flag, this.whole, this.numbers, this.summary});

  final String? text;
  final int flag;
  final int? whole;
  final List<int>? numbers;
  final String? summary;
}

class NumberValue {
  const NumberValue(this.value);

  final int? value;
}

class TextValue {
  const TextValue(this.value);

  final String? value;
}

class NumberEnvelope {
  const NumberEnvelope(this.number);

  final NumberValue? number;
}

class ParsedChild {
  const ParsedChild({this.id, this.label});

  final int? id;
  final String? label;
}

class ParsedHolder {
  const ParsedHolder({this.child, this.payload, this.children});

  final ParsedChild? child;
  final ParsedChild? payload;
  final List<ParsedChild>? children;
}

class RecordingGuard extends DogModelGuard {
  final objectKeys = <String>[];
  final listKeys = <String>[];

  @override
  T? object<T>(Map<String, dynamic> json, String key, T Function(Map<String, dynamic>) parse) {
    objectKeys.add(key);
    return super.object<T>(json, key, parse);
  }

  @override
  List<T>? list<T>(Map<String, dynamic> json, String key, T Function(dynamic) parse) {
    listKeys.add(key);
    return super.list<T>(json, key, parse);
  }
}

late DogModelCodec readerCodec;
int childReaderCalls = 0;

Object readNumberChild(Map<String, dynamic> json) {
  childReaderCalls++;
  return readerCodec.fromJson<NumberValue>(json, values: {"value": (json["value"] as int) + 10});
}

Object? readSummary(Map<String, dynamic> json) =>
    "${json.containsKey("text") ? json["text"] : "missing"}:${json["suffix"] ?? ""}";

ParsedChild parseChild(Map<String, dynamic> json) => ParsedChild(
      id: json["id"] as int?,
      label: json["label"]?.toString(),
    );

num defaultNumber() => 7.9;

void registerModel<T>(DogEngine engine, DogStructure<T> structure) {
  engine.registerStructure(structure, emitChangeToStream: false);
  engine.registerAssociatedConverter(DogStructureConverterImpl<T>(structure),
      emitChangeToStream: false);
}

DogStructure<AliasValue> aliasStructure() => DogStructure<AliasValue>(
      "AliasValue",
      StructureConformity.basic,
      [
        DogStructureField.int("id", optional: true, annotations: const [
          JsonKey(aliases: ["legacy_id", "id"])
        ]),
        DogStructureField.string("name", optional: true, annotations: const [
          JsonKey(aliases: ["legacy_name", "name"])
        ]),
        DogStructureField.string("echo", optional: true, annotations: const [
          JsonKey(aliases: ["name"])
        ]),
        DogStructureField.bool("flag", optional: true, annotations: const [
          JsonKey(aliases: ["legacy_flag", "flag"])
        ]),
        DogStructureField.bool("ignored", annotations: const [JsonKey(value: false)]),
      ],
      const [
        JsonModel(outputKeys: ["id", "name"])
      ],
      ObjectFactoryStructureProxy<AliasValue>(
        (values) => AliasValue(
            id: values[0], name: values[1], echo: values[2], flag: values[3], ignored: values[4]),
        [
          (value) => value.id,
          (value) => value.name,
          (value) => value.echo,
          (value) => value.flag,
          (value) => value.ignored
        ],
        (value) => [value.id, value.name, value.echo, value.flag, value.ignored],
      ),
    );

DogStructure<TreeValue> treeStructure({bool emptyListsOnNull = true}) => DogStructure<TreeValue>(
      "TreeValue",
      StructureConformity.basic,
      [
        DogStructureField.create<AliasValue>("child", optional: true, annotations: const [
          JsonKey(aliases: ["payload"])
        ]),
        DogStructureField.create<AliasValue>(
          "children",
          optional: true,
          iterable: IterableKind.list,
          annotations: const [
            JsonKey(aliases: ["children", "old_children"])
          ],
        ),
        DogStructureField.create<TreeValue>("nested", optional: true),
      ],
      [JsonModel(emptyListsOnNull: emptyListsOnNull)],
      ObjectFactoryStructureProxy<TreeValue>(
        (values) => TreeValue(child: values[0], children: values[1], nested: values[2]),
        [(value) => value.child, (value) => value.children, (value) => value.nested],
        (value) => [value.child, value.children, value.nested],
      ),
    );

DogStructure<ConvertedValue> convertedStructure() => DogStructure<ConvertedValue>(
      "ConvertedValue",
      StructureConformity.basic,
      [
        DogStructureField.string("text", optional: true, annotations: const [
          JsonKey(aliases: ["legacy_text", "text"], convert: JsonConversions.stringify),
        ]),
        DogStructureField.int("flag", annotations: const [JsonKey(convert: JsonConversions.flagInt)]),
        DogStructureField.int("whole", optional: true, annotations: const [
          DefaultValue(0, onNull: true),
          JsonKey(convert: JsonConversions.integer)
        ]),
        DogStructureField.int("numbers",
            optional: true,
            iterable: IterableKind.list,
            annotations: const [JsonKey(each: JsonConversions.integer)]),
        DogStructureField.string("summary",
            optional: true, annotations: const [JsonKey(read: readSummary)]),
      ],
      const [JsonModel(emptyListsOnNull: true)],
      ObjectFactoryStructureProxy<ConvertedValue>(
        (values) => ConvertedValue(
            text: values[0],
            flag: values[1],
            whole: values[2],
            numbers: values[3],
            summary: values[4]),
        [
          (value) => value.text,
          (value) => value.flag,
          (value) => value.whole,
          (value) => value.numbers,
          (value) => value.summary
        ],
        (value) => [value.text, value.flag, value.whole, value.numbers, value.summary],
      ),
    );

DogStructure<NumberValue> numberStructure(
        {List<StructureMetadata> annotations = const [], JsonModel metadata = const JsonModel()}) =>
    DogStructure<NumberValue>(
      "NumberValue",
      StructureConformity.basic,
      [DogStructureField.int("value", optional: true, annotations: annotations)],
      [metadata],
      ObjectFactoryStructureProxy<NumberValue>(
          (values) => NumberValue(values[0]), [(value) => value.value], (value) => [value.value]),
    );

DogStructure<TextValue> textStructure({JsonModel metadata = const JsonModel()}) =>
    DogStructure<TextValue>(
      "TextValue",
      StructureConformity.basic,
      [DogStructureField.string("value", optional: true)],
      [metadata],
      ObjectFactoryStructureProxy<TextValue>(
          (values) => TextValue(values[0]), [(value) => value.value], (value) => [value.value]),
    );

DogStructure<NumberEnvelope> envelopeStructure() => DogStructure<NumberEnvelope>(
      "NumberEnvelope",
      StructureConformity.basic,
      [DogStructureField.create<NumberValue>("number", optional: true)],
      const [JsonModel()],
      ObjectFactoryStructureProxy<NumberEnvelope>((values) => NumberEnvelope(values[0]),
          [(value) => value.number], (value) => [value.number]),
    );

DogStructure<ParsedHolder> parsedStructure() => DogStructure<ParsedHolder>(
      "ParsedHolder",
      StructureConformity.basic,
      [
        DogStructureField.create<ParsedChild>("child", optional: true, annotations: const [
          JsonKey(parse: parseChild),
        ]),
        DogStructureField.create<ParsedChild>("payload", optional: true, annotations: const [
          JsonKey(aliases: ["legacy_payload", "payload"], parse: parseChild),
        ]),
        DogStructureField.create<ParsedChild>(
          "children",
          optional: true,
          iterable: IterableKind.list,
          annotations: const [
            JsonKey(name: "items", parse: parseChild),
          ],
        ),
      ],
      const [JsonModel(emptyListsOnNull: true)],
      ObjectFactoryStructureProxy<ParsedHolder>(
        (values) => ParsedHolder(child: values[0], payload: values[1], children: values[2]),
        [(value) => value.child, (value) => value.payload, (value) => value.children],
        (value) => [value.child, value.payload, value.children],
      ),
    );

({DogEngine engine, DogModelCodec codec}) codecFixture(
    {DogModelGuard guard = const DogModelGuard()}) {
  final engine = DogEngine();
  registerModel(engine, aliasStructure());
  registerModel(engine, treeStructure());
  registerModel(engine, convertedStructure());
  registerModel(engine, numberStructure());
  registerModel(engine, textStructure());
  registerModel(engine, envelopeStructure());
  registerModel(engine, parsedStructure());
  return (engine: engine, codec: DogModelCodec(engine: engine, guard: guard));
}

void main() {
  group("strict model fields", () {
    test("missing and explicitly null nullable fields remain null", () {
      final (:codec, :engine) = codecFixture();
      for (final input in <Map<String, dynamic>>[
        {},
        {"id": null, "name": null, "flag": null}
      ]) {
        final value = codec.fromJson<AliasValue>(input);
        expect(value.id, isNull);
        expect(value.name, isNull);
        expect(value.echo, isNull);
        expect(value.flag, isNull);
        expect(value.ignored, isFalse);
      }
      expect(engine.findStructureByType(AliasValue), isNotNull);
    });

    test("aliases retain zero, false and empty strings before later values", () {
      final (:codec, :engine) = codecFixture();
      final value = codec.fromJson<AliasValue>({
        "legacy_id": 0,
        "id": 8,
        "legacy_name": "",
        "name": "later",
        "legacy_flag": false,
        "flag": true
      });
      expect(value.id, 0);
      expect(value.name, "");
      expect(value.flag, isFalse);
      expect(value.echo, "later");
      expect(codec.engine, same(engine));
    });

    test("aliases fall back only on null and do not normalize other source fields", () {
      final (:codec, :engine) = codecFixture();
      final input = Map<String, dynamic>.unmodifiable({
        "legacy_id": null,
        "id": 3,
        "legacy_name": "only legacy",
        "legacy_flag": null,
        "flag": true,
        "ignored": true
      });
      final value = codec.fromJson<AliasValue>(input);
      expect(value.id, 3);
      expect(value.name, "only legacy");
      expect(value.echo, isNull);
      expect(value.flag, isTrue);
      expect(value.ignored, isFalse);
      expect(input.containsKey("name"), isFalse);
      expect(input["ignored"], isTrue);
      expect(codec.engine, same(engine));
    });

    test("explicit values including null override aliases and fixed metadata", () {
      final (:codec, :engine) = codecFixture();
      final value = codec.fromJson<AliasValue>(
          {"legacy_id": "bad", "legacy_name": "name", "ignored": false},
          values: {"id": null, "name": "override", "ignored": true});
      expect(value.id, isNull);
      expect(value.name, "override");
      expect(value.ignored, isTrue);
      expect(codec.engine, same(engine));
    });

    test("scalar numbers and malformed preferred aliases are never coerced", () {
      final (:codec, :engine) = codecFixture();
      for (final input in <Map<String, dynamic>>[
        {"id": "7"},
        {"id": 7.0},
        {"legacy_id": "bad", "id": 7},
        {"legacy_flag": 0, "flag": false}
      ]) {
        expect(() => codec.fromJson<AliasValue>(input), throwsA(isA<TypeError>()));
      }
      expect(codec.engine, same(engine));
    });

    test("class and call-level stringification retain null without mutating input", () {
      final (:codec, :engine) = codecFixture();
      final input = Map<String, dynamic>.unmodifiable({"value": false});
      expect(codec.fromJson<TextValue>(input, stringify: true).value, "false");
      registerModel(engine, textStructure(metadata: const JsonModel(stringify: true)));
      expect(codec.fromJson<TextValue>({"value": 0}).value, "0");
      expect(codec.fromJson<TextValue>({"value": null}).value, isNull);
      expect(input["value"], isFalse);
    });

    test("output filters preserve canonical names and explicit null fields", () {
      final (:codec, :engine) = codecFixture();
      expect(
          codec.toJson(
              const AliasValue(id: 4, name: null, echo: "hidden", flag: true, ignored: true)),
          {"id": 4, "name": null});
      expect(codec.engine, same(engine));
    });
  });

  group("nested model graph", () {
    test("objects and lists recursively preserve typed children and immutable input", () {
      final (:codec, :engine) = codecFixture();
      final child = Map<String, dynamic>.unmodifiable({"legacy_id": 1});
      final children = List<Object?>.unmodifiable([
        Map<String, dynamic>.unmodifiable({"id": 2})
      ]);
      final input = Map<String, dynamic>.unmodifiable({
        "payload": child,
        "children": children,
        "nested": Map<String, dynamic>.unmodifiable({
          "payload": Map<String, dynamic>.unmodifiable({"id": 3})
        })
      });
      final value = codec.fromJson<TreeValue>(input);
      expect(value.child?.id, 1);
      expect(value.children, isA<List<AliasValue>>());
      expect(value.children?.single.id, 2);
      expect(value.nested?.child?.id, 3);
      expect(input["payload"], same(child));
      expect(input["children"], same(children));
      expect(input.containsKey("child"), isFalse);
      expect(child.containsKey("id"), isFalse);
      expect(codec.engine, same(engine));
    });

    test("missing and null model lists receive independent mutable typed defaults", () {
      final (:codec, :engine) = codecFixture();
      final missing = codec.fromJson<TreeValue>({});
      final nullable = codec.fromJson<TreeValue>({"children": null});
      expect(missing.children, isA<List<AliasValue>>());
      expect(nullable.children, isA<List<AliasValue>>());
      expect(missing.children, isNot(same(nullable.children)));
      missing.children!.add(const AliasValue(id: 1));
      expect(nullable.children, isEmpty);
      expect(const TreeValue().children, isNull);
      expect(codec.engine, same(engine));
    });

    test("list fields retain null when class-level empty lists are disabled", () {
      final (:codec, :engine) = codecFixture();
      registerModel(engine, treeStructure(emptyListsOnNull: false));
      expect(codec.fromJson<TreeValue>({}).children, isNull);
      expect(codec.fromJson<TreeValue>({"children": null}).children, isNull);
    });

    test("list aliases choose an empty first list before a populated fallback", () {
      final (:codec, :engine) = codecFixture();
      final preferred = codec.fromJson<TreeValue>({
        "children": <dynamic>[],
        "old_children": <dynamic>[
          {"id": 2}
        ]
      });
      final fallback = codec.fromJson<TreeValue>({
        "children": null,
        "old_children": <dynamic>[
          <String, dynamic>{"id": 3}
        ]
      });
      expect(preferred.children, isEmpty);
      expect(fallback.children?.single.id, 3);
      expect(codec.engine, same(engine));
    });

    test("objects keep strict generic map checks and backend diagnostic keys", () {
      final (:codec, :engine) = codecFixture();
      for (final value in <Object>["bad", <dynamic, dynamic>{}, const AliasValue()]) {
        expect(
            () => codec.fromJson<TreeValue>({"payload": value}),
            throwsA(isA<FormatException>()
                .having((error) => error.message, "backend key", contains("payload"))
                .having((error) => error.message, "expected child", contains("AliasValue"))));
      }
      expect(codec.engine, same(engine));
    });

    test("malformed list containers and elements retain indexed canonical errors", () {
      final (:codec, :engine) = codecFixture();
      expect(() => codec.fromJson<TreeValue>({"children": "bad", "old_children": <dynamic>[]}),
          throwsFormatException);
      for (final item in <Object?>[
        null,
        "bad",
        <dynamic, dynamic>{},
        <String, dynamic>{"id": "bad"}
      ]) {
        expect(
            () => codec.fromJson<TreeValue>({
                  "old_children": <dynamic>[item]
                }),
            throwsA(isA<FormatException>()
                .having((error) => error.message, "indexed field", contains("children[0]"))));
      }
      expect(codec.engine, same(engine));
    });

    test("explicit nested values bypass parsing even when null", () {
      final (:codec, :engine) = codecFixture();
      final value = codec.fromJson<TreeValue>({"payload": "bad", "children": "bad"},
          values: {"child": null, "children": <AliasValue>[]});
      expect(value.child, isNull);
      expect(value.children, isEmpty);
      expect(codec.engine, same(engine));
    });

    test("a custom guard receives typed object and list dispatch", () {
      final guard = RecordingGuard();
      final (:codec, :engine) = codecFixture(guard: guard);
      final value = codec.fromJson<TreeValue>({
        "payload": <String, dynamic>{"id": 1}
      });
      expect(value.child, isA<AliasValue>());
      expect(guard.objectKeys, contains("payload"));
      expect(guard.listKeys, contains("children"));
      expect(codec.engine, same(engine));
    });

    test("a child reader can delegate back to the codec without recursion", () {
      final (:codec, :engine) = codecFixture();
      registerModel(engine, numberStructure(metadata: const JsonModel(reader: readNumberChild)));
      readerCodec = codec;
      childReaderCalls = 0;
      expect(codec.fromJson<NumberValue>({"value": 3}).value, 3);
      expect(childReaderCalls, 0);
      expect(
          codec
              .fromJson<NumberEnvelope>({
                "number": <String, dynamic>{"value": 3}
              })
              .number
              ?.value,
          13);
      expect(childReaderCalls, 1);
      expect(
          codec
              .fromJson<NumberEnvelope>({"number": "bad"},
                  values: {"number": const NumberValue(42)})
              .number
              ?.value,
          42);
      expect(childReaderCalls, 1);
    });

    test("raw output retains nested object identity rather than recursively serializing", () {
      final (:codec, :engine) = codecFixture();
      const child = AliasValue(id: 4);
      final children = <AliasValue>[child];
      final json = codec.toJson(TreeValue(child: child, children: children));
      expect(json["child"], same(child));
      expect(json["children"], same(children));
      expect(json.containsKey("nested"), isTrue);
      expect(json["nested"], isNull);
      expect(codec.engine, same(engine));
    });
  });

  group("declarative conversions and defaults", () {
    test("field conversions run after alias selection and retain integer flag values", () {
      final (:codec, :engine) = codecFixture();
      final value = codec.fromJson<ConvertedValue>(
          {"legacy_text": false, "text": "later", "flag": true, "whole": -3.8});
      expect(value.text, "false");
      expect(value.flag, 1);
      expect(value.whole, -3);
      for (final entry in <Object?, int>{null: 0, false: 0, 5: 5, "bad": 0}.entries) {
        expect(codec.fromJson<ConvertedValue>({"flag": entry.key}).flag, entry.value);
      }
      expect(codec.engine, same(engine));
    });

    test("list conversions create typed results and fresh defaults", () {
      final (:codec, :engine) = codecFixture();
      expect(
          codec.fromJson<ConvertedValue>({
            "numbers": <dynamic>[2.9, -3.8, 4]
          }).numbers,
          <int>[2, -3, 4]);
      final first = codec.fromJson<ConvertedValue>({});
      final second = codec.fromJson<ConvertedValue>({"numbers": null});
      expect(first.numbers, isA<List<int>>());
      first.numbers!.add(7);
      expect(second.numbers, isEmpty);
      expect(codec.engine, same(engine));
    });

    test("list conversion failures report the element index", () {
      final (:codec, :engine) = codecFixture();
      expect(
          () => codec.fromJson<ConvertedValue>({
                "numbers": <dynamic>[1, "bad"]
              }),
          throwsA(isA<FormatException>()
              .having((error) => error.message, "indexed conversion", contains("numbers[1]"))));
      expect(() => codec.fromJson<ConvertedValue>({"numbers": "bad"}), throwsFormatException);
      expect(codec.engine, same(engine));
    });

    test("whole-map reads see original immutable keys and explicit overrides win", () {
      final (:codec, :engine) = codecFixture();
      final input = Map<String, dynamic>.unmodifiable({"legacy_text": 7, "suffix": "!"});
      final value = codec.fromJson<ConvertedValue>(input);
      expect(value.text, "7");
      expect(value.summary, "missing:!");
      expect(input.containsKey("text"), isFalse);
      expect(
          codec.fromJson<ConvertedValue>(input, values: {"summary": null, "whole": null}).summary,
          isNull);
      expect(codec.fromJson<ConvertedValue>(input, values: {"whole": null}).whole, isNull);
      expect(codec.engine, same(engine));
    });

    test("default suppliers are resolved before a field conversion", () {
      final (:codec, :engine) = codecFixture();
      registerModel(
          engine,
          numberStructure(annotations: const [
            DefaultValue(defaultNumber, onNull: true),
            JsonKey(convert: JsonConversions.integer)
          ]));
      expect(codec.fromJson<NumberValue>({}).value, 7);
      expect(codec.fromJson<NumberValue>({"value": null}).value, 7);
      expect(codec.fromJson<NumberValue>({"value": 2.9}).value, 2);
    });

    test("JsonKey parse uses the field name by default and keeps nulls", () {
      final (:codec, :engine) = codecFixture();
      final input = Map<String, dynamic>.unmodifiable({
        "child": Map<String, dynamic>.unmodifiable({"id": 3, "label": 9}),
      });
      final value = codec.fromJson<ParsedHolder>(input);
      expect(value.child?.id, 3);
      expect(value.child?.label, "9");
      expect(value.payload, isNull);
      expect(codec.fromJson<ParsedHolder>({}).child, isNull);
      expect(codec.fromJson<ParsedHolder>({"child": null}).child, isNull);
      expect(input.containsKey("payload"), isFalse);
      expect(codec.engine, same(engine));
    });

    test("JsonKey name overrides aliases and reports the backend key", () {
      final (:codec, :engine) = codecFixture();
      registerModel(
          engine,
          DogStructure<ParsedHolder>(
            "ParsedHolder",
            StructureConformity.basic,
            [
              DogStructureField.create<ParsedChild>("child", optional: true, annotations: const [
                JsonKey(aliases: ["legacy_child", "child"], name: "product", parse: parseChild),
              ]),
              DogStructureField.create<ParsedChild>("payload", optional: true),
              DogStructureField.create<ParsedChild>(
                "children",
                optional: true,
                iterable: IterableKind.list,
              ),
            ],
            const [JsonModel()],
            ObjectFactoryStructureProxy<ParsedHolder>(
              (values) => ParsedHolder(child: values[0], payload: values[1], children: values[2]),
              [(value) => value.child, (value) => value.payload, (value) => value.children],
              (value) => [value.child, value.payload, value.children],
            ),
          ));
      expect(
          codec.fromJson<ParsedHolder>({
            "legacy_child": {"id": 1},
            "product": {"id": 2, "label": "ok"},
          }).child?.id,
          2);
      expect(
          () => codec.fromJson<ParsedHolder>({"product": "bad"}),
          throwsA(isA<FormatException>()
              .having((error) => error.message, "custom key", contains("product"))));
      expect(codec.engine, same(engine));
    });

    test("JsonKey parse falls back through aliases when no name is set", () {
      final (:codec, :engine) = codecFixture();
      expect(
          codec.fromJson<ParsedHolder>({
            "legacy_payload": {"id": 8, "label": true},
            "payload": {"id": 9},
          }).payload?.label,
          "true");
      expect(
          codec.fromJson<ParsedHolder>({
            "legacy_payload": null,
            "payload": {"id": 9},
          }).payload?.id,
          9);
      expect(codec.engine, same(engine));
    });

    test("JsonKey list parse reads a custom name and defaults empty lists", () {
      final (:codec, :engine) = codecFixture();
      final items = List<Object?>.unmodifiable([
        Map<String, dynamic>.unmodifiable({"id": 1, "label": "a"}),
        Map<String, dynamic>.unmodifiable({"id": 2, "label": 4}),
      ]);
      final input = Map<String, dynamic>.unmodifiable({"items": items});
      final value = codec.fromJson<ParsedHolder>(input);
      expect(value.children?.map((child) => child.id).toList(), <int>[1, 2]);
      expect(value.children?.map((child) => child.label).toList(), <String>["a", "4"]);
      expect(codec.fromJson<ParsedHolder>({}).children, isEmpty);
      expect(codec.fromJson<ParsedHolder>({"items": null}).children, isEmpty);
      expect(input["items"], same(items));
      expect(
          () => codec.fromJson<ParsedHolder>({
                "items": [
                  {"id": 1},
                  "bad"
                ]
              }),
          throwsA(isA<FormatException>()
              .having((error) => error.message, "indexed parse", contains("items[1]"))));
      expect(codec.engine, same(engine));
    });

    test("missing-only defaults retain explicit null while onNull opts in", () {
      final (:codec, :engine) = codecFixture();
      registerModel(engine, numberStructure(annotations: const [DefaultValue(7)]));
      expect(codec.fromJson<NumberValue>({}).value, 7);
      expect(codec.fromJson<NumberValue>({"value": null}).value, isNull);
      registerModel(engine, numberStructure(annotations: const [DefaultValue(9, onNull: true)]));
      expect(codec.fromJson<NumberValue>({}).value, 9);
      expect(codec.fromJson<NumberValue>({"value": null}).value, 9);
      expect(codec.fromJson<NumberValue>({"value": 0}).value, 0);
    });
  });

  group("engine and native compatibility", () {
    test("forked codecs use their own structure metadata without altering the parent", () {
      final (:codec, :engine) = codecFixture();
      registerModel(engine, numberStructure(annotations: const [DefaultValue(1)]));
      final forked = engine.fork(listen: false);
      registerModel(forked, numberStructure(annotations: const [DefaultValue(2)]));
      final other = DogModelCodec(engine: forked);
      expect(codec.fromJson<NumberValue>({}).value, 1);
      expect(other.fromJson<NumberValue>({}).value, 2);
      expect(codec.fromJson<NumberValue>({}).value, 1);
      expect(other.engine, same(forked));
    });

    test("native DefaultValue preserves explicit-null behavior unless opted in", () {
      final (:codec, :engine) = codecFixture();
      registerModel(engine, numberStructure(annotations: const [DefaultValue(7)]));
      NumberValue read(Map<String, dynamic> json) =>
          engine.convertObjectFromNative(json, NumberValue) as NumberValue;
      expect(read({}).value, 7);
      expect(read({"value": null}).value, isNull);
      registerModel(engine, numberStructure(annotations: const [DefaultValue(9, onNull: true)]));
      engine.reset();
      expect(read({}).value, 9);
      expect(read({"value": null}).value, 9);
      expect(read({"value": 0}).value, 0);
      expect(codec.fromJson<NumberValue>({"value": null}).value, 9);
    });

    test("unregistered model types fail with a useful registration error", () {
      final codec = DogModelCodec(engine: DogEngine());
      expect(
          () => codec.fromJson<NumberValue>({}),
          throwsA(isA<StateError>()
              .having((error) => error.message, "missing model", contains("NumberValue"))));
    });
  });
}
