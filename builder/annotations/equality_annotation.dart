import '../index.dart';

@RegisterProcessor(priority: 20)
class EqualityAnnotation extends BaseAnnotationProcessor {
  @override
  String get annotationName => 'GenerateEquality';

  @override
  List<String> get annotationAliases => ['generateEquality'];

  @override
  String get annotationComment =>
      '/// Annotation to generate equality (== and hashCode) methods for a class';

  /// Register this annotation processor with the registry
  static void register(AnnotationRegistry registry) {
    registry.add(EqualityAnnotation());
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

    final equalityChecks = fields
        .map((f) => '${f.name} == other.${f.name}')
        .join(' && ');
    final hashCodeFields = fields.map((f) => f.name).join(', ');

    return '''
extension ${className}Equality on $className {
  bool isEqualTo(Object other) {
    if (identical(this, other)) return true;
    return other is $className && $equalityChecks;
  }

  int get generatedHashCode => Object.hash($hashCodeFields);
}''';
  }
}
