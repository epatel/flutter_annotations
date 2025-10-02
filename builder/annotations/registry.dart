import '../index.dart';

/// Registry for all annotation processors
class AnnotationRegistry {
  final List<BaseAnnotationProcessor> _processors = [];

  /// Add an annotation processor to the registry
  void add(BaseAnnotationProcessor processor) {
    _processors.add(processor);
  }

  /// Get all registered processors
  List<BaseAnnotationProcessor> get processors =>
      List.unmodifiable(_processors);

  /// Find a processor that can handle the given annotation name
  BaseAnnotationProcessor? findProcessor(String annotationName) {
    for (final processor in _processors) {
      if (processor.canProcess(annotationName)) {
        return processor;
      }
    }
    return null;
  }

  /// Get all annotation names that can be processed
  List<String> getSupportedAnnotations() {
    final annotations = <String>[];
    for (final processor in _processors) {
      annotations.add(processor.annotationName);
      annotations.addAll(processor.annotationAliases);
    }
    return annotations;
  }

  /// Clear all processors (useful for testing)
  void clear() {
    _processors.clear();
  }
}
