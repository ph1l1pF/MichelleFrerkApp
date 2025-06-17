// import 'dart:convert';

// import 'package:http/http.dart' as http;
// import 'package:michelle_frerk/environment.dart';
// import 'package:michelle_frerk/models/product_variant.dart';
// import 'package:michelle_frerk/secrets.dart';

// class CartShopifyService {

//   Future<String> createCart(List<ProductVariant> productVariants) async {
//     var lines = productVariants
//         .map((variant) {
//           return '{ merchandiseId: "${variant.id}", quantity: 1 }';
//         })
//         .join(', ');

//     var shopifyQuery = '''
//       mutation {
//         cartCreate(input: {
//           lines: [
//             $lines
//           ]
//         }) {
//           cart {
//             id
//             checkoutUrl
//           }
//         }
//       }
//       ''';

//     var responseJson = await _sendRequest(shopifyQuery);

//     print('Response: $responseJson');

//     return responseJson['data']['cartCreate']['cart']['id'];
//   }

//   Future<dynamic> _sendRequest(String shopifyQuery) async {
//     final Uri url = Uri.https(
//       Environment.shopifyDomain,
//       '/api/2025-04/graphql.json',
//     );
    
//     final response = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'X-Shopify-Storefront-Access-Token': Secrets.accessToken,
//       },
//       body: jsonEncode({'query': shopifyQuery}),
//     );
    
//     var responseJson = jsonDecode(response.body);
//     return responseJson;
//   }

//   Future<String> addToCart(String cardId, List<ProductVariant> productVariants) async {
//     var lines = productVariants
//         .map((variant) {
//           return '{ merchandiseId: "${variant.id}", quantity: 1 }';
//         })
//         .join(', ');

//     var query = '''
//         mutation {
//       cartLinesAdd(cartId: "$cardId", lines: [
//         $lines
//       ]) {
//         cart {
//           id
//         }
//         userErrors {
//           field
//           message
//           code
//         }
//       }
//     }
//     ''';

//     final response = await _sendRequest(query);
//     print('####'+response.toString());
//     return response.toString();
//   }
// }
