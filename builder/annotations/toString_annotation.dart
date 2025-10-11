import '../index.dart';

@Initializer()
class ToStringAnnotation extends BaseAnnotationProcessor {
  @override
  String get annotationName => 'GenerateToString';

  @override
  List<String> get annotationAliases => ['generateToString'];

  @override
  String get annotationComment =>
      '/// Annotation to generate toString method for a class\n'
      '///\n'
      '/// Add this method to the class\n'
      '/// ```\n'
      '/// @override\n'
      '/// String toString() => toStringGenerated();\n'
      '/// ```';

  /// Initialize and register this annotation processor
  static Function()? initialize() {
    getGlobalRegistry().add(ToStringAnnotation());
    return null;
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

    final fieldsString = fields.map((f) => '${f.name}: \$${f.name}').join(', ');

    return '''
extension ${className}ToString on $className {
  String toStringGenerated() {
    return '$className($fieldsString)';
  }
}''';
  }
}
