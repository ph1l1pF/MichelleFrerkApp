import 'package:flutter/material.dart';
import 'package:michelle_frerk/repositories/cart_repository.dart';
import 'package:michelle_frerk/utils/price_utils.dart';
import 'package:provider/provider.dart';

class CartView extends StatefulWidget {
  const CartView({Key? key}) : super(key: key);

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  @override
  Widget build(BuildContext context) {
    final cartRepository = Provider.of<CartRepository>(context, listen: true);
    final cartItems = cartRepository.cart.variantsWithQuantities;
    final totalPrice = cartRepository.totalPrice;

    final entries = cartItems.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warenkorb'),
      ),
      body: entries.isEmpty
          ? const Center(child: Text('Dein Warenkorb ist leer.'))
          : SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final variant = entry.key;
                      final quantity = entry.value;
                      var title = variant.product.title;
                      if (variant.title.isNotEmpty) {
                        title += ' - ${variant.title}';
                      }
                      return ListTile(
                        title: Text(title),
                        subtitle: Text('Menge: $quantity'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(formatPrice(variant.price)),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.black),
                              tooltip: 'Entfernen',
                              onPressed: () {
                                setState(() {
                                  cartRepository.remove(variant);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Text(
                          'Gesamt: ',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          formatPrice(totalPrice),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            await cartRepository.launchCheckout();
                          },
                          icon: const Icon(Icons.shopping_bag),
                          label: const Text('Zur Kasse'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            await cartRepository.clearCart();
                            setState(() {});
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Warenkorb leeren'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}