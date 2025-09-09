import 'package:flutter_annotations/models/user.dart';
import 'package:flutter_annotations/models/product.dart';
import 'package:flutter_annotations/models/category.dart';
import 'package:flutter_annotations/builder.g.dart';

void main() {
  // Test User with generated extensions
  final user = User(
    name: 'John Doe',
    age: 30,
    email: 'john@example.com',
    isActive: true,
  );

  print('Generated toString: ${user.toStringGenerated()}');

  // Test copyWith
  final updatedUser = user.copyWith(age: 31);
  print('Updated user: ${updatedUser.toStringGenerated()}');

  // Test JSON serialization
  final userJson = user.toJson();
  print('User JSON: $userJson');

  final userFromJson = UserJson.fromJson(userJson);
  print('User from JSON: ${userFromJson.toStringGenerated()}');

  // Test equality
  final user2 = User(
    name: 'John Doe',
    age: 30,
    email: 'john@example.com',
    isActive: true,
  );
  print('Users equal: ${user.isEqualTo(user2)}');
  print('User hashCode: ${user.generatedHashCode}');

  // Test Product with Category
  final category = Category(id: 'cat1', name: 'Electronics');
  final product = Product(
    id: '123',
    name: 'Widget',
    price: 29.99,
    description: 'A useful widget',
    category: category,
  );

  print('Product: ${product.toStringGenerated()}');
  print('Product JSON: ${product.toJson()}');
  print('Category: ${category.toStringGenerated()}');
  print('Category JSON: ${category.toJson()}');
}
