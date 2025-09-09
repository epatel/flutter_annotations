import '../annotations.g.dart';

@JsonSerializable()
@GenerateToString()
class Category {
  final String id;
  final String name;
  final String? description;

  const Category({
    required this.id,
    required this.name,
    this.description,
  });
}