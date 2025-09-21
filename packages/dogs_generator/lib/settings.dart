import 'package:build/build.dart';
import 'package:pubspec/pubspec.dart';
import 'package:recase/recase.dart';

class DogsGeneratorSettings {
  bool isLibrary = false;
  bool nullableAccessors = false;
  CasingType propertyCase = CasingType.keep;
  CasingType nameCase = CasingType.keep;
  CasingType enumCase = CasingType.keep;

  static Future<DogsGeneratorSettings> load(BuildStep buildStep) async {
    var settings = DogsGeneratorSettings();

    try {
      var pubspecString =
          await buildStep.readAsString(AssetId(buildStep.inputId.package, "pubspec.yaml"));
      var pubspec = PubSpec.fromYamlString(pubspecString);
      var dogsRegion = pubspec.unParsedYaml?["dogs"];
      if (dogsRegion != null) {
        log.info("Using dogs generator options specified in the pubspec.yaml");
        var map = dogsRegion as Map;

        var isLibraryValue = map["library"];
        if (isLibraryValue is bool) {
          settings.isLibrary = isLibraryValue;
        }

        var casingValue = map["property_case"];
        if (casingValue is String) {
          settings.propertyCase = CasingType.fromString(casingValue);
        }

        var nameCasingValue = map["name_case"];
        if (nameCasingValue is String) {
          settings.nameCase = CasingType.fromString(nameCasingValue);
        }

        var enumCasingValue = map["enum_case"];
        if (enumCasingValue is String) {
          settings.enumCase = CasingType.fromString(enumCasingValue);
        }
        
        var nullableAccessorsValue = map["nullable_accessors"];
        if (nullableAccessorsValue is bool) {
          settings.nullableAccessors = nullableAccessorsValue;
        }
      }
    } catch (ex) {
      log.warning("Can't resolve package pubspec.yaml with error: $ex. Using default values.");
    }
    return settings;
  }
}

enum CasingType {
  keep,
  snake,
  kebab,
  camel,
  pascal,
  constant;

  static CasingType fromString(String value) {
    switch (value.toLowerCase()) {
      case "keep":
        return CasingType.keep;
      case "snake":
        return CasingType.snake;
      case "kebab":
        return CasingType.kebab;
      case "camel":
        return CasingType.camel;
      case "pascal":
        return CasingType.pascal;
      case "constant":
        return CasingType.constant;
      default:
        return CasingType.keep;
    }
  }

  String recase(String input) {
    switch (this) {
      case CasingType.keep:
        return input;
      case CasingType.snake:
        return ReCase(input).snakeCase;
      case CasingType.camel:
        return ReCase(input).camelCase;
      case CasingType.pascal:
        return ReCase(input).pascalCase;
      case CasingType.constant:
        return ReCase(input).constantCase;
      case CasingType.kebab:
        return ReCase(input).paramCase;
    }
  }
}
