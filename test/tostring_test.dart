import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_annotations/models/user.dart';
import 'package:flutter_annotations/models/product.dart';
import 'package:flutter_annotations/models/category.dart';
import 'package:flutter_annotations/builder.g.dart';

void main() {
  group('ToString Annotation Tests', () {
    test('User toStringGenerated contains all fields and values', () {
      final user = User(
        name: 'Alice',
        age: 28,
        email: 'alice@example.com',
        isActive: true,
      );
      final userString = user.toStringGenerated();

      expect(userString, contains('User'));
      expect(userString, contains('name: Alice'));
      expect(userString, contains('age: 28'));
      expect(userString, contains('email: alice@example.com'));
      expect(userString, contains('isActive: true'));
    });

    test('Product toStringGenerated handles nested objects', () {
      final category = Category(
        id: 'cat-01',
        name: 'Electronics',
        description: 'Gadgets and devices',
      );
      final product = Product(
        id: 'prod-123',
        name: 'Smartphone',
        price: 699.99,
        description: 'A smart device',
        category: category,
      );
      final productString = product.toStringGenerated();

      expect(productString, contains('Product'));
      expect(productString, contains('id: prod-123'));
      expect(productString, contains('name: Smartphone'));
      expect(productString, contains('price: 699.99'));
      expect(productString, contains('description: A smart device'));
      // Check if the nested object's toString is included
      expect(
        productString,
        contains('category: ${category.toStringGenerated()}'),
      );
    });

    test('Category toStringGenerated handles null fields', () {
      final category = Category(id: 'cat-02', name: 'Books', description: null);
      final categoryString = category.toStringGenerated();

      expect(categoryString, contains('Category'));
      expect(categoryString, contains('id: cat-02'));
      expect(categoryString, contains('name: Books'));
      expect(categoryString, contains('description: null'));
    });
  });
}
