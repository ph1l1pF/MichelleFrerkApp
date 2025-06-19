import 'package:michelle_frerk/models/product.dart';

class ProductVariant {
  final String id;
  final String title;
  final bool availableForSale;
  final int quantityAvailable;
  final double price;
  final String currencyCode;
  final String? imageUrl;
  final Product product;

  ProductVariant(
    this.id,
    this.title,
    this.availableForSale,
    this.price,
    this.currencyCode,
    this.imageUrl,
    this.quantityAvailable,
    this.product,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductVariant && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
