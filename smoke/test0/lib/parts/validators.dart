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

part of "../test.dart";

void testValidators() {
  testValidation(ValidateA.trues, ValidateA.falses);
  testValidation(ValidateB.trues, ValidateB.falses);
  testValidation(ValidateC.trues, ValidateC.falses);
  testValidation(ValidateD.trues, ValidateD.falses);
  testValidation(ValidateE.trues, ValidateE.falses);
  testValidation(ValidateF.trues, ValidateF.falses);
}

void testValidation<T extends Dataclass<T>>(List<T> Function() trues, List<T> Function() falses) {
  trues().forEach((element) {
    expect(element.isValid, isTrue);
    expect(dogs.validateAnnotated(element).messages, isEmpty);
  });

  falses().forEach((element) {
    expect(element.isValid, isFalse);
    expect(dogs.validateAnnotated(element).messages, isNotEmpty);
  });
}
