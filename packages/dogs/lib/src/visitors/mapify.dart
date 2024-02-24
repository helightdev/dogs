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

Map mapifyValue(dynamic obj) => switch (obj) {
      Map() => obj,
      List() => <String, dynamic>{r"$elements": obj},
      _ => <String, dynamic>{r"$value": obj}
    };

dynamic unmapifyValue(Map obj) {
  if (obj.containsKey(r"$elements") && obj.length == 1) {
    return obj[r"$elements"];
  } else if (obj.containsKey(r"$value") && obj.length == 1) {
    return obj[r"$value"];
  } else {
    return obj;
  }
}
