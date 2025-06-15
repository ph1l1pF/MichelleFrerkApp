import 'package:michelle_frerk/models/collection.dart';
import 'package:michelle_frerk/models/media_item.dart';
import 'package:michelle_frerk/models/product_variant.dart';

class Product {
  final String id;
  final String title;
  final String descriptionHtml;
  final bool hasAvailableVariant;
  final Collection collection;
  final String shortDescription;
  final List<ProductVariant> variants;
  final List<MediaItem> mediaItems;

  Product(this.id, this.title, this.descriptionHtml, this.hasAvailableVariant, this.collection, this.shortDescription, this.variants, this.mediaItems);
}