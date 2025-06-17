import 'package:intl/intl.dart';
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
}
