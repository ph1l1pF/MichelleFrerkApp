import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:michelle_frerk/repositories/cart_repository.dart';
import 'package:michelle_frerk/services/checkout_service.dart';
import 'package:michelle_frerk/utils/price_utils.dart';
import 'package:michelle_frerk/views/carousel.dart';
import 'package:michelle_frerk/models/product.dart';
import 'package:michelle_frerk/models/product_variant.dart';
import 'package:provider/provider.dart';

class ProduktDetailPage extends StatefulWidget {
  final Product product;

  const ProduktDetailPage({super.key, required this.product});

  @override
  State<ProduktDetailPage> createState() => _ProduktDetailPageState();
}

class _ProduktDetailPageState extends State<ProduktDetailPage> {
  late List<ProductVariant> _variants;
  late CheckoutService _checkoutService;
  late CartRepository _cartRepository;
  ProductVariant? _selectedVariant;
  final GlobalKey<ImageCarouselState> _carouselKey =
      GlobalKey<ImageCarouselState>();

  @override
  void initState() {
    super.initState();

    _checkoutService = Provider.of<CheckoutService>(context, listen: false);
    _cartRepository = Provider.of<CartRepository>(context, listen: false);

    _variants = widget.product.variants;

    _selectedVariant =
        _variants.isNotEmpty
            ? _variants.firstWhere((v) => v.availableForSale == true)
            : null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showImageForSelectedVariant(_selectedVariant);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.title)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                ImageCarousel(
                  key: _carouselKey,
                  mediaItems: widget.product.mediaItems,
                ),
              const SizedBox(height: 16),
              if (_variants.length > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: DropdownButton<ProductVariant>(
                    value: _selectedVariant,
                    onChanged:
                        (newValue) => setState(() {
                          _selectedVariant = newValue;
                          showImageForSelectedVariant(newValue);
                        }),
                    items:
                        _variants.map((variant) {
                          final title = variant.title;
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
                                      variant.availableForSale
                                          ? null
                                          : TextDecoration.lineThrough,
                                  color:
                                      variant.availableForSale
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
                    _selectedVariant?.availableForSale == true
                        ? Colors.black
                        : Colors.grey,
                  ),
                ),
                onPressed:
                    _selectedVariant?.availableForSale != true
                        ? null
                        : () async {
                        
                          await _checkoutService.launchCheckoutForSingleVariant(_selectedVariant!);
                        },
                child: const Text(
                  style: TextStyle(color: Colors.white),
                  'Sofort kaufen',
                ),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    _selectedVariant?.availableForSale == true && _cartRepository.canAdd(_selectedVariant!)
                        ? Colors.black
                        : Colors.grey,
                  ),
                ),
                onPressed:
                    _selectedVariant?.availableForSale != true || !_cartRepository.canAdd(_selectedVariant!)
                        ? () {print('bla');}
                        : () async {
                      
                          final addResult = await _cartRepository.addToCart(_selectedVariant!);
                          if (addResult.success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Produkt zum Warenkorb hinzugefügt!'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Fehler beim Hinzufügen zum Warenkorb: ${addResult.message}'),
                              ),
                            );
                          }
                        },
                child: const Text(
                  style: TextStyle(color: Colors.white),
                  'Zum Warenkorb hinzufügen',
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.product.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _selectedVariant?.price != null ? formatPrice(_selectedVariant!.price) : '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Html(
                data: widget.product.descriptionHtml,
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

  void showImageForSelectedVariant(ProductVariant? newValue) {
    final selectedImageUrl = newValue?.imageUrl;

    final index = widget.product.mediaItems.indexWhere(
      (item) => item.locator == selectedImageUrl,
    );

    if (index != -1 && _carouselKey.currentState != null) {
      _carouselKey.currentState!.jumpToPage(index);
    }
  }
}


