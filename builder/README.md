# Builder System

This directory contains the dynamic annotation/code generation system for Flutter Annotations. It's a self-contained Dart project that processes annotated classes and generates extension methods.

## Install

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/epatel/flutter_annotations/HEAD/install.sh)"
```

## 🏗️ Architecture

### Overview
The builder system uses a registry-based architecture where annotation processors self-register to handle specific annotations. It scans Dart files using the `analyzer` package, identifies annotated classes, and generates extensions without modifying source files.

### Key Components

#### Entry Point
- **`builder.dart`** - Main orchestrator that registers processors and coordinates generation

#### Registry System
- **`annotations/registry.dart`** - Central processor registry
- **`annotations/base_annotation.dart`** - Abstract base class with parameter support
- **`annotations/*_annotation.dart`** - Individual annotation processors

#### Code Generation
- **`core/code_builder.dart`** - AST scanning and extension generation
- **`core/annotation_generator.dart`** - Dynamic annotation class generation
- **`core/field_info.dart`** - Field metadata representation

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

### Step 1: Create Processor
Create `annotations/my_annotation.dart`:
```dart
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
  
  static void register(AnnotationRegistry registry) {
    registry.add(MyAnnotation());
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

### Step 2: Register Processor
Add to `builder.dart` in `_registerAnnotations()`:
```dart
void _registerAnnotations(AnnotationRegistry registry) {
  // ... existing registrations
  MyAnnotation.register(registry);
}
```

### Step 3: Generate
Run `dart builder/builder.dart lib` and the annotation will be available.

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

### 1. File Scanning
The builder recursively scans the source directory for `.dart` files, parsing each with the Dart analyzer.

### 2. Annotation Detection
For each class, it checks for annotations that match registered processors using `canProcess()`.

### 3. Code Generation
Matched processors generate extension methods via `processAnnotation()`, keeping original classes unchanged.

### 4. File Writing
Generated extensions are written to `builder.g.dart`, annotations to `annotations.g.dart`.

### 5. Initialization Support
Classes with `@Initializer()` are added to a global `builderInitializer()` function with callback support.

## 💡 Design Principles

### Extension-Based Generation
- **Non-intrusive**: Original classes remain unchanged
- **Clean separation**: Generated code is clearly separated
- **Import-friendly**: Extensions are automatically available

### Registry Pattern
- **Self-registering**: Processors register themselves
- **Dynamic**: No hardcoded annotation handling
- **Maintainable**: Easy to add/remove processors

### Parameter Support
- **Configurable**: Annotations can accept parameters
- **Type-safe**: Parameters are strongly typed
- **Default values**: Sensible defaults for all parameters

### Dual File Generation
- **annotations.g.dart**: Contains all annotation classes with parameters
- **builder.g.dart**: Contains generated extensions and initialization code

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