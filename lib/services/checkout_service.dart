import 'package:michelle_frerk/environment.dart';
import 'package:michelle_frerk/models/product_variant.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutService {
  
  Future<void> launchCheckout(
    Map<ProductVariant, int> variantsWithQuantities,
  ) async {
    var subUrl = '';
    for (var entry in variantsWithQuantities.entries) {
      subUrl += '${_extractVariantId(entry.key.id)}:${entry.value},';
    }
    subUrl = subUrl.substring(0, subUrl.length - 1); // Remove the last ','
    final url = 'https://${Environment.shopifyDomain}/cart/$subUrl';
    await _launchCheckoutUrl(url);
  }

  String _extractVariantId(String gid) {
    final parts = gid.split('/');
    return parts.isNotEmpty ? parts.last : gid;
  }

  Future<void> launchCheckoutForSingleVariant(
    ProductVariant productVariant,
  ) async {
    Map<ProductVariant, int> variantsWithQuantities = {productVariant: 1};
    await launchCheckout(variantsWithQuantities);
  }

  Future<void> _launchCheckoutUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } else {
      throw 'Could not launch $url';
    }
  }
}
