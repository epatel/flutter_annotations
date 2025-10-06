import '../index.dart';

@RegisterProcessor(priority: 50)
class InitializerAnnotation extends BaseAnnotationProcessor {
  @override
  String get annotationName => 'Initializer';

  @override
  List<String> get annotationAliases => ['initializer'];

  @override
  String get annotationComment =>
      '/// Annotation to mark a class for inclusion in builderInitializer';

  /// Register this annotation processor with the registry
  static void register(AnnotationRegistry registry) {
    registry.add(InitializerAnnotation());
  }

  @override
  String? processAnnotation(
    ClassDeclaration node,
    String className,
    String filePath,
    Annotation? annotation,
  ) {
    // The InitializerAnnotation processor doesn't generate extensions
    // It only tracks classes for the InitializeBuilder function
    // The actual InitializeBuilder generation happens in CodeBuilder
    return null;
  }
}
