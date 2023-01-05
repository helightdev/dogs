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

import 'package:aqueduct_isolates/aqueduct_isolates.dart';
import 'package:dogs/dogs.dart';

class DogsSerializerAqueduct extends Aqueduct {
  final DogEngine engine;

  DogsSerializerAqueduct(this.engine);

  @override
  void isolateRun() async {
    await for (var event in events) {
      var list = event as List;
      String op = list[0];
      var source = list[1];
      Type type = list[2];

      if (op == "jsonDecode") {
        var graph = engine.jsonSerializer.deserialize(source);
        send(engine.convertObjectFromGraph(graph, type));
      } else if (op == "jsonEncode") {
        var graph = engine.convertObjectToGraph(source, type);
        send(engine.jsonSerializer.serialize(graph));
      } else if (op == "toGraph") {
        var graph = engine.convertObjectToGraph(source, type);
        send(graph);
      } else if (op == "fromGraph") {
        var value = engine.convertObjectFromGraph(source, type);
        send(value);
      }
    }
  }

  @override
  void mainRun() {}

  @MainIsolate()
  Future<dynamic> decodeJson(String json, Type type) async {
    var future = next; // Avoid race conditions, even if unlikely
    send(["jsonDecode", json, type]);
    return await future;
  }

  @MainIsolate()
  Future<String> encodeJson(dynamic value, Type type) async {
    var future = next; // Avoid race conditions, even if unlikely
    send(["jsonEncode", value, type]);
    return await future;
  }

  @MainIsolate()
  Future<DogGraphValue> convertToGraph(dynamic value, Type type) async {
    var future = next; // Avoid race conditions, even if unlikely
    send(["toGraph", value, type]);
    return await future;
  }

  @MainIsolate()
  Future<dynamic> convertFromGraph(DogGraphValue value, Type type) async {
    var future = next; // Avoid race conditions, even if unlikely
    send(["fromGraph", value, type]);
    return await future;
  }
}
