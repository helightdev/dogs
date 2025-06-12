import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_flutter/databinding/style.dart';
import 'package:dogs_flutter/schema/custom_tags.dart';
import 'package:flutter/widgets.dart';

class SchemaBindingStyleContributor
    implements SchemaStructureMaterializationContributor {
  @override
  DogStructureField transformField(DogStructureField field, SchemaType schema) {
    if (DogsFlutterSchemaTags.bindingStyleTags.any((e) => schema[e] != null)) {
      Widget? prefix;
      if (schema[DogsFlutterSchemaTags.bindingStylePrefix] != null) {
        prefix = Text(
          schema[DogsFlutterSchemaTags.bindingStylePrefix] as String,
        );
      }
      Widget? suffix;
      if (schema[DogsFlutterSchemaTags.bindingStyleSuffix] != null) {
        suffix = Text(
          schema[DogsFlutterSchemaTags.bindingStyleSuffix] as String,
        );
      }

      final style = BindingStyle(
        label: schema[DogsFlutterSchemaTags.bindingStyleLabel],
        hint: schema[DogsFlutterSchemaTags.bindingStyleHint],
        helper: schema[DogsFlutterSchemaTags.bindingStyleHelper],
        prefix: prefix,
        suffix: suffix,
      );
      field = field.copy(annotations: [...field.annotations, style]);
    }
    return field;
  }

  @override
  DogStructure<Object> transformStructure(
    DogStructure<Object> structure,
    SchemaType schema,
  ) {
    return structure;
  }
}

extension BindingStyleSchemaBuilderExtension on SchemaType {
  SchemaType formLabel(String label) {
    this[DogsFlutterSchemaTags.bindingStyleLabel] = label;
    return this;
  }

  SchemaType formHint(String hint) {
    this[DogsFlutterSchemaTags.bindingStyleHint] = hint;
    return this;
  }

  SchemaType formHelper(String helper) {
    this[DogsFlutterSchemaTags.bindingStyleHelper] = helper;
    return this;
  }

  SchemaType formPrefix(String prefix) {
    this[DogsFlutterSchemaTags.bindingStylePrefix] = prefix;
    return this;
  }
}
