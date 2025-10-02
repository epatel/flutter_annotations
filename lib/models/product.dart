import 'package:flutter_annotations/index.dart';

@Initializer()
@JsonSerializable(explicitToJson: true, includeIfNull: false)
@GenerateToString()
@GenerateCopyWith()
class Product {
  final String id;
  final String name;
  final double price;
  final String? description;
  final Category category;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    required this.category,
  });

  static Function()? initialize() {
    print('Initializing Product...');
    return () {
      print('Product post-initialization callback executed');
    };
  }

  @override
  String toString() => toStringGenerated();
}
