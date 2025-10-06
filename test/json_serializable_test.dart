import 'dart:convert';
import 'package:flutter_annotations/models/user.dart';
import 'package:flutter_annotations/models/product.dart';
import 'package:flutter_annotations/models/category.dart';
import 'package:flutter_annotations/builder.g.dart';

void main() {
  print('=== JsonSerializable Full Round-Trip Tests ===');

  // Test 1: Category (simple object with defaults)
  print(
    '\n--- Category Test (defaults: explicitToJson: false, includeIfNull: true) ---',
  );
  final category = Category(
    id: 'electronics',
    name: 'Electronics',
    description: 'Electronic devices',
  );

  print('Original Category: $category');

  // Category -> Map
  final categoryMap = category.toJson();
  print('Category Map: $categoryMap');

  // Map -> JSON String
  final categoryJsonString = jsonEncode(categoryMap);
  print('Category JSON String: $categoryJsonString');

  // JSON String -> Map -> Category
  final categoryMapFromJson =
      jsonDecode(categoryJsonString) as Map<String, dynamic>;
  final categoryFromJson = CategoryJson.fromJson(categoryMapFromJson);
  print('Category from JSON: $categoryFromJson');

  print(
    'Round-trip successful: ${category.id == categoryFromJson.id && category.name == categoryFromJson.name && category.description == categoryFromJson.description}',
  );

  // Test 2: Category with null description
  print('\n--- Category with null description ---');
  final categoryNull = Category(id: 'books', name: 'Books', description: null);

  final categoryNullMap = categoryNull.toJson();
  print('Category with null Map: $categoryNullMap');
  print(
    'Includes null description: ${categoryNullMap.containsKey("description")}',
  );

  final categoryNullJsonString = jsonEncode(categoryNullMap);
  final categoryNullFromJson = CategoryJson.fromJson(
    jsonDecode(categoryNullJsonString),
  );
  print(
    'Null description preserved: ${categoryNullFromJson.description == null}',
  );

  // Test 3: User (simple object with defaults)
  print(
    '\n--- User Test (defaults: explicitToJson: false, includeIfNull: true) ---',
  );
  final user = User(
    name: 'Alice Johnson',
    age: 28,
    email: 'alice@example.com',
    isActive: true,
  );

  print('Original User: $user');

  final userMap = user.toJson();
  final userJsonString = jsonEncode(userMap);
  print('User JSON String: $userJsonString');

  final userFromJson = UserJson.fromJson(jsonDecode(userJsonString));
  print('User from JSON: $userFromJson');

  print(
    'User round-trip successful: ${user.name == userFromJson.name && user.age == userFromJson.age && user.email == userFromJson.email && user.isActive == userFromJson.isActive}',
  );

  // Test 4: Product (complex object with explicitToJson: true, includeIfNull: false)
  print('\n--- Product Test (explicitToJson: true, includeIfNull: false) ---');
  final product = Product(
    id: 'laptop-001',
    name: 'MacBook Pro',
    price: 2499.99,
    description: 'High-performance laptop',
    category: category, // Nested object
  );

  print('Original Product: $product');

  // Product -> Map (should call category.toJson() due to explicitToJson: true)
  final productMap = product.toJson();
  print('Product Map: $productMap');
  print(
    'Category is Map (explicitToJson worked): ${productMap["category"] is Map}',
  );

  // Map -> JSON String
  final productJsonString = jsonEncode(productMap);
  print('Product JSON String: $productJsonString');

  // JSON String -> Map -> Product (Full round-trip!)
  final productMapFromJson =
      jsonDecode(productJsonString) as Map<String, dynamic>;
  print('Parsed Map from JSON: $productMapFromJson');

  final productFromJson = ProductJson.fromJson(productMapFromJson);
  print('Product from JSON: $productFromJson');

  // Verify full round-trip success
  final roundTripSuccess =
      product.id == productFromJson.id &&
      product.name == productFromJson.name &&
      product.price == productFromJson.price &&
      product.description == productFromJson.description &&
      product.category.id == productFromJson.category.id &&
      product.category.name == productFromJson.category.name &&
      product.category.description == productFromJson.category.description;
  print('Product full round-trip successful: $roundTripSuccess');

  // Test 5: Product with null description (includeIfNull: false)
  print('\n--- Product with null description (includeIfNull: false) ---');
  final productNullDesc = Product(
    id: 'phone-001',
    name: 'iPhone',
    price: 999.99,
    description: null, // This should be excluded due to includeIfNull: false
    category: categoryNull,
  );

  final productNullMap = productNullDesc.toJson();
  print('Product with null desc Map: $productNullMap');
  print(
    'Excludes null description (includeIfNull: false): ${!productNullMap.containsKey("description")}',
  );

  final productNullJsonString = jsonEncode(productNullMap);
  print('Product with null desc JSON: $productNullJsonString');
  print(
    'JSON does not contain description field: ${!productNullJsonString.contains("description")}',
  );

  print('\n=== All JsonSerializable Tests Complete ===');
}
