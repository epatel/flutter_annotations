import 'package:analyzer/dart/ast/ast.dart';
import 'base_annotation.dart';
import 'registry.dart';

class ToStringAnnotation extends BaseAnnotationProcessor {
  @override
  String get annotationName => 'GenerateToString';

  @override
  List<String> get annotationAliases => ['generateToString'];

  @override
  String get annotationComment => '/// Annotation to generate toString method for a class';

  /// Register this annotation processor with the registry
  static void register(AnnotationRegistry registry) {
    registry.add(ToStringAnnotation());
  }

  @override
  String? processAnnotation(ClassDeclaration node, String className, String filePath, Annotation? annotation) {
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