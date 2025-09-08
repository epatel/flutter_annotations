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
    this.isActive = true,
  });
}
