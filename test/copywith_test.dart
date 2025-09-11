import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_annotations/models/user.dart';
import 'package:flutter_annotations/builder.g.dart';

void main() {
  group('CopyWith Annotation Tests', () {
    final originalUser = User(
      name: 'John Doe',
      age: 30,
      email: 'john.doe@example.com',
      isActive: true,
    );

    test('copyWith creates a new instance', () {
      final copiedUser = originalUser.copyWith();
      expect(identical(originalUser, copiedUser), isFalse);
    });

    test('copyWith with no arguments creates an equal instance', () {
      final copiedUser = originalUser.copyWith();
      expect(copiedUser.isEqualTo(originalUser), isTrue);
    });

    test('copyWith correctly updates a single field', () {
      final updatedUser = originalUser.copyWith(name: 'Jane Doe');
      expect(updatedUser.name, 'Jane Doe');
      expect(updatedUser.age, originalUser.age);
      expect(updatedUser.email, originalUser.email);
      expect(updatedUser.isActive, originalUser.isActive);
    });

    test('copyWith correctly updates multiple fields', () {
      final updatedUser = originalUser.copyWith(age: 31, isActive: false);
      expect(updatedUser.name, originalUser.name);
      expect(updatedUser.age, 31);
      expect(updatedUser.email, originalUser.email);
      expect(updatedUser.isActive, isFalse);
    });

    test('copyWith can chain multiple calls', () {
      final updatedUser = originalUser.copyWith(age: 35).copyWith(name: 'John Smith');
      expect(updatedUser.name, 'John Smith');
      expect(updatedUser.age, 35);
      expect(updatedUser.email, originalUser.email);
    });
  });
}
