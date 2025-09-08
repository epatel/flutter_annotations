import 'user.dart';
import 'product.dart';
import '../builder.g.dart';

void exampleUsage() {
  // Test User with generated extensions
  final user = User(
    name: 'John Doe',
    age: 30,
    email: 'john@example.com',
  );

  print('Generated toString: ${user.toString()}');
  
  // Test copyWith
  final updatedUser = user.copyWith(age: 31);
  print('Updated user: ${updatedUser.toString()}');
  
  // Test JSON serialization
  final userJson = user.toJson();
  print('User JSON: $userJson');
  
  final userFromJson = UserJson.fromJson(userJson);
  print('User from JSON: ${userFromJson.toString()}');
  
  // Test equality
  final user2 = User(
    name: 'John Doe',
    age: 30,
    email: 'john@example.com',
  );
  print('Users equal: ${user == user2}');
  print('User hashCode: ${user.hashCode}');

  // Test Product
  final product = Product(
    id: '123',
    name: 'Widget',
    price: 29.99,
    description: 'A useful widget',
  );

  print('Product: ${product.toString()}');
  print('Product JSON: ${product.toJson()}');
}