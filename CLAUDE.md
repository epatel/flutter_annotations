# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application that demonstrates a custom annotation system with code generation. The project serves as both a working Flutter app and a showcase for a modular annotation/builder system that generates Dart code at build time.

## Key Components

### Flutter Application
- **Architecture**: Feature-based structure with clean separation of concerns
- **State Management**: Provider pattern for state management
- **Navigation**: GoRouter for declarative routing
- **Design System**: Custom theme system with Material 3 design tokens
- **Structure**: `lib/features/`, `lib/core/`, `lib/design_system/`, `lib/models/`

### Annotation & Code Generation System
- **Purpose**: Custom annotation processor that generates Dart extensions for model classes
- **Location**: All builder code lives in `builder/` directory (separate from main Flutter app)
- **Output**: Generates `lib/annotations.g.dart` and `lib/builder.g.dart`
- **Architecture**: Modular, self-registering annotation processors

## Development Commands

### Essential Commands
```bash
# Code generation (must run after model changes)
make generate

# Development workflow
make run              # Run Flutter app in debug mode
make test             # Run all tests
make format           # Format all Dart code
make analyze          # Run static analysis
make reset            # Clean and reinstall dependencies
```

### Builder-specific Commands
```bash
# Manual code generation
dart builder/builder.dart lib

# View builder help
dart builder/builder.dart --help
```

## Code Generation Workflow

### When to Run Code Generation
- After adding/modifying annotations on model classes
- After creating new model classes with annotations
- Before committing changes that involve annotated models

### Annotation Usage
Models use annotations from `lib/annotations.g.dart` (generated file):
```dart
import '../annotations.g.dart';

@generateToString
@generateEquality
@jsonSerializable
@generateCopyWith
class User {
  // class definition
}
```

### Generated Files
- `lib/annotations.g.dart`: Annotation class definitions and constants
- `lib/builder.g.dart`: Generated extensions for annotated models

## Architecture Deep Dive

### Builder System Architecture
- **Registry Pattern**: `AnnotationRegistry` manages all annotation processors
- **Self-Registration**: Each processor registers itself via static `register()` method
- **Modular Processors**: Each annotation type has its own processor class
- **Extension Generation**: Creates Dart extensions rather than modifying source files

### Builder Components
- `builder/builder.dart`: Main entry point and orchestrator
- `builder/core/code_builder.dart`: Core scanning and generation logic
- `builder/core/annotation_generator.dart`: Generates annotation definitions
- `builder/annotations/`: Individual annotation processors
- `builder/annotations/registry.dart`: Central processor registry

### Flutter App Architecture
- **Feature-Based**: Each feature in `lib/features/` with screens, widgets, providers
- **Design System**: Centralized theming in `lib/design_system/`
- **Clean Architecture**: Separation between UI, business logic, and data
- **Provider Pattern**: State management with context providers

## Extension Points

### Adding New Annotations
1. Create processor in `builder/annotations/new_annotation.dart`
2. Extend `BaseAnnotationProcessor`
3. Implement required methods (`annotationName`, `processAnnotation`)
4. Add static `register()` method
5. Register in `builder/builder.dart` `_registerAnnotations()` function
6. Add annotation class to `builder/core/annotation_generator.dart`

### Adding New Features
1. Create feature directory in `lib/features/`
2. Follow existing pattern: `screens/`, `widgets/`, optional `providers/`
3. Add routes to `lib/core/router/app_router.dart`
4. Import and use design system components

## Important Notes

- **Generated Files**: Never edit `*.g.dart` files directly - they are overwritten
- **Dependencies**: Builder has separate `pubspec.yaml` in `builder/` directory
- **Import Paths**: Models import annotations from `../annotations.g.dart`
- **Build Order**: Always run `make generate` before building/testing when models change
- **Self-Contained**: Builder system is independent of main Flutter dependencies