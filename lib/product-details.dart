import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:michelle_frerk/carousel.dart';
import 'package:michelle_frerk/environment.dart';
import 'package:url_launcher/url_launcher.dart';

class ProduktDetailPage extends StatefulWidget {
  final Map<String, dynamic> produkt;

  const ProduktDetailPage({super.key, required this.produkt});

  @override
  State<ProduktDetailPage> createState() => _ProduktDetailPageState();
}

class _ProduktDetailPageState extends State<ProduktDetailPage> {
  late List<Map<String, dynamic>> _variants;
  Map<String, dynamic>? _selectedVariant;
  final GlobalKey<ImageCarouselState> _carouselKey =
      GlobalKey<ImageCarouselState>();

  @override
  void initState() {
    super.initState();
    _variants = widget.produkt['variants'];

    _selectedVariant =
        _variants.isNotEmpty
            ? _variants.firstWhere((v) => v['availableForSale'] == true)
            : null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showImageForSelectedVariant(_selectedVariant);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.produkt['title'] ?? 'Produkt')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.produkt['mediaItems'] != null)
                ImageCarousel(
                  key: _carouselKey,
                  mediaItems: widget.produkt['mediaItems'],
                ),
              const SizedBox(height: 16),
              if (_variants.length > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: DropdownButton<Map<String, dynamic>>(
                    value: _selectedVariant,
                    onChanged:
                        (newValue) => setState(() {
                          _selectedVariant = newValue;
                          showImageForSelectedVariant(newValue);
                        }),
                    items:
                        _variants.map((variant) {
                          final title = variant['title'];
                          return DropdownMenuItem(
                            value: variant,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Text(
                                '$title',
                                overflow: TextOverflow.ellipsis,
                                textScaleFactor: 0.8,
                                style: TextStyle(
                                  decoration:
                                      variant['availableForSale'] == true
                                          ? null
                                          : TextDecoration.lineThrough,
                                  color:
                                      variant['availableForSale'] == true
                                          ? Colors.black
                                          : Colors.grey,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    _selectedVariant?['availableForSale'] == true
                        ? Colors.black
                        : Colors.grey,
                  ),
                ),
                onPressed:
                    _selectedVariant?['availableForSale'] != true
                        ? null
                        : () {
                          final variantId = extractVariantId(
                            _selectedVariant?['id'] ?? '',
                          );
                          var baseUri = Uri.https(Environment.shopifyDomain);
                          final url = '$baseUri/cart/$variantId:1';
                          launchCheckoutUrl(url);
                        },
                child: const Text(
                  style: TextStyle(color: Colors.white),
                  'Kaufen',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.produkt['title'] ?? '',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                formatPrice(_selectedVariant?['price']),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Html(
                data: widget.produkt['descriptionHtml'] ?? '',
                style: {
                  "body": Style(
                    fontSize: FontSize.medium,
                    lineHeight: LineHeight.number(1.5),
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showImageForSelectedVariant(Map<String, dynamic>? newValue) {
    final selectedImageUrl = newValue?['image'];

    final index = widget.produkt['mediaItems'].indexWhere(
      (item) => item.locator == selectedImageUrl,
    );

    if (index != -1 && _carouselKey.currentState != null) {
      _carouselKey.currentState!.jumpToPage(index);
    }
  }
}

String extractVariantId(String gid) {
  final parts = gid.split('/');
  return parts.isNotEmpty ? parts.last : gid;
}

Future<void> launchCheckoutUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  } else {
    throw 'Could not launch $url';
  }
}

String formatPrice(String amount) {
  final number = double.tryParse(amount) ?? 0;
  final format = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 2,
  );

  return format.format(number);
}
