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


[{"name":"Json Serialize","iterations":1000,"options":{"count":500},"times":{"native":919821,"json_ser":871791,"freezed":886788,"dogs":1053691,"built":1165779,"mappable":2431272}},{"name":"Json Deserialize","iterations":1000,"options":{"count":500},"times":{"native":693422,"json_ser":763582,"freezed":745832,"dogs":849681,"built":1007304,"mappable":1103323}},{"name":"Builders","iterations":1000,"options":{"count":500},"times":{"dogs":20816,"built":34294,"freezed":11121,"mappable":139905}},{"name":"Direct Equality","iterations":1000000,"options":{},"times":{"native":10219,"dogs":15749,"built":10871,"equatable":38175,"freezed":14260,"mappable":135677}},{"name":"Index Of","iterations":1000,"options":{"count":500},"times":{"native":1184006,"dogs":1297354,"built":1232183,"equatable":4172102,"freezed":1465759,"mappable":15789308}},{"name":"Map Key","iterations":1000,"options":{"count":500},"times":{"native":276844,"dogs":11624,"built":22855,"equatable":576534,"freezed":299308,"mappable":1083497}}]


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