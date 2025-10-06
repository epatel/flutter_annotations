// Dart core libraries
export 'dart:io';

// Third-party packages
export 'package:analyzer/dart/analysis/utilities.dart';
export 'package:analyzer/dart/ast/ast.dart';
export 'package:analyzer/dart/ast/visitor.dart';
export 'package:args/args.dart';
export 'package:dart_style/dart_style.dart';
export 'package:path/path.dart';
export 'package:pub_semver/pub_semver.dart';

// Core modules
export 'core/annotation_generator.dart';
export 'core/base_annotation.dart';
export 'core/code_builder.dart';
export 'core/field_info.dart';
export 'core/registry.dart';

// Dog food - builder uses its own annotations
export 'annotations.g.dart';
export 'builder.g.dart';
