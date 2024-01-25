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


[{"name":"Json Serialize","iterations":1000,"options":{"count":500},"times":{"native":924299,"json_ser":881202,"freezed":881219,"dogs":1006485,"built":1250134,"mappable":2391038}},{"name":"Json Deserialize","iterations":1000,"options":{"count":500},"times":{"native":674524,"json_ser":722911,"freezed":735751,"dogs":894164,"built":1002346,"mappable":1076039}},{"name":"Builders","iterations":1000,"options":{"count":500},"times":{"dogs":21415,"built":34778,"freezed":11767,"mappable":141253}},{"name":"Direct Equality","iterations":1000000,"options":{},"times":{"native":10373,"dogs":15861,"built":10748,"equatable":37991,"freezed":14433,"mappable":153503}},{"name":"Index Of","iterations":1000,"options":{"count":500},"times":{"native":1320760,"dogs":1336138,"built":1082435,"equatable":4521335,"freezed":1633956,"mappable":16448461}},{"name":"Map Key","iterations":1000,"options":{"count":500},"times":{"native":346661,"dogs":13406,"built":22165,"equatable":559157,"freezed":326905,"mappable":1105087}}]


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