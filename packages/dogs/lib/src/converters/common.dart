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

import "dart:convert";
import "dart:typed_data";

import "package:conduit_open_api/v3.dart";
import "package:dogs_core/dogs_core.dart";

/// [DogConverter] for [DateTime] instances which encodes the timestamp as a
/// Iso8601 string.
class DateTimeConverter extends DogConverter<DateTime>
    with OperationMapMixin<DateTime> {
  DateTimeConverter()
      : super(struct: DogStructure<DateTime>.synthetic("DateTime"));

  @override
  Map<Type, OperationMode<DateTime> Function()> get modes => {
        NativeSerializerMode: () => NativeSerializerMode.create(
            serializer: (value, engine) => value.toIso8601String(),
            deserializer: (value, engine) => DateTime.parse(value)),
        GraphSerializerMode: () => GraphSerializerMode.auto(this)
      };

  @override
  APISchemaObject get output => APISchemaObject.string(format: "date-time");
}

/// [DogConverter] for [Duration] instances which encode a duration as a
/// Iso8601 string.
class DurationConverter extends DogConverter<Duration>
    with OperationMapMixin<Duration> {
  DurationConverter()
      : super(struct: DogStructure<Duration>.synthetic("Duration"));

  @override
  Map<Type, OperationMode<Duration> Function()> get modes => {
        NativeSerializerMode: () => NativeSerializerMode.create(
            serializer: (value, engine) => _writeIso8601Duration(value),
            deserializer: (value, engine) => _parseDuration(value)),
        GraphSerializerMode: () => GraphSerializerMode.auto(this)
      };

  @override
  APISchemaObject get output => APISchemaObject.integer();

  // From https://github.com/google/built_value.dart/blob/master/built_value/lib/iso_8601_duration_serializer.dart
  Duration _parseDuration(String value) {
    final match = _parseFormat.firstMatch(value);
    if (match == null) {
      throw FormatException("Invalid duration format", value);
    }
    // Iterate through the capture groups to build the unit mappings.
    final unitMappings = <String, int>{};

    // Start iterating at 1, because match[0] is the full match.
    for (var i = 1; i <= match.groupCount; i++) {
      final group = match[i];
      if (group == null) continue;

      // Get all but last character in group.
      // The RegExp ensures this must be an int.
      final value = int.parse(group.substring(0, group.length - 1));
      // Get last character.
      final unit = group.substring(group.length - 1);
      unitMappings[unit] = value;
    }
    return Duration(
      days: unitMappings[_dayToken] ?? 0,
      hours: unitMappings[_hourToken] ?? 0,
      minutes: unitMappings[_minuteToken] ?? 0,
      seconds: unitMappings[_secondToken] ?? 0,
    );
  }

  String _writeIso8601Duration(Duration duration) {
    if (duration == Duration.zero) {
      return "PT0S";
    }
    final days = duration.inDays;
    final hours = (duration - Duration(days: days)).inHours;
    final minutes = (duration - Duration(days: days, hours: hours)).inMinutes;
    final seconds =
        (duration - Duration(days: days, hours: hours, minutes: minutes))
            .inSeconds;
    final remainder = duration -
        Duration(days: days, hours: hours, minutes: minutes, seconds: seconds);

    if (remainder != Duration.zero) {
      throw ArgumentError.value(duration, "duration",
          "Contains sub-second data which cannot be serialized.");
    }
    final buffer = StringBuffer(_durationToken)
      ..write(days == 0 ? "" : '$days$_dayToken');
    if (!(hours == 0 && minutes == 0 && seconds == 0)) {
      buffer
        ..write(_timeToken)
        ..write(hours == 0 ? "" : '$hours$_hourToken')
        ..write(minutes == 0 ? "" : '$minutes$_minuteToken')
        ..write(seconds == 0 ? "" : '$seconds$_secondToken');
    }
    return buffer.toString();
  }

  // The unit tokens.
  static const _durationToken = "P";
  static const _dayToken = "D";
  static const _timeToken = "T";
  static const _hourToken = "H";
  static const _minuteToken = "M";
  static const _secondToken = "S";

  // The parse format for ISO8601 durations.
  static final _parseFormat = RegExp(
    "^P(?!\$)(0D|[1-9][0-9]*D)?"
    "(?:T(?!\$)(0H|[1-9][0-9]*H)?(0M|[1-9][0-9]*M)?(0S|[1-9][0-9]*S)?)?\$",
  );
}

/// [DogConverter] for [Uri] instances which encodes the uri into a string.
class UriConverter extends DogConverter<Uri> with OperationMapMixin<Uri> {
  UriConverter() : super(struct: DogStructure<Uri>.synthetic("Uri"));

  @override
  Map<Type, OperationMode<Uri> Function()> get modes => {
        NativeSerializerMode: () => NativeSerializerMode.create(
            serializer: (value, engine) => value.toString(),
            deserializer: (value, engine) => Uri.parse(value)),
        GraphSerializerMode: () => GraphSerializerMode.auto(this)
      };

  @override
  APISchemaObject get output => APISchemaObject.string(format: "uri");
}

/// [DogConverter] for [Uint8List] instances which encodes the binary data
/// as a base64 string using [base64Encode].
class Uint8ListConverter extends DogConverter<Uint8List>
    with OperationMapMixin<Uint8List> {
  Uint8ListConverter()
      : super(struct: DogStructure<Uint8List>.synthetic("Uint8List"));

  @override
  Map<Type, OperationMode<Uint8List> Function()> get modes => {
        NativeSerializerMode: () => NativeSerializerMode.create(
            serializer: (value, engine) => base64Encode(value),
            deserializer: (value, engine) => base64Decode(value)),
        GraphSerializerMode: () => GraphSerializerMode.auto(this)
      };

  @override
  APISchemaObject get output => APISchemaObject.string(format: "byte");
}

/// [DogConverter] for [RegExp] instances which encodes the regular expression
/// as a string.
class RegExpConverter extends SimpleDogConverter<RegExp> {
  RegExpConverter() : super(serialName: "RegExp");

  @override
  RegExp deserialize(value, DogEngine engine) {
    return RegExp(value);
  }

  @override
  serialize(RegExp value, DogEngine engine) {
    return value.pattern;
  }

  @override
  APISchemaObject get output => APISchemaObject.string(format: "regex");
}