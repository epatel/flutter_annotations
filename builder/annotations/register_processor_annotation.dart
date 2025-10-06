/// Annotation to mark a class as an annotation processor that should be
/// automatically registered with the AnnotationRegistry.
///
/// This is a meta-annotation used by the builder system itself to achieve
/// self-referential discovery of annotation processors.
///
/// Usage:
/// ```dart
/// @RegisterProcessor()
/// class MyCustomAnnotation extends BaseAnnotationProcessor {
///   // ... implementation
/// }
/// ```
class RegisterProcessor {
  /// Optional priority for registration order (lower numbers = earlier registration)
  final int priority;

  /// Optional description of what this processor does
  final String? description;

  const RegisterProcessor({
    this.priority = 100,
    this.description,
  });
}

/// Convenience constant for the RegisterProcessor annotation
const registerProcessor = RegisterProcessor();
