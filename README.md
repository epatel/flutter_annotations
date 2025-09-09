# Flutter Annotations

A Flutter application demonstrating a powerful, dynamic annotation system with automatic code generation. This project showcases a fully modular, registry-based annotation processor that generates Dart extensions at build time.

## 🚀 Features

### Dynamic Annotation System
- **Registry-Based Architecture**: Self-registering annotation processors
- **Parameter Support**: Configurable annotations (e.g., `JsonSerializable` with `explicitToJson`, `includeIfNull`)
- **Nested Object Serialization**: Full round-trip JSON serialization with complex objects
- **Extension Generation**: Creates extensions rather than modifying source files
- **Automatic Documentation**: Each processor defines its own generated comments

### Available Annotations
| Annotation | Generated Methods | Purpose |
|------------|-------------------|---------|
| `@generateToString` | `toStringGenerated()` | Debug-friendly string representation |
| `@generateEquality` | `isEqualTo()`, `generatedHashCode` | Value equality and hash code |
| `@jsonSerializable` | `toJson()`, `fromJson()` | JSON serialization with parameters |
| `@generateCopyWith` | `copyWith()` | Immutable object copying |
| `@initializer` | Added to `builderInitializer()` | Global initialization with callbacks |

### Flutter App Features
- **Provider State Management**: Reactive state management
- **GoRouter Navigation**: Declarative routing
- **Material 3 Design**: Modern design system
- **Feature-Based Architecture**: Clean code organization

## 🏃‍♂️ Quick Start

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK 3.9.2+

### Installation
```bash
git clone <repository-url>
cd flutter_annotations
flutter pub get
```

### Generate Code & Run
```bash
# Generate annotation extensions (required after model changes)
make generate

# Run the Flutter app
make run

# Run tests
make test
```

## 💻 Development Workflow

### Essential Commands
```bash
make generate    # Generate annotations.g.dart and builder.g.dart
make run         # Run Flutter app in debug mode
make test        # Run all tests including JSON round-trip tests
make format      # Format all Dart code
make analyze     # Run static analysis
make reset       # Clean and reinstall dependencies
```

### Manual Code Generation
```bash
dart builder/builder.dart lib
```

## 📝 Usage Examples

### Basic Model with Annotations
```dart
import '../annotations.g.dart';

@generateToString
@generateEquality  
@jsonSerializable
@generateCopyWith
class User {
  final String name;
  final int age;
  final String email;
  final bool isActive;

  const User({
    required this.name,
    required this.age, 
    required this.email,
    required this.isActive,
  });
}
```

### Advanced Model with Parameters and Nested Objects
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
    return () => print('Product post-initialization callback');
  }
}
```

### Using Generated Methods
```dart
// Create instances
final user = User(name: 'Alice', age: 28, email: 'alice@example.com', isActive: true);
final category = Category(id: 'electronics', name: 'Electronics');
final product = Product(id: '123', name: 'Laptop', price: 999.99, category: category);

// Use generated methods
print(user.toStringGenerated());           // Debug string
print(user.isEqualTo(otherUser));         // Value equality
print(user.generatedHashCode);            // Hash code

final userJson = user.toJson();           // Serialize to Map
final userCopy = user.copyWith(age: 29);  // Immutable copy

// JSON serialization with nested objects
final productJson = product.toJson();     // Calls category.toJson() due to explicitToJson: true
final jsonString = jsonEncode(productJson); // Full JSON string
final productFromJson = ProductJson.fromJson(jsonDecode(jsonString)); // Round-trip!
```

### Initialization System
```dart
// In main.dart
void main() {
  builderInitializer(); // Calls all @Initializer classes with callbacks
  runApp(const App());
}
```

## 🏗️ Architecture

### High-Level Structure
- **Flutter App**: Provider state management + GoRouter navigation + Material 3 design
- **Annotation System**: Registry-based processors generate extensions without modifying source files
- **Generated Files**: `annotations.g.dart` (annotation classes) + `builder.g.dart` (extensions)
- **Builder System**: See [`builder/README.md`](builder/README.md) for detailed technical documentation

### Key Design Principles
- **Extension Methods**: Clean separation, non-intrusive code generation
- **Registry Pattern**: Self-registering processors for maintainability
- **Parameter Support**: Configurable annotations (JsonSerializable, etc.)
- **Two-Phase Initialization**: Global setup with optional callbacks

## 🧪 Testing

### Comprehensive Test Suite
- **JSON Round-Trip Tests**: Full object → JSON string → object validation
- **Parameter Testing**: Validates `explicitToJson` and `includeIfNull` behavior  
- **Nested Object Tests**: Complex object serialization validation
- **Generated Method Tests**: All extension method functionality
- **Initialization Tests**: Callback-based initialization system
- **Equality & Hash Code Tests**: Complete equality contract validation (reflexive, symmetric, transitive)

### Run Specific Tests
```bash
make test_units                           # Run all unit tests
dart test/json_serializable_test.dart    # JSON serialization testing
dart test/usage_test.dart                 # Generated method usage
dart test/initializer_test.dart           # Initialization system
dart test/equality_test.dart              # Equality and hash code contract tests
flutter test test/widget_test.dart        # Flutter widget tests
```

## 🔧 Extending the System

Want to create custom annotations? See the comprehensive guide in [`builder/README.md`](builder/README.md#-adding-new-annotations) which covers:

- Creating annotation processors with parameter support
- Registry-based self-registration
- Code generation patterns and best practices
- Complete working examples

## 📋 Important Notes

- **Generated Files**: Never edit `*.g.dart` files - they are completely regenerated
- **Build Order**: Always run `make generate` after model changes
- **Function Names**: Use generated method names to avoid conflicts:
  - `toStringGenerated()` (not `toString()`)
  - `isEqualTo()` (not `operator ==`)
  - `generatedHashCode` (not `hashCode`)
- **Import Pattern**: Models import annotations from `../annotations.g.dart`

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Add/modify annotations following the established patterns
4. Add comprehensive tests for new functionality
5. Run `make generate && make test && make analyze` to ensure everything works
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Built with Flutter and Dart
- Uses the `analyzer` package for AST processing
- Inspired by code generation patterns in the Dart ecosystem