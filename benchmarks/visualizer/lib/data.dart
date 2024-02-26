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

const benchmarkData = """


[{"name":"Json Serialize","iterations":1000,"options":{"count":500},"times":{"native":846743,"json_ser":845537,"freezed":848542,"dogs":988639,"built":1126858,"mappable":2385272}},{"name":"Json Deserialize","iterations":1000,"options":{"count":500},"times":{"native":678217,"json_ser":722527,"freezed":724358,"dogs":872475,"built":997094,"mappable":1096667}},{"name":"Builders","iterations":1000,"options":{"count":500},"times":{"dogs":22625,"built":36453,"freezed":12577,"mappable":136699}},{"name":"Direct Equality","iterations":1000000,"options":{},"times":{"native":10425,"dogs":15762,"built":11961,"equatable":35700,"freezed":13446,"mappable":139424}},{"name":"Index Of","iterations":1000,"options":{"count":500},"times":{"native":1338166,"dogs":1349076,"built":1056771,"equatable":4200633,"freezed":1502488,"mappable":15204543}},{"name":"Map Key","iterations":1000,"options":{"count":500},"times":{"native":272888,"dogs":13430,"built":20652,"equatable":574265,"freezed":302901,"mappable":1075792}}]

""";

List<BenchmarkEntry> loadBenchmarkEntries() {
  var list = jsonDecode(benchmarkData.trim()) as List;
  return List.generate(list.length, (index) => BenchmarkEntry.fromMap(list[index]));
}

class BenchmarkEntry {
  String name;
  int iterations;
  Map<String,Object> options;
  Map<String,int> times;

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
    print(map);
    return BenchmarkEntry(
      name: map['name'] as String,
      iterations: map['iterations'] as int,
      options: (map['options'] as Map).cast<String,Object>(),
      times: (map['times'] as Map).cast<String,int>()
    );
  }
}