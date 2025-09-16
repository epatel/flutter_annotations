import 'package:args/args.dart';
import 'annotations/registry.dart';
import 'annotations/toString_annotation.dart';
import 'annotations/equality_annotation.dart';
import 'annotations/json_annotation.dart';
import 'annotations/copyWith_annotation.dart';
import 'annotations/initializer_annotation.dart';
import 'core/code_builder.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('source', abbr: 's', help: 'Source directory to scan')
    ..addFlag('help', abbr: 'h', help: 'Show help');

  final results = parser.parse(arguments);

  if (results['help'] || arguments.isEmpty) {
    print('Usage: dart builder.dart <source_dir>');
    print('  Generates:');
    print('    <source_dir>/builder.g.dart - Model extensions');
    print('    <source_dir>/annotations.g.dart - Annotation classes');
    print(parser.usage);
    return;
  }

  final sourceDir = arguments.isNotEmpty ? arguments[0] : results['source'];

  if (sourceDir == null) {
    print('Error: Source directory is required');
    print('Usage: dart builder.dart <source_dir>');
    return;
  }

  // Create registry and register all annotation processors
  final registry = AnnotationRegistry();
  _registerAnnotations(registry);

  // Create builder with registry and generate code
  final builder = CodeBuilder(registry);
  builder.generateFiles(sourceDir);
}

/// Register all annotation processors with the registry
void _registerAnnotations(AnnotationRegistry registry) {
  print('📋 Registering annotation processors...');

  // Self-registering annotations
  ToStringAnnotation.register(registry);
  EqualityAnnotation.register(registry);
  JsonAnnotation.register(registry);
  CopyWithAnnotation.register(registry);
  InitializerAnnotation.register(registry);

  print(
    '✅ Registered ${registry.processors.length} processors for annotations:',
  );
  for (final processor in registry.processors) {
    print(
      '  • @${processor.annotationName}(), [ ${processor.annotationAliases.map((e) => '@$e').join(', ')} ]',
    );
  }
}
