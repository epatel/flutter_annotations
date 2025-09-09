// ignore_for_file: non_constant_identifier_names

import 'package:flutter_annotations/models/user.dart';
import 'package:flutter_annotations/builder.g.dart';

void main() {
  print('=== User Equality and Hash Code Tests ===');

  // Test 1: Basic equality - identical users
  print('\n--- Test 1: Identical Users ---');
  final user1 = User(
    name: 'Alice',
    age: 28,
    email: 'alice@example.com',
    isActive: true,
  );
  final user2 = User(
    name: 'Alice',
    age: 28,
    email: 'alice@example.com',
    isActive: true,
  );

  print('User1: ${user1.toStringGenerated()}');
  print('User2: ${user2.toStringGenerated()}');
  print('Are equal (isEqualTo): ${user1.isEqualTo(user2)}');
  print(
    'Same hash code: ${user1.generatedHashCode == user2.generatedHashCode}',
  );
  print('Hash1: ${user1.generatedHashCode}');
  print('Hash2: ${user2.generatedHashCode}');

  // Test 2: Different users - different names
  print('\n--- Test 2: Different Names ---');
  final user3 = User(
    name: 'Bob',
    age: 28,
    email: 'alice@example.com',
    isActive: true,
  );

  print('User1: ${user1.toStringGenerated()}');
  print('User3: ${user3.toStringGenerated()}');
  print('Are equal (isEqualTo): ${user1.isEqualTo(user3)}');
  print(
    'Same hash code: ${user1.generatedHashCode == user3.generatedHashCode}',
  );
  print('Hash1: ${user1.generatedHashCode}');
  print('Hash3: ${user3.generatedHashCode}');

  // Test 3: Different users - different ages
  print('\n--- Test 3: Different Ages ---');
  final user4 = User(
    name: 'Alice',
    age: 30,
    email: 'alice@example.com',
    isActive: true,
  );

  print('User1: ${user1.toStringGenerated()}');
  print('User4: ${user4.toStringGenerated()}');
  print('Are equal (isEqualTo): ${user1.isEqualTo(user4)}');
  print(
    'Same hash code: ${user1.generatedHashCode == user4.generatedHashCode}',
  );
  print('Hash1: ${user1.generatedHashCode}');
  print('Hash4: ${user4.generatedHashCode}');

  // Test 4: Different users - different emails
  print('\n--- Test 4: Different Emails ---');
  final user5 = User(
    name: 'Alice',
    age: 28,
    email: 'alice.different@example.com',
    isActive: true,
  );

  print('User1: ${user1.toStringGenerated()}');
  print('User5: ${user5.toStringGenerated()}');
  print('Are equal (isEqualTo): ${user1.isEqualTo(user5)}');
  print(
    'Same hash code: ${user1.generatedHashCode == user5.generatedHashCode}',
  );
  print('Hash1: ${user1.generatedHashCode}');
  print('Hash5: ${user5.generatedHashCode}');

  // Test 5: Different users - different isActive status
  print('\n--- Test 5: Different Active Status ---');
  final user6 = User(
    name: 'Alice',
    age: 28,
    email: 'alice@example.com',
    isActive: false,
  );

  print('User1: ${user1.toStringGenerated()}');
  print('User6: ${user6.toStringGenerated()}');
  print('Are equal (isEqualTo): ${user1.isEqualTo(user6)}');
  print(
    'Same hash code: ${user1.generatedHashCode == user6.generatedHashCode}',
  );
  print('Hash1: ${user1.generatedHashCode}');
  print('Hash6: ${user6.generatedHashCode}');

  // Test 6: Self equality (identical instance)
  print('\n--- Test 6: Self Equality ---');
  print('User1: ${user1.toStringGenerated()}');
  print('Self equal (isEqualTo): ${user1.isEqualTo(user1)}');
  print('Same instance: ${identical(user1, user1)}');

  // Test 7: Different type comparison with Object
  print('\n--- Test 7: Different Object Type Comparison ---');
  print('User1: ${user1.toStringGenerated()}');
  final someObject = Object();
  print('Equal to generic Object: ${user1.isEqualTo(someObject)}');

  // Test 8: Different type comparison
  print('\n--- Test 8: Different Type Comparison ---');
  final someString = 'Not a User';
  print('User1: ${user1.toStringGenerated()}');
  print('String: $someString');
  print('Equal to String: ${user1.isEqualTo(someString)}');

  // Test 9: Hash code consistency
  print('\n--- Test 9: Hash Code Consistency ---');
  print('User1: ${user1.toStringGenerated()}');
  final hash1_first = user1.generatedHashCode;
  final hash1_second = user1.generatedHashCode;
  final hash1_third = user1.generatedHashCode;
  print('Hash code call 1: $hash1_first');
  print('Hash code call 2: $hash1_second');
  print('Hash code call 3: $hash1_third');
  print(
    'Hash code is consistent: ${hash1_first == hash1_second && hash1_second == hash1_third}',
  );

  // Test 10: Equality contract verification
  print('\n--- Test 10: Equality Contract Verification ---');
  final userA = User(
    name: 'Test',
    age: 25,
    email: 'test@example.com',
    isActive: true,
  );
  final userB = User(
    name: 'Test',
    age: 25,
    email: 'test@example.com',
    isActive: true,
  );
  final userC = User(
    name: 'Test',
    age: 25,
    email: 'test@example.com',
    isActive: true,
  );

  // Reflexive: a.equals(a) should be true
  final reflexive = userA.isEqualTo(userA);
  print('Reflexive (A == A): $reflexive');

  // Symmetric: a.equals(b) should equal b.equals(a)
  final symmetric = userA.isEqualTo(userB) == userB.isEqualTo(userA);
  print('Symmetric (A == B) == (B == A): $symmetric');

  // Transitive: if a.equals(b) and b.equals(c), then a.equals(c)
  final aEqualsB = userA.isEqualTo(userB);
  final bEqualsC = userB.isEqualTo(userC);
  final aEqualsC = userA.isEqualTo(userC);
  final transitive = (aEqualsB && bEqualsC) ? aEqualsC : true;
  print('Transitive: A == B && B == C implies A == C: $transitive');
  print('  A == B: $aEqualsB');
  print('  B == C: $bEqualsC');
  print('  A == C: $aEqualsC');

  // Hash code contract: if a.equals(b), then a.hashCode() == b.hashCode()
  final hashContract =
      !userA.isEqualTo(userB) ||
      (userA.generatedHashCode == userB.generatedHashCode);
  print('Hash contract (equal objects have equal hash codes): $hashContract');

  print('\n=== All Equality and Hash Code Tests Complete ===');
}
