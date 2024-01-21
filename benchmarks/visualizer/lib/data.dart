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

[{"name":"Json Serialize","iterations":1000,"options":{"count":500},"times":{"native":911001,"json_ser":883418,"d_j_m":22234529,"freezed":867047,"dogs":900818,"built":1190075,"mappable":2297140}},{"name":"Json Deserialize","iterations":1000,"options":{"count":500},"times":{"native":691066,"json_ser":738312,"d_j_m":40528034,"freezed":749250,"dogs":818846,"built":1058845,"mappable":1081145}},{"name":"Builders","iterations":1000,"options":{"count":500},"times":{"dogs":32432,"built":34636,"freezed":12773,"d_j_m":62356126,"mappable":141063}},{"name":"Direct Equality","iterations":1000000,"options":{},"times":{"native":9601,"dogs":16543,"built":11376,"equatable":35560,"freezed":14310,"mappable":136857}},{"name":"Index Of","iterations":1000,"options":{"count":500},"times":{"native":1324663,"dogs":1331480,"built":1218739,"equatable":3948858,"freezed":1426358,"mappable":15530740}},{"name":"Map Key","iterations":1000,"options":{"count":500},"times":{"native":254637,"dogs":12537,"built":19777,"equatable":550718,"freezed":361648,"mappable":1088442}}]

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