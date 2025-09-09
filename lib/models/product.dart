import '../annotations.g.dart';

@Initializer()
@JsonSerializable()
@GenerateToString()
class Product {
  final String id;
  final String name;
  final double price;
  final String? description;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.description,
  });

  static Function()? initialize() {
    print('Initializing Product...');
    return () {
      print('Product post-initialization callback executed');
    };
  }
}
