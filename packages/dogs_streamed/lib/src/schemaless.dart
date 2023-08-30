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

import 'dart:convert';
import 'dart:ffi';

abstract class DogReader {
  String readString();
  int readInt();
  double readDouble();
  bool readBool();

  bool readNullability() => readBool();
  T? readNullable<T>(T Function() func) {
    var isNull = readNullability();
    if (isNull) return null;
    return func();
  }

  String? readStringOpt() => readNullable(() => readString());
  int? readIntOpt() => readNullable(() => readInt());
  double? readDoubleOpt() => readNullable(() => readDouble());
  bool? readBoolOpt() => readNullable(() => readBool());

  int readListStart() => readInt();
  void nextListEntry() {}
  void readListEnd() {}
  void rewindList() {}

  int readMapStart() => readInt();
  String readMapKey() => readString();
  void readMapValue() {}
  void nextMapEntry() {}
  void rewindMap() {}
  bool gotoMapValue(String key) => false;

  void readObjectStart() {}
  void readObjectEnd() {}

}

class NativeMapReader extends DogReader {
  List stack = [];
  List<int> cursorStack = [];
  int cursor = 0;
  dynamic top;
  dynamic chunk;

  NativeMapReader(dynamic value) {
    top = value;
    chunk = value;
  }

  void push(dynamic value) {
    stack.add(top);
    cursorStack.add(cursor);
    top = value;
    cursor = 0;
    chunk = top;
  }

  dynamic pop() {
    var popped = top;
    top = stack.removeLast();
    cursor = cursorStack.removeLast();
    chunk = top;
    return popped;
  }

  @override
  bool readBool() {
    return chunk;
  }

  @override
  double readDouble() {
    return chunk;
  }

  @override
  int readInt() {
    return chunk;
  }

  @override
  String readString() {
    return chunk;
  }

  @override
  int readMapStart() {
    var map = (chunk as Map);
    push(map);
    return map.length;
  }

  @override
  void nextMapEntry() {
    chunk = (top as Map).entries.elementAt(cursor++);
  }

  @override
  void readMapValue() {
    chunk = (chunk as MapEntry).value;
  }

  @override
  String readMapKey() {
    return (chunk as MapEntry).key as String;
  }

  @override
  bool gotoMapValue(String key) {
    var map = (top as Map);
    var value = map[key];
    if (value == null) return false;
    chunk = MapEntry(key, value);
    return true;
  }

  @override
  void rewindMap() {
    cursor = 0;
  }

  @override
  int readListStart() {
    var list = (chunk as List);
    push(list);
    return list.length;
  }

  @override
  void readListEnd() {
    pop();
  }

  @override
  void nextListEntry() {
    chunk = (top as List).elementAt(cursor++);
  }

  @override
  void rewindList() {
    cursor = 0;
  }
}

abstract class DogWriter {
  void writeString(String value);
  void writeInt(int value);
  void writeDouble(double value);
  void writeBool(bool value);

  void writeNullability(bool value) => writeBool(value);
  void writeNullable<T>(T? value, Function(T) func) {
    var notNull = value != null;
    writeNullability(notNull);
    if (notNull) func(value);
  }

  void writeStringOpt(String? value) => writeNullable(value, (p0) => writeString(p0));
  void writeIntOpt(int? value) => writeNullable(value, (p0) => writeInt(p0));
  void writeDoubleOpt(double? value) => writeNullable(value, (p0) => writeDouble(p0));
  void writeBoolOpt(bool? value) => writeNullable(value, (p0) => writeBool(p0));

  void beginList(int length) => writeInt(length);
  void beginListEntry() {}
  void endList() {}

  // Maps must retain their keys and be able to skip to specific key before starting to read
  void beginMap(int length) => writeInt(length);
  void writeMapEntry(String key) => writeString(key);
  void endMap() {}

  // Objects must not retain their key but are free to act like maps to allow more freeform data.
  void beginObject(int propertyCount) => beginMap(propertyCount);
  void writeObjectProperty(String key) => writeMapEntry(key);
  void endObject() => endMap();
}
