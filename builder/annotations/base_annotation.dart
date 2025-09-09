import 'package:analyzer/dart/ast/ast.dart';
import '../core/field_info.dart';

/// Represents a parameter for an annotation class
class AnnotationParameter {
  final String type;
  final String name;
  final String? defaultValue;
  final String? description;

  const AnnotationParameter({
    required this.type,
    required this.name,
    this.defaultValue,
    this.description,
  });
}

/// Abstract base class for all annotation processors
abstract class BaseAnnotationProcessor {
  /// The name of the annotation this processor handles
  String get annotationName;

  /// Alternative names for the annotation (e.g., both 'GenerateToString' and 'generateToString')
  List<String> get annotationAliases => [];

  /// Parameters for the annotation class (empty for simple annotations)
  List<AnnotationParameter> get annotationParameters => [];

  /// Documentation comment for the annotation class
  String get annotationComment;

  /// Check if this processor can handle the given annotation name
  bool canProcess(String annotationName) {
    return this.annotationName == annotationName ||
        annotationAliases.contains(annotationName);
  }

  /// Process the annotation and generate code
  String? processAnnotation(
    ClassDeclaration node,
    String className,
    String filePath,
    Annotation? annotation,
  );

  /// Extract class fields from a ClassDeclaration
  List<FieldInfo> getClassFields(ClassDeclaration node) {
    final fields = <FieldInfo>[];

    for (final member in node.members) {
      if (member is FieldDeclaration) {
        for (final variable in member.fields.variables) {
          final type = member.fields.type?.toString() ?? 'dynamic';
          fields.add(FieldInfo(variable.name.lexeme, type));
        }
      }
    }

    return fields;
  }

  /// Generate an import path from a file path relative to the source directory
  String generateImportPath(String filePath, String sourceDir) {
    // This will be implemented by the registry or builder
    // For now, return a placeholder
    return filePath;
  }
}
