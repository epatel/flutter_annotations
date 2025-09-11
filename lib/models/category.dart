import 'package:flutter_annotations/annotations.g.dart';
import 'package:flutter_annotations/builder.g.dart';

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
