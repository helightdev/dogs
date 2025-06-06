#!/bin/bash
#
#    Copyright 2022, the DOGs authors
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

# Setup OpenAPI Generator CLI
echo "Setting up OpenAPI Generator CLI..."
flutter pub global activate openapi_generator_cli

echo "Generating OpenAPI client code..."
(
  rm -rf "openapi"
  mkdir "openapi"
  cd "openapi"
  openapi-generator generate -i https://petstore.swagger.io/v2/swagger.json -g dart-dio
  flutter pub get
  flutter pub run build_runner build --delete-conflicting-outputs
)

# Run the test
echo  "Running OpenAPI client tests..."
flutter pub get
flutter pub upgrade
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run lib/test.dart