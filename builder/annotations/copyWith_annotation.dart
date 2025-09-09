import 'package:analyzer/dart/ast/ast.dart';
import 'base_annotation.dart';
import 'registry.dart';

class CopyWithAnnotation extends BaseAnnotationProcessor {
  @override
  String get annotationName => 'GenerateCopyWith';

  @override
  List<String> get annotationAliases => ['generateCopyWith'];

  @override
  String get annotationComment => '/// Annotation to generate a copyWith method for a class';

  /// Register this annotation processor with the registry
  static void register(AnnotationRegistry registry) {
    registry.add(CopyWithAnnotation());
  }

  @override
  String? processAnnotation(ClassDeclaration node, String className, String filePath) {
    final fields = getClassFields(node);
    if (fields.isEmpty) return null;

    final params = fields.map((f) => '${f.type}? ${f.name}').join(', ');
    final assignments = fields.map((f) => '${f.name}: ${f.name} ?? this.${f.name}').join(', ');

    return '''
extension ${className}CopyWith on $className {
  $className copyWith({$params}) {
    return $className($assignments);
  }
}''';
  }
}