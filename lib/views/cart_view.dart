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
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final variant = entry.key;
                      final quantity = entry.value;
                      var title = variant.product.title;
                      if(variant.title.isNotEmpty) {
                        title += ' - ${variant.title}';
                      }
                      return ListTile(
                        title: Text(title),
                        subtitle: Text('Menge: $quantity'),
                        trailing: Text(formatPrice(variant.price)),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await cartRepository.clearCart();
                    setState(() {});
                  },
                  child: const Text('Warenkorb leeren'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await cartRepository.launchCheckout();
                  },
                  child: const Text('Zur Kasse'),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gesamt: ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formatPrice(totalPrice),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}