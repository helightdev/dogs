import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

const String genAlias = "gen";

class AliasImport {
  final String import;
  final String? alias;

  const AliasImport(this.import, this.alias);

  factory AliasImport.root(String import) => AliasImport(import, null);
  factory AliasImport.gen(String import) => AliasImport(import, genAlias);
  factory AliasImport.type(DartType type, [String? alias]) {
    return AliasImport(type.element!.library!.identifier, alias);
  }
  factory AliasImport.library(LibraryElement element, [String? alias]) {
    return AliasImport(element.identifier, alias);
  }
  String get code => "import '$import'${alias == null ? "" : " as $alias"};";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AliasImport &&
          runtimeType == other.runtimeType &&
          import == other.import &&
          alias == other.alias;

  @override
  int get hashCode => import.hashCode ^ alias.hashCode;
}

String getImportString(LibraryElement library, AssetId id,
    [List<AliasImport> additional = const []]) {
  Set<AliasImport> importValues = <AliasImport>{};
  importValues.addAll(additional);
  importValues.add(AliasImport.root(id.uri.toString()));
  for (var element in library.libraryImports) {
    importValues.add(AliasImport(element.importedLibrary!.identifier,
        element.prefix?.element.displayName));
  }
  return importValues.map((e) => e.code).join("\n");
}

extension MetadataExtension on List<ElementAnnotation> {
  List<ElementAnnotation> whereTypeChecker(TypeChecker checker) =>
      where((element) => checker.isAssignableFrom(
          element.computeConstantValue()!.type!.element2!)).toList();
}
