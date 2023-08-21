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

import 'schemaless.dart';

class PrimitiveBuffer {

  List<dynamic> values = [];
  void write(dynamic value) => values.add(value);

  int _readerIndex = 0;
  dynamic read() => values[_readerIndex++];
  void rewind() => _readerIndex = 0;
  void clear() => values.clear();

  PrimitiveBufferWriter get writer => PrimitiveBufferWriter(this);
  PrimitiveBufferReader get reader => PrimitiveBufferReader(this);
}

class PrimitiveBufferReader extends DogReader {

  PrimitiveBuffer buffer;
  PrimitiveBufferReader(this.buffer);

  @override
  bool readBool() => buffer.read() as bool;

  @override
  double readDouble() => buffer.read() as double;

  @override
  int readInt() => buffer.read() as int;

  @override
  String readString() => buffer.read() as String;
}

class PrimitiveBufferWriter extends DogWriter {

  PrimitiveBuffer buffer;
  PrimitiveBufferWriter(this.buffer);

  @override
  void writeBool(bool value) => buffer.write(value);

  @override
  void writeDouble(double value) => buffer.write(value);

  @override
  void writeInt(int value) => buffer.write(value);

  @override
  void writeString(String value) => buffer.write(value);
}