import '../index.dart';

@Initializer()
class InitializerAnnotation extends BaseAnnotationProcessor {
  @override
  String get annotationName => 'Initializer';

  @override
  List<String> get annotationAliases => ['initializer'];

  @override
  String get annotationComment =>
      '/// Annotation to mark a class for inclusion in builderInitializer';

  /// Initialize and register this annotation processor
  static Function()? initialize() {
    getGlobalRegistry().add(InitializerAnnotation());
    return null;
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
