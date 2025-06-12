import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:michelle_frerk/collections-map.dart';
import 'package:michelle_frerk/environment.dart';
import 'package:michelle_frerk/secrets.dart';

const String shopifyQuery = '''
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

class MediaItem {
  final String type; // 'image' oder 'video'
  final String origin; // 'assets' or 'network'
  final String locator;

  MediaItem({required this.type, required this.origin, required this.locator});
}

Future<List<Map<String, dynamic>>> fetchShopifyProducts() async {
  final Uri url = Uri.https(Environment.shopifyDomain, '/api/2025-04/graphql.json');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'X-Shopify-Storefront-Access-Token': Secrets.accessToken,
    },
    body: jsonEncode({'query': shopifyQuery}),
  );

  if (response.statusCode != 200) {
    print('Fehler beim Laden der Produkte: ${response.body}');
    return [];
  }
  final data = jsonDecode(response.body);
  final collections = data['data']['collections']['edges'] as List;

  List<Map<String, dynamic>> availableProductsWithCategories = [];

  for (var collection in collections) {

    var collectionObject = {
      'id': collection['node']['id'],
      'title': collection['node']['title'],
    };

    // Skip the collection Startseite as it contains duplicates
    if(collectionObject['id'] == collectionMap[Startseite]){
      continue;
    }

    final products = collection['node']['products']['edges'];
    var productObjects =
        products
            .map<Map<String,dynamic>>((e) {
              final node = e['node'];

              final variants = node['variants']['edges'] as List;

              final bool hasAvailableVariant = variants.any(
                (v) =>
                    v['node'] != null && v['node']['availableForSale'] == true,
              );
              if(!hasAvailableVariant) {
                 return <String, dynamic>{};
              }


              return {
                'id': node['id'],
                'title': node['title'],
                'description': node['description'],
                'descriptionHtml': node['descriptionHtml'],
                'hasAvailableVariant': hasAvailableVariant,
                'mediaItems': getMediaItems(node),
                'collection': collectionObject,
                'shortDescription' : node['metafield'] != null
                    ? node['metafield']['value']
                    : '',
                'variants':
                    variants.map((v) {
                      final variantNode = v['node'];
                      return {
                        'id': variantNode['id'],
                        'title': variantNode['title'],
                        'availableForSale': variantNode['availableForSale'],
                        'price': variantNode['price']['amount'],
                        'currencyCode': variantNode['price']['currencyCode'],
                        'image': variantNode['image']?['url'],
                      };
                    })
                    .toList(),
              };
            })
            .where((p) => p['hasAvailableVariant'] == true)
            .toList();

    availableProductsWithCategories.addAll(productObjects);
  }

  return availableProductsWithCategories;
}

List<MediaItem> getMediaItems(dynamic product) {
  final mediaEdges = product['media']['edges'] as List;

  return mediaEdges
      .map<MediaItem?>((e) {
        final node = e['node'];
        final type = node['mediaContentType'];

        if (type == 'IMAGE') {
          return MediaItem(type: 'image', origin: 'network', locator: node['image']['url']);
        } else if (type == 'VIDEO') {
          final sources = node['sources'] as List;
          final videoUrl = sources.first['url'];
          return MediaItem(type: 'video', origin: 'network', locator: videoUrl);
        }
        return null;
      })
      .whereType<MediaItem>()
      .toList();
}
