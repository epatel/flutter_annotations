import 'package:flutter_annotations/annotations.g.dart';
import 'package:flutter_annotations/builder.g.dart';

@initializer
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
    this.isActive = true,
  });

  static Function()? initialize() {
    print('Initializing User...');
    // No callback needed for User
    return null;
  }

  @override
  String toString() => toStringGenerated();
}
