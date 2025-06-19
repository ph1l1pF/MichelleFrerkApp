import 'package:flutter/material.dart';
import 'package:michelle_frerk/models/cart.dart';
import 'package:michelle_frerk/models/product.dart';
import 'package:michelle_frerk/models/product_variant.dart';
import 'package:michelle_frerk/services/checkout_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartRepository extends ChangeNotifier {
  final CheckoutService checkoutService;
  final Cart cart = Cart();

  final outerSplitSymbol = '§§';
  final innerSplitSymbol = '***';

  CartRepository({required this.checkoutService});

  double get totalPrice {
    return cart.totalPrice;
  }

  int get count {
    return cart.count;
  }

  Future<void> loadCart(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString('cart');
    if (cartData == null || cartData.isEmpty) {
      return; 
    }
    final entries = cartData.split(outerSplitSymbol);
    for (var entry in entries) {
      final parts = entry.split(innerSplitSymbol);
      if (parts.length == 2) {
        final variantId = parts[0];
        final quantity = int.tryParse(parts[1]) ?? 0;
        final variant = products
            .expand((product) => product.variants)
            .where(
              (v) => v.id == variantId
            ).firstOrNull;
        
        if (variant != null && quantity > 0) {
          cart.add(variant, quantity);
        }
      }
    }
  }

  Future<CartAddResult> addToCart(ProductVariant variant) async {
    final result = cart.add(variant, 1);
    await _persistCart();
    notifyListeners();
    return result;
  }

  Future<void> clearCart() async {
    cart.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart');
    notifyListeners();
  }

  bool canAdd(ProductVariant variant) {
    return cart.canAdd(variant, 1);
  }

  Future<void> launchCheckout() async {
    if (cart.variantsWithQuantities.isEmpty) {
      throw Exception('Der Warenkorb ist leer.');
    }
    await checkoutService.launchCheckout(cart.variantsWithQuantities);
  }

  Future<void> _persistCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = cart.variantsWithQuantities.entries
        .map((entry) => '${entry.key.id}$innerSplitSymbol${entry.value}')
        .join(outerSplitSymbol);
    await prefs.setString('cart', cartData);
  }

  void remove(ProductVariant variant) {
    if (!cart.variantsWithQuantities.containsKey(variant)) {
      return;
    }
    cart.variantsWithQuantities.remove(variant);
    _persistCart();
    notifyListeners();
  }
}
