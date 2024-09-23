// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unused_field, unused_import, public_member_api_docs, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

import 'package:smoke_test_0/special.dart';
import 'package:smoke_test_0/validation.conv.g.dart';
import 'package:smoke_test_0/models.conv.g.dart';
import 'package:smoke_test_0/special.conv.g.dart';
import 'package:smoke_test_0/conformities.conv.g.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:smoke_test_0/special.dart' as gen0;
import 'package:smoke_test_0/validation.conv.g.dart' as gen1;
import 'package:smoke_test_0/models.conv.g.dart' as gen2;
import 'package:smoke_test_0/special.conv.g.dart' as gen3;
import 'package:smoke_test_0/conformities.conv.g.dart' as gen4;
export 'package:smoke_test_0/special.dart';
export 'package:smoke_test_0/validation.conv.g.dart';
export 'package:smoke_test_0/models.conv.g.dart';
export 'package:smoke_test_0/special.conv.g.dart';
export 'package:smoke_test_0/conformities.conv.g.dart';

Future initialiseDogs() async {
  var engine = DogEngine.hasValidInstance ? DogEngine.instance : DogEngine();
  engine.registerAllConverters([
    gen0.ConvertableAConverter(),
    gen1.ValidateAConverter(),
    gen1.ValidateBConverter(),
    gen1.ValidateCConverter(),
    gen1.ValidateDConverter(),
    gen1.ValidateEConverter(),
    gen1.ValidateFConverter(),
    gen2.ModelAConverter(),
    gen2.ModelBConverter(),
    gen2.ModelCConverter(),
    gen2.ModelDConverter(),
    gen2.ModelEConverter(),
    gen2.ModelFConverter(),
    gen2.ModelGConverter(),
    gen2.NoteConverter(),
    gen2.DeepPolymorphicConverter(),
    gen3.CustomBaseImplConverter(),
    gen3.InitializersModelConverter(),
    gen3.ConstructorBodyModelConverter(),
    gen3.GetterModelConverter(),
    gen3.DefaultValueModelConverter(),
    gen3.EnumAConverter(),
    gen4.ConformityBeanConverter(),
    gen4.ConformityBasicConverter(),
    gen4.ConformityDataConverter(),
    gen4.ConformityDataArgConverter()
  ]);
  engine.setSingleton();
}
