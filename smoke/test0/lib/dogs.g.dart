// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unused_field, unused_import, public_member_api_docs, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

import 'package:dogs_core/dogs_core.dart';
import 'package:smoke_test_0/conformities.conv.g.dart' as gen3;
import 'package:smoke_test_0/conformities.conv.g.dart';
import 'package:smoke_test_0/models.conv.g.dart' as gen1;
import 'package:smoke_test_0/models.conv.g.dart';
import 'package:smoke_test_0/special.conv.g.dart' as gen2;
import 'package:smoke_test_0/special.conv.g.dart';
import 'package:smoke_test_0/special.dart' as gen0;
import 'package:smoke_test_0/special.dart';
import 'package:smoke_test_0/validation.conv.g.dart' as gen4;
import 'package:smoke_test_0/validation.conv.g.dart';

export 'package:smoke_test_0/conformities.conv.g.dart';
export 'package:smoke_test_0/models.conv.g.dart';
export 'package:smoke_test_0/special.conv.g.dart';
export 'package:smoke_test_0/special.dart';
export 'package:smoke_test_0/validation.conv.g.dart';

Future initialiseDogs() async {
  var engine = DogEngine.hasValidInstance ? DogEngine.instance : DogEngine();
  engine.registerAllConverters([
    gen0.ConvertableAConverter(),
    gen1.ModelAConverter(),
    gen1.ModelBConverter(),
    gen1.ModelCConverter(),
    gen1.ModelDConverter(),
    gen1.ModelEConverter(),
    gen1.ModelFConverter(),
    gen1.ModelGConverter(),
    gen1.NoteConverter(),
    gen1.DeepPolymorphicConverter(),
    gen2.CustomBaseImplConverter(),
    gen2.InitializersModelConverter(),
    gen2.ConstructorBodyModelConverter(),
    gen2.GetterModelConverter(),
    gen2.EnumAConverter(),
    gen3.ConformityBeanConverter(),
    gen3.ConformityBasicConverter(),
    gen3.ConformityDataConverter(),
    gen3.ConformityDataArgConverter(),
    gen4.ValidateAConverter(),
    gen4.ValidateBConverter(),
    gen4.ValidateCConverter(),
    gen4.ValidateDConverter(),
    gen4.ValidateEConverter(),
    gen4.ValidateFConverter()
  ]);
  engine.setSingleton();
}
