import 'package:flutter_annotations/core_index.dart';

@JsonSerializable()
@GenerateToString()
@GenerateCopyWith()
class Category {
  final String id;
  final String name;
  final String? description;

  const Category({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  String toString() => toStringGenerated();
}
