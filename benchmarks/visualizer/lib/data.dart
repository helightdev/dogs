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

import 'package:flutter/foundation.dart';

const benchmarkData = """

[{"name":"Json Serialize","iterations":1000,"options":{"count":500},"times":{"native":484319,"json_ser":479635,"freezed":478858,"dogs":556399,"built":627856,"mappable":919908}},{"name":"Json Deserialize","iterations":1000,"options":{"count":500},"times":{"native":288237,"json_ser":311281,"freezed":313311,"dogs":390838,"built":457629,"mappable":516350}},{"name":"Builders","iterations":1000,"options":{"count":500},"times":{"dogs":15634,"built":19282,"freezed":3890,"mappable":53510}},{"name":"Direct Equality","iterations":1000000,"options":{},"times":{"native":5320,"dogs":7530,"built":5552,"equatable":22825,"freezed":7335,"mappable":76747}},{"name":"Index Of","iterations":1000,"options":{"count":500},"times":{"native":656027,"dogs":580548,"built":508889,"equatable":2637151,"freezed":673228,"mappable":7619813}},{"name":"Map Key","iterations":1000,"options":{"count":500},"times":{"native":153598,"dogs":5602,"built":9389,"equatable":265269,"freezed":163469,"mappable":440505}}]
""";

List<BenchmarkEntry> loadBenchmarkEntries() {
  var list = jsonDecode(benchmarkData.trim()) as List;
  return List.generate(
      list.length, (index) => BenchmarkEntry.fromMap(list[index]));
}

class BenchmarkEntry {
  String name;
  int iterations;
  Map<String, Object> options;
  Map<String, int> times;

  BenchmarkEntry({
    required this.name,
    required this.iterations,
    required this.options,
    required this.times,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iterations': iterations,
      'options': options,
      'times': times,
    };
  }

  factory BenchmarkEntry.fromMap(Map map) {
    if (kDebugMode) {
      print(map);
    }
    return BenchmarkEntry(
        name: map['name'] as String,
        iterations: map['iterations'] as int,
        options: (map['options'] as Map).cast<String, Object>(),
        times: (map['times'] as Map).cast<String, int>());
  }
}
