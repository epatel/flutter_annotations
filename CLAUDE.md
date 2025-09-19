# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application that demonstrates a custom annotation system with dynamic code generation. The project serves as both a working Flutter app and a showcase for a fully modular, registry-based annotation/builder system that generates Dart code at build time.

## Core Architecture

### Flutter Application
- **Architecture**: Feature-based structure with Provider state management and GoRouter navigation
- **State Management**: Provider pattern for global state
- **Navigation**: GoRouter for declarative routing  
- **Design System**: Custom theme system with Material 3 design tokens
- **Initialization**: Global `builderInitializer()` function with callback support

### Dynamic Annotation System
- **Registry Pattern**: Self-registering annotation processors with full metadata
- **Dynamic Generation**: Annotations auto-generated from processor definitions
- **Parameter Support**: JsonSerializable supports `explicitToJson` and `includeIfNull` parameters
- **Extension Methods**: Generates extensions rather than modifying source files
- **Nested Objects**: Full support for complex object serialization with `explicitToJson`

## Development Commands

### Essential Workflow
```bash
# Code generation (run after any model changes)
make generate

# Development
make run              # Flutter app in debug mode
make test             # All tests including JSON round-trip tests
make test_table       # All tests with formatted table results
make test_json        # All tests with JSON output for CI/CD
make format           # Format lib/ test/ builder/ directories
make analyze          # Static analysis
make build            # Build for web (includes clean)
make reset            # Clean and reinstall dependencies

# Manual code generation
dart builder/builder.dart lib

# Interactive menu (shows all available commands)
make menu
make select           # Interactive command selection
```

### Test Commands
```bash
# Run all tests (Flutter and Dart)
make test

# Run all unit tests efficiently
make test_units

# Test result aggregation with formatted output
make test_table                                # All tests with formatted table
make test_json                                 # All tests with JSON output
dart test/test_runner.dart --dart-only         # Run only Dart tests
dart test/test_runner.dart --flutter-only      # Run only Flutter tests
dart test/test_runner.dart --verbose           # Show detailed output
dart test/test_runner.dart --format csv        # Export as CSV

# Run specific tests
dart test test/json_serializable_test.dart     # JSON round-trip testing
dart test test/usage_test.dart                 # Generated method usage
dart test test/initializer_test.dart           # Initialization system
dart test test/equality_test.dart              # Equality and hash code contract tests
dart test test/copywith_test.dart              # CopyWith functionality tests
dart test test/tostring_test.dart              # ToString generation tests
flutter test test/widget_test.dart             # Flutter widget tests
```

## Code Generation System

### Current Implementation Status
- **Fully Dynamic**: No hardcoded annotation handling - all driven by registry
- **Parameter Support**: JsonSerializable with `explicitToJson` and `includeIfNull`
- **Auto-Generated Comments**: Each processor defines its own documentation
- **Nested Object Support**: Full round-trip JSON serialization with complex objects
- **Self-Contained**: Builder system independent of main Flutter dependencies

### Generated Function Names
The system generates extension methods with specific naming to avoid conflicts:
- `toStringGenerated()` (not `toString()`)
- `isEqualTo()` (not `operator ==`)
- `generatedHashCode` (not `hashCode`)
- `builderInitializer()` (global function, not `InitializeBuilder`)

### Annotation Usage Examples
```dart
import 'package:flutter_annotations/annotations.g.dart';
import 'package:flutter_annotations/builder.g.dart';
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

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.category,
  });

  // Required for @Initializer classes
  static Function()? initialize() {
    print('Initializing Product...');
    return () => print('Product post-init callback');
  }

  @override
  String toString() => toStringGenerated();
}
```

### JsonSerializable Parameters
- **explicitToJson: true**: Calls `.toJson()` on nested objects (like `category.toJson()`)
- **includeIfNull: false**: Excludes null fields from JSON output
- **Defaults**: `explicitToJson: false, includeIfNull: true`

## Architecture Deep Dive

### Registry-Based System
- **AnnotationRegistry**: Central registry managing all processors
- **BaseAnnotationProcessor**: Abstract base with metadata support
- **AnnotationParameter**: Supports parameterized annotations
- **Dynamic Comments**: Each processor provides its own documentation

### Builder Components
- `builder/builder.dart`: Main orchestrator with self-registering processors
- `builder/core/code_builder.dart`: AST scanning and generation logic
- `builder/core/annotation_generator.dart`: Dynamic annotation class generation
- `builder/core/field_info.dart`: Field metadata and analysis utilities
- `builder/annotations/base_annotation.dart`: Base processor with parameter support
- `builder/annotations/registry.dart`: Central processor registry
- Individual annotation processors:
  - `builder/annotations/json_annotation.dart`: JSON serialization processor
  - `builder/annotations/toString_annotation.dart`: ToString generation processor
  - `builder/annotations/equality_annotation.dart`: Equality and hash code processor
  - `builder/annotations/copyWith_annotation.dart`: CopyWith method processor
  - `builder/annotations/initializer_annotation.dart`: Initialization system processor

### Generated Files Structure
- **lib/annotations.g.dart**: All annotation classes + convenience constants
- **lib/builder.g.dart**: Extensions + `builderInitializer()` function

### Available Annotations
| Annotation | Generated Methods | Parameters |
|------------|-------------------|------------|
| `@generateToString` | `toStringGenerated()` | None |
| `@generateEquality` | `isEqualTo()`, `generatedHashCode` | None |
| `@jsonSerializable` | `toJson()`, `fromJson()` | `explicitToJson`, `includeIfNull` |
| `@generateCopyWith` | `copyWith()` | None |
| `@initializer` | Adds to `builderInitializer()` | None |

## Adding New Annotations

### Step-by-Step Process
1. **Create Processor**: `builder/annotations/new_annotation.dart`
```dart
class NewAnnotation extends BaseAnnotationProcessor {
  @override
  String get annotationName => 'NewAnnotation';
  
  @override  
  List<String> get annotationAliases => ['newAnnotation'];
  
  @override
  String get annotationComment => '/// Description of what this does';
  
  @override
  List<AnnotationParameter> get annotationParameters => [
    // Add parameters if needed
  ];
  
  static void register(AnnotationRegistry registry) {
    registry.add(NewAnnotation());
  }
  
  @override
  String? processAnnotation(...) {
    // Generate extension code
  }
}
```

2. **Register**: Add to `builder/builder.dart` in `_registerAnnotations()`
3. **Test**: The annotation will automatically appear in generated files

### Parameter Support
For parameterized annotations:
```dart
@override
List<AnnotationParameter> get annotationParameters => [
  AnnotationParameter(
    type: 'bool',
    name: 'someFlag', 
    defaultValue: 'false',
    description: 'What this parameter does',
  ),
];
```

## Testing Strategy

### Comprehensive Test Coverage
- **JSON Round-Trip**: Full object → JSON string → object validation
- **Parameter Testing**: Validates `explicitToJson` and `includeIfNull` behavior
- **Nested Objects**: Tests complex object serialization
- **Generated Methods**: Validates all generated extension methods
- **Initialization System**: Tests callback-based initialization
- **Equality Contract**: Complete validation of reflexive, symmetric, transitive properties and hash code consistency

### Test Files Purpose
- `json_serializable_test.dart`: Complete JSON serialization testing
- `usage_test.dart`: Generated method functionality
- `initializer_test.dart`: Initialization system with callbacks
- `equality_test.dart`: Comprehensive equality and hash code contract validation
- `copywith_test.dart`: CopyWith method generation tests
- `tostring_test.dart`: ToString method generation tests
- `widget_test.dart`: Flutter widget integration
- `test_runner.dart`: Test aggregation and result formatting tool

### Test Result Aggregation
The project includes a comprehensive test runner that aggregates results from all tests and presents them in a formatted table:

```bash
# Example output from make test_table:
╔═════════════════════════╤════════╤══════╤══════╤════════╤═════════╗
║Test File                │Type    │Passed│Failed│Time(s) │Status   ║
╠═════════════════════════╪════════╪══════╪══════╪════════╪═════════╣
║copywith_test            │Flutter │1     │0     │1.72    │✅ PASS   ║
║equality_test            │Dart    │1     │0     │0.16    │✅ PASS   ║
║json_serializable_test   │Dart    │1     │0     │0.16    │✅ PASS   ║
║widget_test              │Flutter │1     │0     │2.26    │✅ PASS   ║
╚═════════════════════════╧════════╧══════╧══════╧════════╧═════════╝

Summary: 7 tests passed, 0 failed
Total execution time: 6.29s
Overall result: ✅ ALL TESTS PASSED
```

**Test Runner Features:**
- **Table format**: Clean, readable test results with status indicators
- **JSON output**: Machine-readable format for CI/CD integration (`make test_json`)
- **CSV export**: Spreadsheet-compatible format (`--format csv`)
- **Filtering**: Run only Dart tests (`--dart-only`) or Flutter tests (`--flutter-only`)
- **Performance tracking**: Execution time per test and total runtime
- **Error reporting**: Detailed error messages for failed tests
- **Exit codes**: Returns 0 for success, 1 for failures (CI/CD friendly)

## Important Notes

### Constraints
- **Generated Files**: Never edit `*.g.dart` files - completely regenerated
- **Function Names**: Use generated method names (`toStringGenerated()`, `isEqualTo()`, etc.)
- **Build Order**: Always `make generate` after model changes
- **Import Pattern**: Models import from `package:flutter_annotations/annotations.g.dart` and `package:flutter_annotations/builder.g.dart`
- **Linting**: Uses `flutter_lints` package with `avoid_print: false` configuration
- **Formatting**: Preserves trailing commas as configured in `analysis_options.yaml`

### Architecture Decisions
- **Extension Methods**: Avoids source file modification
- **Registry Pattern**: Enables dynamic, maintainable annotation system  
- **Parameter Support**: Allows complex annotation configuration
- **Nested Object Support**: Full serialization with `explicitToJson`
- **Callback System**: Two-phase initialization with optional callbacks

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.