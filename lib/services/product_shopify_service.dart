import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:michelle_frerk/repositories/collections-map.dart';
import 'package:michelle_frerk/environment.dart';
import 'package:michelle_frerk/models/collection.dart';
import 'package:michelle_frerk/models/media_item.dart';
import 'package:michelle_frerk/models/product.dart';
import 'package:michelle_frerk/models/product_variant.dart';
import 'package:michelle_frerk/secrets.dart';

class ProductShopifyService {
  final String shopifyQuery = '''
{
  collections(first: 10) {
    edges {
      node {
        id
        title
        handle
        products(first: 100) {
          edges {
            node {
              id
              title
              description
              descriptionHtml
              metafield(namespace: "custom", key: "kurzbeschreibung_f_r_app") {
                value
              }
              variants(first: 10) {
                edges {
                  node {
                    id
                    title
                    availableForSale
                    quantityAvailable
                    price {
                      amount
                      currencyCode
                    }
                    image {
                      url(transform: { maxWidth: 1000, preferredContentType: WEBP })
                      altText
                    }
                  }
                }
              }
              media(first: 50) {
                edges {
                  node {
                    mediaContentType
                    alt
                    ... on MediaImage {
                      image {
                        url(transform: { maxWidth: 1000, preferredContentType: WEBP })
                      }
                    }
                    ... on Video {
                      sources {
                        url
                        format
                        mimeType
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
''';

  List<ProductVariant> _getVariants(Product product, List<dynamic> variantJsons) {
    return variantJsons.map((v) {
      final variantNode = v['node'];
      return ProductVariant(
        variantNode['id'],
        variantNode['title'] != 'Default Title' ? variantNode['title'] : '',
        variantNode['availableForSale'],
        double.parse(variantNode['price']['amount']),
        variantNode['price']['currencyCode'],
        variantNode['image']?['url'],
        variantNode['quantityAvailable'] ?? 0,
        product
      );
    }).toList();
  }

  List<MediaItem> _getMediaItems(dynamic product) {
    final mediaEdges = product['media']['edges'] as List;

    return mediaEdges
        .map<MediaItem?>((e) {
          final node = e['node'];
          final type = node['mediaContentType'];

          if (type == 'IMAGE') {
            return MediaItem(
              type: 'image',
              origin: 'network',
              locator: node['image']['url'],
            );
          } else if (type == 'VIDEO') {
            final sources = node['sources'] as List;
            final videoUrl = sources.first['url'];
            return MediaItem(
              type: 'video',
              origin: 'network',
              locator: videoUrl,
            );
          }
          return null;
        })
        .whereType<MediaItem>()
        .toList();
  }

  Future<dynamic> _fetchCollections() async {
    final Uri url = Uri.https(
      Environment.shopifyDomain,
      '/api/2025-04/graphql.json',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Shopify-Storefront-Access-Token': Secrets.accessToken,
      },
      body: jsonEncode({'query': shopifyQuery}),
    );

    if (response.statusCode != 200) {
      return [];
    }
    final data = jsonDecode(response.body);
    return data['data']['collections']['edges'] as List;
  }

  Future<List<Product>> fetchProducts() async {
    final collections = await _fetchCollections();

    List<Product?> availableProductsWithCategories = [];
    for (var collection in collections) {
      
      final collectionObject = Collection(
        collection['node']['id'],
        collection['node']['title'],
      );

      // Skip the collection Startseite as it contains duplicates
      if (collectionObject.id == collectionMap[Startseite]) {
        continue;
      }

      final products = collection['node']['products']['edges'];
      var productObjects = products.map<Product?>((e) {
        final node = e['node'];

        final variants = node['variants']['edges'] as List;

        final bool hasAvailableVariant = variants.any(
          (v) => v['node'] != null && v['node']['availableForSale'] == true,
        );
        if (!hasAvailableVariant) {
          return null;
        }

        final product = Product(
          node['id'],
          node['title'],
          node['descriptionHtml'],
          hasAvailableVariant,
          collectionObject,
          node['metafield'] != null ? node['metafield']['value'] : '',
          _getMediaItems(node),
        );
        product.setVariants(_getVariants(product, variants));
        return product;
      }).cast<Product?>();

      availableProductsWithCategories.addAll(productObjects);
    }

    return availableProductsWithCategories.where((product) => product != null).cast<Product>().toList();
  }
}
