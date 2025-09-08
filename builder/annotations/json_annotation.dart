import 'package:analyzer/dart/ast/ast.dart';
import 'base_annotation.dart';
import 'registry.dart';

class JsonAnnotation extends BaseAnnotationProcessor {
  @override
  String get annotationName => 'JsonSerializable';

  @override
  List<String> get annotationAliases => ['jsonSerializable'];

  /// Register this annotation processor with the registry
  static void register(AnnotationRegistry registry) {
    registry.add(JsonAnnotation());
  }

  @override
  String? processAnnotation(ClassDeclaration node, String className, String filePath) {
    final fields = getClassFields(node);
    if (fields.isEmpty) return null;

    final toJsonFields = fields.map((f) => "'${f.name}': ${f.name}").join(', ');
    final fromJsonFields = fields.map((f) => "${f.name}: json['${f.name}'] as ${f.type}").join(', ');

    return '''
extension ${className}Json on $className {
  Map<String, dynamic> toJson() {
    return {$toJsonFields};
  }

  static $className fromJson(Map<String, dynamic> json) {
    return $className($fromJsonFields);
  }
}''';
  }
}