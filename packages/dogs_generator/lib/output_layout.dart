import 'package:build/build.dart';
import 'package:lyell_gen/lyell_gen.dart';
import 'package:path/path.dart' as path;

/// Determines generated Dart paths before build_runner creates its asset graph.
class DogsOutputLayout {
  final String? directory;

  const DogsOutputLayout({this.directory});

  factory DogsOutputLayout.fromOptions(BuilderOptions options) {
    final value = options.config['output_directory'];
    if (value == null) return const DogsOutputLayout();
    if (value is! String ||
        value.isEmpty ||
        value.contains('\\') ||
        value.contains(':') ||
        path.posix.isAbsolute(value) ||
        value.split('/').any((segment) => segment.isEmpty || segment == '.' || segment == '..')) {
      throw ArgumentError.value(
          value, 'output_directory', 'Expected a relative directory below lib');
    }
    return DogsOutputLayout(directory: value);
  }

  AssetId converterAsset(AssetId input) {
    final directory = this.directory;
    if (directory == null) return input.changeExtension('.conv.g.dart');
    if (!input.path.startsWith('lib/')) {
      throw ArgumentError.value(input.path, 'input', 'Relocated models must be under lib');
    }
    return AssetId(input.package, 'lib/$directory/${input.path.substring(4)}')
        .changeExtension('.conv.g.dart');
  }

  String reactorFileName() => directory == null ? 'dogs.g.dart' : '$directory/dogs.g.dart';

  Map<String, List<String>> converterBuildExtensions() => {
        if (directory == null)
          '.dart': ['.conv.g.dart']
        else
          '^lib/{{}}.dart': ['lib/$directory/{{}}.conv.g.dart'],
      };

  void validateDescriptor(SubjectDescriptor descriptor) {
    if (descriptor.meta.containsKey('outputDirectory') &&
        descriptor.meta['outputDirectory'] != directory) {
      throw StateError(
        'Configure output_directory identically for dogs_descriptors, dogs_bindings and '
        'dogs_reactor. Converter ${descriptor.uri} uses '
        '${descriptor.meta['outputDirectory']}, but dogs_reactor uses $directory.',
      );
    }
  }
}
