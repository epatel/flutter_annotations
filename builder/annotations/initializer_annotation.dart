import 'package:analyzer/dart/ast/ast.dart';
import 'base_annotation.dart';
import 'registry.dart';

class InitializerAnnotation extends BaseAnnotationProcessor {
  @override
  String get annotationName => 'Initializer';

  @override
  List<String> get annotationAliases => ['initializer'];

  /// Register this annotation processor with the registry
  static void register(AnnotationRegistry registry) {
    registry.add(InitializerAnnotation());
  }

  @override
  String? processAnnotation(
    ClassDeclaration node,
    String className,
    String filePath,
  ) {
    // The InitializerAnnotation processor doesn't generate extensions
    // It only tracks classes for the InitializeBuilder function
    // The actual InitializeBuilder generation happens in CodeBuilder
    return null;
  }
}
