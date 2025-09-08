import 'package:analyzer/dart/ast/ast.dart';
import 'base_annotation.dart';
import 'registry.dart';

class EqualityAnnotation extends BaseAnnotationProcessor {
  @override
  String get annotationName => 'GenerateEquality';

  @override
  List<String> get annotationAliases => ['generateEquality'];

  /// Register this annotation processor with the registry
  static void register(AnnotationRegistry registry) {
    registry.add(EqualityAnnotation());
  }

  @override
  String? processAnnotation(ClassDeclaration node, String className, String filePath) {
    final fields = getClassFields(node);
    if (fields.isEmpty) return null;

    final equalityChecks = fields.map((f) => '${f.name} == other.${f.name}').join(' && ');
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