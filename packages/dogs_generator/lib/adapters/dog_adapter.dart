// ignore_for_file: unused_import

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

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';
import 'package:lyell_gen/lyell_gen.dart';
import 'package:source_gen/builder.dart';

abstract class DogsAdapter<TAnnotation>
    extends SubjectAdapter<TAnnotation, Element> {
  DogsAdapter({required super.archetype})
      : super(descriptorExtension: 'dogs', annotation: TAnnotation);
}

class CombinedBuilder implements Builder {
  final List<Builder> builders;

  CombinedBuilder(this.builders);

  @override
  Future<void> build(BuildStep buildStep) async {
    for (var builder in builders) {
      await builder.build(buildStep);
    }
  }

  @override
  Map<String, List<String>> get buildExtensions {
    var map = <String, List<String>>{};
    for (var builder in builders) {
      builder.buildExtensions.forEach((key, value) {
        var list = map[key] ?? [];
        list.addAll(value);
        map[key] = list;
      });
    }

    return map;
  }
}
