
import 'package:michelle_frerk/models/product_variant.dart';

class Cart {
  final Map<ProductVariant, int> variantsWithQuantities = {};

  bool canAdd(ProductVariant variant, int quantity) {
    final currentQuantity = variantsWithQuantities[variant] ?? 0;
    if (quantity + currentQuantity > variant.quantityAvailable) {
      return false;
    }
    return true;
  }

  double get totalPrice {
    double total = 0.0;
    variantsWithQuantities.forEach((variant, quantity) {
      total += variant.price * quantity;
    });
    return total;
  }

  int get count => variantsWithQuantities.isNotEmpty
      ? variantsWithQuantities.values.reduce((a, b) => a + b)
      : 0;

  void clear() {
    variantsWithQuantities.clear();
  }

  CartAddResult add(ProductVariant variant, int quantity) {

    if(!canAdd(variant, quantity)) {
      return CartAddResult(
        false,
        'Die Menge übersteigt die verfügbare Menge von ${variant.quantityAvailable}.',
      );
    }

    if (variantsWithQuantities.containsKey(variant)) {
      variantsWithQuantities[variant] = variantsWithQuantities[variant]! + quantity;
    } else {
      variantsWithQuantities[variant] = quantity;
    }
    return CartAddResult(
      true,
      '',
    );
  }
}

class CartAddResult {
  final bool success;
  final String message;

  CartAddResult(this.success, this.message);
}