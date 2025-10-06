import 'index.dart';

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

  // Create registry and set as global
  final registry = AnnotationRegistry();
  setGlobalRegistry(registry);

  // Call builderInitializer to auto-register all @Initializer processors
  print('🔧 Initializing annotation processors...');
  builderInitializer();

  // Display registered processors
  print(
    '✅ Registered ${registry.processors.length} processors for annotations:',
  );
  for (final processor in registry.processors) {
    print(
      '  • @${processor.annotationName}(), [ ${processor.annotationAliases.map((e) => '@$e').join(', ')} ]',
    );
  }

  // Create builder with registry and generate code
  final builder = CodeBuilder(registry);
  builder.generateFiles(sourceDir);
}
