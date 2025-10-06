import '../index.dart';
import 'package:path/path.dart' as path;

/// Discovers and registers annotation processors by scanning the builder's
/// annotations directory for classes marked with @RegisterProcessor.
///
/// This enables the builder to use its own annotation system to achieve
/// self-referential, modular processor registration.
class ProcessorDiscovery {
  /// Automatically discover and register all annotation processors
  /// by scanning the annotations directory.
  static void autoRegister(AnnotationRegistry registry) {
    print('🔍 Auto-discovering annotation processors...');

    // Get the builder directory path
    final builderDir = _getBuilderDirectory();
    if (builderDir == null) {
      print(
        '⚠️  Could not locate builder directory, falling back to manual registration',
      );
      _fallbackRegistration(registry);
      return;
    }

    final annotationsDir = Directory(path.join(builderDir, 'annotations'));
    if (!annotationsDir.existsSync()) {
      print(
        '⚠️  Annotations directory not found, falling back to manual registration',
      );
      _fallbackRegistration(registry);
      return;
    }

    // Scan annotation files and collect processor info
    final processorInfo = <_ProcessorInfo>[];

    for (final entity in annotationsDir.listSync()) {
      if (entity is File &&
          entity.path.endsWith('_annotation.dart') &&
          !entity.path.endsWith('register_processor_annotation.dart')) {
        final info = _scanProcessorFile(entity);
        if (info != null) {
          processorInfo.add(info);
        }
      }
    }

    // Sort by priority (lower numbers first)
    processorInfo.sort((a, b) => a.priority.compareTo(b.priority));

    // Instantiate and register processors
    for (final info in processorInfo) {
      final processor = info.instantiate();
      if (processor != null) {
        registry.add(processor);
        print(
          '  ✓ Registered: ${processor.annotationName} (priority: ${info.priority})',
        );
      }
    }

    if (processorInfo.isEmpty) {
      print(
        '⚠️  No processors discovered, falling back to manual registration',
      );
      _fallbackRegistration(registry);
    } else {
      print('✅ Auto-registered ${processorInfo.length} processors');
    }
  }

  /// Scan a processor file to extract metadata
  static _ProcessorInfo? _scanProcessorFile(File file) {
    try {
      final content = file.readAsStringSync();
      final parseResult = parseString(content: content);
      final unit = parseResult.unit;

      // Find class declarations with @RegisterProcessor annotation
      for (final declaration in unit.declarations) {
        if (declaration is ClassDeclaration) {
          final className = declaration.name.lexeme;
          int priority = 100;
          String? description;

          // Check for @RegisterProcessor annotation
          for (final metadata in declaration.metadata) {
            if (metadata.name.name == 'RegisterProcessor' ||
                metadata.name.name == 'registerProcessor') {
              // Parse priority if specified
              if (metadata.arguments != null) {
                for (final arg in metadata.arguments!.arguments) {
                  if (arg is NamedExpression) {
                    if (arg.name.label.name == 'priority') {
                      final value = arg.expression.toString();
                      priority = int.tryParse(value) ?? 100;
                    } else if (arg.name.label.name == 'description') {
                      description = arg.expression
                          .toString()
                          .replaceAll("'", '')
                          .replaceAll('"', '');
                    }
                  }
                }
              }

              return _ProcessorInfo(
                className: className,
                file: file,
                priority: priority,
                description: description,
              );
            }
          }
        }
      }
    } catch (e) {
      print('⚠️  Error scanning ${file.path}: $e');
    }
    return null;
  }

  /// Get the builder directory path by locating this file
  static String? _getBuilderDirectory() {
    try {
      // Try to find the builder directory relative to the current script
      final scriptPath = Platform.script.toFilePath();
      final scriptDir = Directory(path.dirname(scriptPath));

      // Check if we're in the builder directory
      if (path.basename(scriptDir.path) == 'builder') {
        return scriptDir.path;
      }

      // Check parent directory
      final parentDir = scriptDir.parent;
      final builderDir = Directory(path.join(parentDir.path, 'builder'));
      if (builderDir.existsSync()) {
        return builderDir.path;
      }

      // Check sibling core directory (we might be in builder/core)
      if (path.basename(scriptDir.path) == 'core') {
        final builderDir = scriptDir.parent;
        if (path.basename(builderDir.path) == 'builder') {
          return builderDir.path;
        }
      }
    } catch (e) {
      print('⚠️  Error locating builder directory: $e');
    }
    return null;
  }

  /// Fallback to manual registration if auto-discovery fails
  static void _fallbackRegistration(AnnotationRegistry registry) {
    print('📋 Using fallback manual registration...');

    // Instantiate processors directly
    registry.add(ToStringAnnotation());
    registry.add(EqualityAnnotation());
    registry.add(JsonAnnotation());
    registry.add(CopyWithAnnotation());
    registry.add(InitializerAnnotation());

    print('✅ Manually registered ${registry.processors.length} processors');
  }
}

/// Internal class to hold processor metadata during discovery
class _ProcessorInfo {
  final String className;
  final File file;
  final int priority;
  final String? description;

  _ProcessorInfo({
    required this.className,
    required this.file,
    required this.priority,
    this.description,
  });

  /// Instantiate the processor using its static register method
  BaseAnnotationProcessor? instantiate() {
    // We can't use reflection in Dart, so we use a factory pattern
    switch (className) {
      case 'ToStringAnnotation':
        return ToStringAnnotation();
      case 'EqualityAnnotation':
        return EqualityAnnotation();
      case 'JsonAnnotation':
        return JsonAnnotation();
      case 'CopyWithAnnotation':
        return CopyWithAnnotation();
      case 'InitializerAnnotation':
        return InitializerAnnotation();
      default:
        print('⚠️  Unknown processor class: $className');
        return null;
    }
  }
}
