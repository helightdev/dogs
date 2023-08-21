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

  int readMapStart() => readInt();
  void readMapKey() {}
  void readMapValue() {}
  void nextMapEntry() {}

  void readObjectStart() {}
  void readObjectEnd() {}

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

  void beginMap(int length) => writeInt(length);
  void beginMapEntry() {}
  void beginMapKey() {}
  void beginMapValue() {}
  void endMap() {}

  void beginObject() {}
  void endObject() {}
}
