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
// ignore_for_file: invalid_use_of_internal_member

import 'package:conduit_open_api/v3.dart';
import 'package:darwin_http/darwin_http.dart';
import 'package:darwin_injector/darwin_injector.dart';
import 'package:darwin_sdk/darwin_sdk.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:darwin_marshal/darwin_marshal.dart';
import 'package:dogs_darwin/dogs_darwin.dart';

class DogPlugin extends DarwinPlugin {
  @override
  Future configure() async {}

  @override
  Stream<Module> collectModules() async* {
    yield Module()..bind(DogEngine).toConstant(dogs);
  }

  @override
  Stream<ServiceDescriptor> collectServices() async* {
    yield DogServiceDescriptor();
  }
}

class DogServiceDescriptor extends ServiceDescriptor {
  @override
  Type get bindingType => DogService;

  @override
  Type get serviceType => DogService;

  @override
  List<Condition> get conditions => [];

  @override
  List<InjectorKey> get dependencies =>
      [InjectorKey.create(DarwinSystem), InjectorKey.create(DogEngine)];

  @override
  List<InjectorKey> get publications => [InjectorKey.create(DogService)];

  @override
  Future instantiate(Injector injector) async {
    return DogService(
        await injector.get(DarwinSystem), await injector.get(DogEngine));
  }

  @override
  Future<void> start(DarwinSystem system, obj) async {
    obj.start();
  }

  @override
  Future<void> stop(DarwinSystem system, obj) async {}
}

class DogService {
  DarwinSystem system;
  DogEngine engine;

  DogService(this.system, this.engine);

  void start() {
    if (system.serviceMixin.findDescriptors(DarwinHttpServer).isNotEmpty) {
      system.eventbus.getLine<ApiDocsResolveParameterTypeEvent>().subscribe((p0) {
        var type = p0.args.parameter!.typeArgument;
        var object = resolve(type);
        if (object != null) p0.update(object);
      });
      system.eventbus.getLine<ApiDocsResolveReturnTypeEvent>().subscribe((p0) {
        var type = p0.args.registration.returnType.typeArgument;
        var object = resolve(type);
        if (object != null) p0.update(object);
      });
      system.eventbus.getLine<ApiDocsPopulateEvent>().subscribe((p0) {
        p0.document.components!.schemas
            .addAll(DogSchema.create().getComponents().schemas);
      });
    }
    if (system.serviceMixin.findDescriptors(DarwinMarshal).isNotEmpty) {
      system.eventbus.getLine<MarshalConfigureEvent>().subscribe((p0) {
        DogsMarshal.link(p0.marshal);
      });
    }
  }

  APISchemaObject? resolve(Type type) {
    for (var entry in dogs.structures.entries) {
      var value = entry.value;
      var converter = dogs.findAssociatedConverter(value.typeArgument)!;
      if (value.deriveIterable == type ||
          value.deriveList == type ||
          value.deriveSet == type) {
        return APISchemaObject.array(ofSchema: converter.output);
      } else if (value.typeArgument == type) {
        return converter.output;
      }
    }
    return null;
  }
}
