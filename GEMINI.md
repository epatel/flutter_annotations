# GEMINI.md

This file provides guidance to Gemini when working with code in this repository.

## Project Overview

This is a Flutter application that demonstrates a custom annotation system with dynamic code generation. The project serves as both a working Flutter app and a showcase for a fully modular, registry-based annotation/builder system that generates Dart code at build time.

The core of this project is the `builder/` directory, which contains the standalone Dart tool for annotation processing and code generation. The main Flutter application in the root directory serves as a demonstration of how to use these annotations.

## Core Architecture

### Flutter Application
- **Architecture**: Feature-based structure with Provider state management and GoRouter navigation.
- **State Management**: Provider for global state.
- **Navigation**: GoRouter for declarative routing.
- **Design System**: Custom theme system with Material 3 design tokens.
- **Initialization**: Global `builderInitializer()` function with callback support.

### Dynamic Annotation System
- **Registry Pattern**: Self-registering annotation processors with full metadata.
- **Dynamic Generation**: Annotations are auto-generated from processor definitions.
- **Parameter Support**: `JsonSerializable` supports `explicitToJson` and `includeIfNull` parameters.
- **Extension Methods**: Generates extensions rather than modifying source files.
- **Nested Objects**: Full support for complex object serialization with `explicitToJson`.

## Development Commands

The project uses a `Makefile` to simplify the development workflow.

### Essential Workflow
```bash
# Generate annotation extensions (run after any model changes)
make generate

# Run the Flutter app in debug mode
make run

# Run all tests, including JSON round-trip tests
make test

# Format all Dart code in lib/, test/, and builder/ directories
make format

# Run static analysis
make analyze

# Clean and reinstall dependencies
make reset
```

### Manual Code Generation
To run the builder manually:
```bash
dart builder/builder.dart lib
```

## Code Generation System

The annotation system is designed to be fully dynamic, with no hardcoded annotation handling.

### Available Annotations
| Annotation | Generated Methods | Purpose |
|------------|-------------------|---------|
| `@generateToString` | `toStringGenerated()` | Debug-friendly string representation |
| `@generateEquality` | `isEqualTo()`, `generatedHashCode` | Value equality and hash code |
| `@jsonSerializable` | `toJson()`, `fromJson()` | JSON serialization with parameters |
| `@generateCopyWith` | `copyWith()` | Immutable object copying |
| `@initializer` | Added to `builderInitializer()` | Global initialization with callbacks |

### Annotation Usage Example
```dart
import '../annotations.g.dart';
import 'category.dart';

@Initializer()
@JsonSerializable(explicitToJson: true, includeIfNull: false)
@GenerateToString()
class Product {
  final String id;
  final String name;
  final double price;
  final String? description;
  final Category category;  // Nested object

  // Required for @Initializer classes
  static Function()? initialize() {
    print('Initializing Product...');
    return () => print('Product post-init callback');
  }
}
```

### Adding New Annotations

To add a new annotation:
1.  Create a new processor class in `builder/annotations/` that extends `BaseAnnotationProcessor`.
2.  Implement the required methods, including `annotationName`, `annotationComment`, and `processAnnotation`.
3.  Register the new processor in `builder/builder.dart` within the `_registerAnnotations()` function.

For more detailed instructions, refer to the `builder/README.md` file.

## Important Notes

-   **Generated Files**: Never edit `*.g.dart` files directly, as they are completely regenerated on each build.
-   **Build Order**: Always run `make generate` after making changes to any data models to ensure the generated code is up-to-date.
-   **Function Names**: Use the generated method names (e.g., `toStringGenerated()`, `isEqualTo()`) to avoid conflicts with base class methods.
