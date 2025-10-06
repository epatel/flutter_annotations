# Builder System

This directory contains the dynamic annotation/code generation system for Flutter Annotations. It's a self-contained Dart project that processes annotated classes and generates extension methods.

## Install

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/epatel/flutter_annotations/HEAD/install.sh)"
```

## 🏗️ Architecture

### Overview
The builder system uses a **self-referential, registry-based architecture** where annotation processors are themselves marked with `@Initializer()` and auto-register via `builderInitializer()`. This achieves true "dogfooding" - the builder uses its own annotation system on itself.

**Bootstrap Process:**
1. Annotation processor classes are marked with `@Initializer()`
2. Running `./builder.exe .` on the builder directory generates `builder.g.dart` with `builderInitializer()`
3. `builder.dart` calls `builderInitializer()` which auto-registers all processors
4. **Result**: Fully modular - add new processor with `@Initializer()`, regenerate, and it auto-registers

The builder scans Dart files using the `analyzer` package, identifies annotated classes, and generates extensions without modifying source files.

### Key Components

#### Entry Point
- **`builder.dart`** - Main entry point, calls `builderInitializer()` for auto-registration
- **`index.dart`** - Centralized exports including generated files (`builder.g.dart`, `annotations.g.dart`)

#### Generated Files (Self-Referential)
- **`builder.g.dart`** - Contains `builderInitializer()` that registers all processors
- **`annotations.g.dart`** - Contains annotation class definitions

#### Registry System
- **`core/registry.dart`** - Central processor registry + global registry accessor (`getGlobalRegistry()`, `setGlobalRegistry()`)
- **`core/base_annotation.dart`** - Abstract base class with parameter support
- **`annotations/*_annotation.dart`** - Individual processors (all marked with `@Initializer()`)

#### Code Generation
- **`core/code_builder.dart`** - AST scanning and extension generation
- **`core/annotation_generator.dart`** - Dynamic annotation class generation
- **`core/field_info.dart`** - Field metadata representation

#### Import Strategy
- **Simplified imports**: All builder files use `import '../index.dart';` or `import 'index.dart';`
- **Centralized dependencies**: All external packages and internal modules exported from `index.dart`
- **Clean separation**: Builder system independent of main Flutter app dependencies

## 🚀 Usage

### Basic Command
```bash
dart builder/builder.dart lib
```
This scans the `lib/` directory and generates:
- `lib/annotations.g.dart` - Annotation class definitions
- `lib/builder.g.dart` - Generated extensions and `builderInitializer()` function

### Generated Files Structure
```dart
// annotations.g.dart
class GenerateToString { /* ... */ }
class JsonSerializable { 
  final bool explicitToJson;
  final bool includeIfNull;
  /* ... */ 
}
const generateToString = GenerateToString();

// builder.g.dart  
extension UserToString on User {
  String toStringGenerated() { /* ... */ }
}
extension UserJson on User {
  Map<String, dynamic> toJson() { /* ... */ }
}
void builderInitializer() { /* ... */ }
```

## 📝 Available Annotations

| Processor | Annotation | Generated Methods | Parameters |
|-----------|------------|------------------|------------|
| `ToStringAnnotation` | `@generateToString` | `toStringGenerated()` | None |
| `EqualityAnnotation` | `@generateEquality` | `isEqualTo()`, `generatedHashCode` | None |
| `JsonAnnotation` | `@jsonSerializable` | `toJson()`, `fromJson()` | `explicitToJson`, `includeIfNull` |
| `CopyWithAnnotation` | `@generateCopyWith` | `copyWith()` | None |
| `InitializerAnnotation` | `@initializer` | Added to `builderInitializer()` | None |

## 🔧 Adding New Annotations

The system is **fully modular** - processors self-register via `@Initializer` annotation. No manual registration lists needed!

### Step 1: Create Processor
Create `annotations/my_annotation.dart`:
```dart
import '../index.dart';

@Initializer()  // Self-registers via builderInitializer()
class MyAnnotation extends BaseAnnotationProcessor {
  @override
  String get annotationName => 'MyAnnotation';

  @override
  List<String> get annotationAliases => ['myAnnotation'];

  @override
  String get annotationComment => '/// Generates custom functionality';

  @override
  List<AnnotationParameter> get annotationParameters => [
    AnnotationParameter(
      type: 'bool',
      name: 'enabled',
      defaultValue: 'true',
      description: 'Whether to enable the feature',
    ),
  ];

  /// Initialize and register this annotation processor
  static Function()? initialize() {
    getGlobalRegistry().add(MyAnnotation());
    return null;  // Optional callback
  }

  @override
  String? processAnnotation(ClassDeclaration node, String className, String filePath, Annotation? annotation) {
    return '''
extension ${className}MyExtension on $className {
  void myGeneratedMethod() {
    // Generated functionality
  }
}''';
  }
}
```

### Step 2: Export Processor
Add to `index.dart` exports:
```dart
// Add to annotation system exports
export 'annotations/my_annotation.dart';
```

### Step 3: Regenerate Builder (Self-Bootstrap)
Run the builder on itself to update `builder.g.dart`:
```bash
cd builder
./builder.exe .
```

### Step 4: Recompile Builder
```bash
dart compile exe builder.dart -o builder.exe
```

### Step 5: Use New Annotation
Run `dart builder/builder.dart lib` and the annotation is automatically available!

**No manual registration needed!** The `@Initializer` annotation handles everything.

## 🧪 Parameter Support

### Simple Parameters
```dart
@override
List<AnnotationParameter> get annotationParameters => [
  AnnotationParameter(
    type: 'bool',
    name: 'someFlag',
    defaultValue: 'false',
    description: 'Controls behavior',
  ),
];
```

### Complex Parameters  
For JsonSerializable-style annotations:
```dart
@override
List<AnnotationParameter> get annotationParameters => [
  AnnotationParameter(type: 'bool', name: 'explicitToJson', defaultValue: 'false'),
  AnnotationParameter(type: 'bool', name: 'includeIfNull', defaultValue: 'true'),
];
```

Usage in models:
```dart
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Product { /* ... */ }
```

## 🔍 How It Works

### 1. Self-Referential Bootstrap
On startup, `builder.dart` calls `builderInitializer()` (from generated `builder.g.dart`) which auto-registers all annotation processors marked with `@Initializer()`.

### 2. File Scanning
The builder recursively scans the source directory for `.dart` files, parsing each with the Dart analyzer.

### 3. Annotation Detection
For each class, it checks for annotations that match registered processors using `canProcess()`.

### 4. Code Generation
Matched processors generate extension methods via `processAnnotation()`, keeping original classes unchanged.

### 5. File Writing
Generated extensions are written to `builder.g.dart`, annotations to `annotations.g.dart`.

### 6. Initialization Support
Classes with `@Initializer()` are added to a global `builderInitializer()` function with callback support.

### Self-Bootstrap Workflow
When you add a new processor:
1. Mark it with `@Initializer()` and add `initialize()` method
2. Run `./builder.exe .` inside builder directory (generates new `builder.g.dart`)
3. Recompile with `dart compile exe builder.dart`
4. New processor is automatically registered on next run!

## 💡 Design Principles

### Self-Referential Bootstrap
- **Dogfooding**: Builder uses its own `@Initializer` annotation to register processors
- **Modular**: Processors marked with `@Initializer()` auto-register via `builderInitializer()`
- **Zero configuration**: No manual registration lists - fully automatic
- **Self-generating**: Running builder on itself updates registration code

### Extension-Based Generation
- **Non-intrusive**: Original classes remain unchanged
- **Clean separation**: Generated code is clearly separated
- **Import-friendly**: Extensions are automatically available

### Registry Pattern
- **Global registry**: Processors access `getGlobalRegistry()` for self-registration
- **Dynamic**: No hardcoded annotation handling
- **Maintainable**: Easy to add/remove processors

### Parameter Support
- **Configurable**: Annotations can accept parameters
- **Type-safe**: Parameters are strongly typed
- **Default values**: Sensible defaults for all parameters

### Simplified Import Strategy
- **Centralized exports**: All dependencies exported from `index.dart`
- **Self-referential**: `index.dart` exports generated files (`builder.g.dart`, `annotations.g.dart`)
- **Single import**: All files use `import '../index.dart';` or `import 'index.dart';`
- **Reduced maintenance**: Adding new dependencies only requires updating index.dart
- **Clean dependencies**: Clear separation between builder system and main app

### Dual File Generation
- **annotations.g.dart**: Contains all annotation classes with parameters
- **builder.g.dart**: Contains generated extensions and `builderInitializer()` function

## 🚨 Important Notes

### Dependencies
The builder requires:
- `analyzer: ^6.4.1` - For AST parsing
- `dart_style: ^2.3.2` - For code formatting  
- `args: ^2.4.2` - For command line parsing

### Function Naming
Generated methods use specific names to avoid conflicts:
- `toStringGenerated()` (not `toString()`)
- `isEqualTo()` (not `operator ==`)
- `generatedHashCode` (not `hashCode`)

### Build Order
Always run the builder after model changes:
1. Modify model classes with annotations
2. Run `dart builder/builder.dart lib`
3. Generated extensions are available for use

### Generated File Handling
- **Never edit**: `*.g.dart` files are completely regenerated
- **Version control**: Commit generated files for consistency
- **Clean builds**: Remove generated files to force regeneration if needed