import 'package:analyzer/dart/ast/ast.dart';
import 'base_annotation.dart';
import 'registry.dart';

class JsonAnnotation extends BaseAnnotationProcessor {
  @override
  String get annotationName => 'JsonSerializable';

  @override
  List<String> get annotationAliases => ['jsonSerializable'];
  
  @override
  List<AnnotationParameter> get annotationParameters => [
    AnnotationParameter(
      type: 'bool',
      name: 'explicitToJson',
      defaultValue: 'false',
      description: 'Whether to explicitly call toJson on nested objects',
    ),
    AnnotationParameter(
      type: 'bool', 
      name: 'includeIfNull',
      defaultValue: 'true',
      description: 'Whether to include null fields in JSON output',
    ),
  ];

  @override
  String get annotationComment => '/// Annotation to generate JSON serialization methods';

  /// Register this annotation processor with the registry
  static void register(AnnotationRegistry registry) {
    registry.add(JsonAnnotation());
  }

  @override
  String? processAnnotation(ClassDeclaration node, String className, String filePath, Annotation? annotation) {
    final fields = getClassFields(node);
    if (fields.isEmpty) return null;

    // Parse annotation parameters
    bool explicitToJson = false;
    bool includeIfNull = true;
    
    if (annotation?.arguments != null) {
      for (final arg in annotation!.arguments!.arguments) {
        if (arg is NamedExpression) {
          final name = arg.name.label.name;
          if (name == 'explicitToJson' && arg.expression.toString() == 'true') {
            explicitToJson = true;
          } else if (name == 'includeIfNull' && arg.expression.toString() == 'false') {
            includeIfNull = false;
          }
        }
      }
    }

    // Generate toJson fields based on parameters
    final toJsonFields = fields.map((f) {
      if (explicitToJson && _isComplexType(f.type)) {
        // For complex types, call toJson() if explicitToJson is true
        if (f.type.endsWith('?')) {
          return "'${f.name}': ${f.name}?.toJson()";
        } else {
          return "'${f.name}': ${f.name}.toJson()";
        }
      } else {
        return "'${f.name}': ${f.name}";
      }
    });

    String toJsonBody;
    if (includeIfNull) {
      // Include all fields
      toJsonBody = 'return {${toJsonFields.join(', ')}};';
    } else {
      // Filter out null fields
      final buffer = StringBuffer();
      buffer.writeln('final map = <String, dynamic>{};');
      for (final field in fields) {
        if (field.type.endsWith('?')) {
          buffer.writeln('if (${field.name} != null) map[\'${field.name}\'] = ${field.name};');
        } else {
          if (explicitToJson && _isComplexType(field.type)) {
            buffer.writeln('map[\'${field.name}\'] = ${field.name}.toJson();');
          } else {
            buffer.writeln('map[\'${field.name}\'] = ${field.name};');
          }
        }
      }
      buffer.writeln('return map;');
      toJsonBody = buffer.toString().trim();
    }

    final fromJsonFields = fields.map((f) => "${f.name}: json['${f.name}'] as ${f.type}").join(', ');

    return '''
extension ${className}Json on $className {
  Map<String, dynamic> toJson() {
    $toJsonBody
  }

  static $className fromJson(Map<String, dynamic> json) {
    return $className($fromJsonFields);
  }
}''';
  }

  bool _isComplexType(String type) {
    // Consider non-primitive types as complex
    final primitiveTypes = ['String', 'int', 'double', 'bool', 'num'];
    final baseType = type.replaceAll('?', '');
    return !primitiveTypes.contains(baseType);
  }
}