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
import 'package:dogs_streamed/dogs_streamed.dart';

class JsonDogWriter extends DogWriter {

  static const int backspace = 0x08;
  static const int tab = 0x09;
  static const int newline = 0x0a;
  static const int carriageReturn = 0x0d;
  static const int formFeed = 0x0c;
  static const int quote = 0x22;
  static const int char_0 = 0x30;
  static const int backslash = 0x5c;
  static const int char_b = 0x62;
  static const int char_d = 0x64;
  static const int char_f = 0x66;
  static const int char_n = 0x6e;
  static const int char_r = 0x72;
  static const int char_t = 0x74;
  static const int char_u = 0x75;
  static const int surrogateMin = 0xd800;
  static const int surrogateMask = 0xfc00;
  static const int surrogateLead = 0xd800;
  static const int surrogateTrail = 0xdc00;

  final StringBuffer buffer = StringBuffer();
  bool flagFirstEntry = false;

  String get finalString => buffer.toString();

  @override
  void writeBool(bool value) {
    buffer.write(value ? "true" : "false");
  }

  @override
  void writeDouble(double value) {
    buffer.write(value);
  }

  @override
  void writeInt(int value) {
    buffer.write(value);
  }

  @override
  void writeString(String value) {
    buffer.write('"');
    writeStringContent(value);
    buffer.write('"');
  }

  void writeStringSlice(String characters, int start, int end) {
    buffer.write(characters.substring(start, end));
  }

  // ('0' + x) or ('a' + x - 10)
  static int hexDigit(int x) => x < 10 ? 48 + x : 87 + x;

  void writeStringContent(String s) {
    var offset = 0;
    final length = s.length;
    for (var i = 0; i < length; i++) {
      var charCode = s.codeUnitAt(i);
      if (charCode > backslash) {
        if (charCode >= surrogateMin) {
          // Possible surrogate. Check if it is unpaired.
          if (((charCode & surrogateMask) == surrogateLead &&
              !(i + 1 < length &&
                  (s.codeUnitAt(i + 1) & surrogateMask) ==
                      surrogateTrail)) ||
              ((charCode & surrogateMask) == surrogateTrail &&
                  !(i - 1 >= 0 &&
                      (s.codeUnitAt(i - 1) & surrogateMask) ==
                          surrogateLead))) {
            // Lone surrogate.
            if (i > offset) writeStringSlice(s, offset, i);
            offset = i + 1;
            buffer.writeCharCode(backslash);
            buffer.writeCharCode(char_u);
            buffer.writeCharCode(char_d);
            buffer.writeCharCode(hexDigit((charCode >> 8) & 0xf));
            buffer.writeCharCode(hexDigit((charCode >> 4) & 0xf));
            buffer.writeCharCode(hexDigit(charCode & 0xf));
          }
        }
        continue;
      }
      if (charCode < 32) {
        if (i > offset) writeStringSlice(s, offset, i);
        offset = i + 1;
        buffer.writeCharCode(backslash);
        switch (charCode) {
          case backspace:
            buffer.writeCharCode(char_b);
            break;
          case tab:
            buffer.writeCharCode(char_t);
            break;
          case newline:
            buffer.writeCharCode(char_n);
            break;
          case formFeed:
            buffer.writeCharCode(char_f);
            break;
          case carriageReturn:
            buffer.writeCharCode(char_r);
            break;
          default:
            buffer.writeCharCode(char_u);
            buffer.writeCharCode(char_0);
            buffer.writeCharCode(char_0);
            buffer.writeCharCode(hexDigit((charCode >> 4) & 0xf));
            buffer.writeCharCode(hexDigit(charCode & 0xf));
            break;
        }
      } else if (charCode == quote || charCode == backslash) {
        if (i > offset) writeStringSlice(s, offset, i);
        offset = i + 1;
        buffer.writeCharCode(backslash);
        buffer.writeCharCode(charCode);
      }
    }
    if (offset == 0) {
      buffer.write(s);
    } else if (offset < length) {
      writeStringSlice(s, offset, length);
    }
  }

  @override
  void writeNullability(bool value) {
    if (value) buffer.write("null");
  }

  @override
  void beginMap(int length) {
    flagFirstEntry = true;
    buffer.write("{");
  }

  @override
  void beginMapEntry() {
    if (flagFirstEntry) {
      flagFirstEntry = false;
      return;
    }
    buffer.write(",");
  }

  @override
  void beginMapValue() {
    buffer.write(":");
  }

  @override
  void endMap() {
    flagFirstEntry = false;
    buffer.write("}");
  }

  @override
  void beginList(int length) {
    flagFirstEntry = true;
    buffer.write("[");
  }

  @override
  void beginListEntry() {
    if (flagFirstEntry) {
      flagFirstEntry = false;
      return;
    }
    buffer.write(",");
  }

  @override
  void endList() {
    flagFirstEntry = false;
    buffer.write("]");
  }
}