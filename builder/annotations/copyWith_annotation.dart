import '../index.dart';

@RegisterProcessor(priority: 40)
class CopyWithAnnotation extends BaseAnnotationProcessor {
  @override
  String get annotationName => 'GenerateCopyWith';

  @override
  List<String> get annotationAliases => ['generateCopyWith'];

  @override
  String get annotationComment =>
      '/// Annotation to generate a copyWith method for a class';

  /// Register this annotation processor with the registry
  static void register(AnnotationRegistry registry) {
    registry.add(CopyWithAnnotation());
  }

  @override
  String? processAnnotation(
    ClassDeclaration node,
    String className,
    String filePath,
    Annotation? annotation,
  ) {
    final fields = getClassFields(node);
    if (fields.isEmpty) return null;

    final params = fields
        .map((f) {
          final nonNullableType = f.type.endsWith('?')
              ? f.type.substring(0, f.type.length - 1)
              : f.type;
          return '${nonNullableType}? ${f.name}';
        })
        .join(', ');
    final assignments = fields
        .map((f) => '${f.name}: ${f.name} ?? this.${f.name}')
        .join(', ');

    return '''
extension ${className}CopyWith on $className {
  $className copyWith({$params}) {
    return $className($assignments);
  }
}''';
  }
}
