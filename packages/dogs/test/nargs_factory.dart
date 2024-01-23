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
import 'package:test/scaffolding.dart';
import 'package:test/test.dart';

void main() {
  test("NArgs Factory", () {
    DogEngine engine = DogEngine();
    engine.setSingleton();
    var treeBaseConverterFactory = TreeBaseConverterFactory.createNargsFactory<MyNargContainer>(
      nargs: 3,
      consume: <A,B,C>() => MyNargContainerConverter<A,B,C>(),
    );
    engine.registerTreeBaseFactory(MyNargContainer, treeBaseConverterFactory);
    var converter = treeBaseConverterFactory.getConverter(
    QualifiedTypeTreeN<MyNargContainer<String,int,bool>, MyNargContainer>([
      QualifiedTerminal<String>(),
      QualifiedTerminal<int>(),
      QualifiedTerminal<bool>(),
    ]), engine, false);
    var nativeSerialization = engine.modeRegistry.nativeSerialization.forConverter(converter, engine);
    var mapValue = {
      "a": "Hello",
      "b": 42,
      "c": true,
    };
    var value = nativeSerialization.deserialize(mapValue, engine);
    expect(value, MyNargContainer<String,int,bool>("Hello", 42, true));
    expect(nativeSerialization.serialize(value, engine), mapValue);
  });
}

class MyNargContainer<A,B,C> {
  final A a;
  final B b;
  final C c;

  MyNargContainer(this.a, this.b, this.c);

  String toString() => "MyNargContainer<$A, $B, $C>($a, $b, $c)";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyNargContainer &&
          runtimeType == other.runtimeType &&
          a == other.a &&
          b == other.b &&
          c == other.c;

  @override
  int get hashCode => a.hashCode ^ b.hashCode ^ c.hashCode;
}

class MyNargContainerConverter<A,B,C> extends NTreeArgConverter<MyNargContainer> {

  @override
  MyNargContainer deserialize(value, DogEngine engine) {
    return MyNargContainer<A,B,C>(
      deserializeArg(value["a"], 0, engine),
      deserializeArg(value["b"], 1, engine),
      deserializeArg(value["c"], 2, engine),
    );
  }

  @override
  serialize(MyNargContainer value, DogEngine engine) {
    return {
      "a": serializeArg(value.a, 0, engine),
      "b": serializeArg(value.b, 1, engine),
      "c": serializeArg(value.c, 2, engine)
    };
  }
}